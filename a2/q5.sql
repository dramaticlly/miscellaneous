SET search_path TO uber, public;

drop view if exists basicinfo cascade;
drop view if exists my cascade;
drop view if exists total cascade;
drop view if exists mofi cascade;
drop view if exists mavg cascade;
drop view if exists combination cascade;
drop view if exists personal cascade;
drop view if exists p0 cascade;
drop view if exists m0 cascade;
drop view if exists raw cascade;
drop view if exists final cascade;

-- join request, dispatch, dropoff together
create view basicinfo as
	select client.client_id, dropoff.request_id, dropoff.datetime
	from client 
	join request
		on client.client_id = request.client_id
	join dispatch 
		on request.request_id = dispatch.request_id
	join pickup
		on dispatch.request_id = pickup.request_id
	join dropoff
		on pickup.request_id = dropoff.request_id;

-- list client, req_id based on month/year
create view my as
  select client_id,request_id, extract(month 
  from datetime) as m, extract(year from datetime) as y
  from basicinfo
  order by y,m;

-- DEBUG select * from my;
/* client_id | request_id | m   |  y
-----------+------------+-------+------
       100 |          2 |     2 | 2013
       100 |         12 |     2 | 2013
       100 |          3 |     2 | 2013
       100 |          4 |     2 | 2013
       100 |          6 |     7 | 2014
       100 |          5 |     7 | 2014
       100 |          7 |     7 | 2014
       100 |          8 |     7 | 2015
        99 |         10 |     7 | 2015
        99 |         11 |     1 | 2016
        99 |          1 |     1 | 2016
*/

-- sum over month
create view total as
	select sum(amount) as t, 
	count(billed.request_id) as num, 
	--'a'||(to_char(y,'9999')||to_char(m,'99'))||'a' as month
	(to_char(y,'9999')||to_char(m,'99')) as month,
	m,y
	from my left join billed
	on my.request_id = billed.request_id
	group by y,m
	order by y,m, sum(amount);
-- DEBUG select * from total;
/*  total
   t   | num |  month   | m  |  y   
-------+-----+----------+----+------
 536.1 |   3 |  2013  2 |  2 | 2013
  17.1 |   3 |  2014  7 |  7 | 2014
   5.7 |   1 |  2015 11 | 11 | 2015
   8.5 |   1 |  2016  1 |  1 | 2016
(5 rows)
*/


-- month where at least one ride
create view mofi as
	select distinct m,y from total
	where t is not null;

-- monthly average bill
create view mavg as
	select month, m,y,t/num as ave from total;

-- cartesian product to generate every possibly combination
create view combination as
	select client.client_id,y,m
	from client,mofi;
/*
 client_id |  y   | m  
-----------+------+----
        99 | 2015 | 11
        99 | 2013 |  2
        99 | 2016 |  1
        99 | 2014 |  7
       100 | 2015 | 11
       100 | 2013 |  2
       100 | 2016 |  1
       100 | 2014 |  7
        88 | 2015 | 11
        88 | 2013 |  2
        88 | 2016 |  1
        88 | 2014 |  7
3 id * 4 month =(12 rows) */

-- sum over client_id in every month
create view personal as
	select c.client_id, c.y, c.m, sum(amount) as total
	from combination c
		left join my
		on c.client_id = my.client_id 
			and c.m = my.m
			and c.y = my.y
		left join billed
		on my.request_id = billed.request_id
	group by c.client_id,c.y,c.m;

/*
 client_id |  y   | m  | client_id | request_id | amount 
-----------+------+----+-----------+------------+--------
        88 | 2016 |  1 |           |            |       
        88 | 2014 |  7 |           |            |       
        88 | 2015 |  7 |           |            |       
        88 | 2013 |  2 |           |            |       
        88 | 2015 | 11 |           |            |       
        99 | 2016 |  1 |        99 |         11 |       
        99 | 2016 |  1 |        99 |          1 |    8.5
        99 | 2014 |  7 |           |            |       
        99 | 2015 |  7 |        99 |         10 |       
        99 | 2013 |  2 |           |            |       
        99 | 2015 | 11 |           |            |       
       100 | 2016 |  1 |           |            |       
       100 | 2014 |  7 |       100 |          5 |    5.1
       100 | 2014 |  7 |       100 |          7 |    6.2
       100 | 2014 |  7 |       100 |          6 |    5.8
       100 | 2015 |  7 |           |            |       
       100 | 2013 |  2 |       100 |          4 |  175.5
       100 | 2013 |  2 |       100 |         12 |       
       100 | 2013 |  2 |       100 |          2 |  255.2
       100 | 2013 |  2 |       100 |          3 |  105.4
       100 | 2015 | 11 |       100 |          8 |    5.7
(21 rows)
*/


--final view of interest: mavg & personal
-- p0 and a0 used to set null to 0, coalesce(total,0)
create view p0 as
	select client_id,y,m,coalesce(total,0) as total 
	from personal;

create view a0 as
	select m,y,coalesce(ave,0) as ave 
	from mavg;

-- unsorted results
create view raw as 
	(select client_id,p.m,p.y,total,ave,'below' as comparison 
	from p0 p join a0 m 
	on p.y = m.y and p.m = m.m
	where p.total < m.ave)
	union
	(select client_id,p.m,p.y,total,ave,'at or above' as comparison 
	from p0 p join a0 m 
	on p.y = m.y and p.m = m.m
	where p.total >= m.ave);

-- finally...
create view final as 
  select client_id,
  (to_char(y,'9999')||to_char(m,'99')) as month,
  total,
  comparison
  from raw
  order by y,m,total,client_id asc;

select * from final;

/*  order diff, and space inbwteen month diff
===========
  QUERY 5
===========
        Incorrect answer for query 5.

Expected:
--------- 

 client_id | month  | total | comparison  
-----------+--------+-------+-------------
        88 | 2013 2 |     0 | below
        99 | 2013 2 |     0 | below
       100 | 2013 2 | 536.1 | at or above
        88 | 2014 7 |     0 | below
        99 | 2014 7 |     0 | below
       100 | 2014 7 |  17.1 | at or above
        99 | 2015 7 |     0 | below
        88 | 2015 7 |     0 | below
       100 | 2015 7 |   5.7 | at or above
        88 | 2016 1 |     0 | below
       100 | 2016 1 |     0 | below
        99 | 2016 1 |   8.5 | at or above
(12 rows)

Actual:
------- 

 client_id |  month   | total | comparison  
-----------+----------+-------+-------------
        88 |  2013  2 |     0 | below
        99 |  2013  2 |     0 | below
       100 |  2013  2 | 536.1 | at or above
        88 |  2014  7 |     0 | below
        99 |  2014  7 |     0 | below
       100 |  2014  7 |  17.1 | at or above
        88 |  2015  7 |     0 | below
        99 |  2015  7 |     0 | below
       100 |  2015  7 |   5.7 | at or above
        88 |  2016  1 |     0 | below
       100 |  2016  1 |     0 | below
        99 |  2016  1 |   8.5 | at or above
(12 rows)
*/