SET search_path TO uber, public;

drop view if exists ID cascade;
drop view if exists ID cascade;


create view ID as
select driver.driver_id, Dropoff.request_id 
from Driver 
	left join Dispatch
		on driver.driver_id = Dispatch.driver_id
	join Pickup
		on Dispatch.request_id = Pickup.request_id
	join Dropoff
		on Pickup.request_id = Dropoff.request_id;

create view ans as
	select driver_id, 
	count(case WHEN rating = 5 THEN 1 ELSE NULL end) as r5, 
	count(case WHEN rating = 4 THEN 1 ELSE NULL end) as r4, 
	count(case WHEN rating = 3 THEN 1 ELSE NULL end) as r3, 
	count(case WHEN rating = 2 THEN 1 ELSE NULL end) as r2, 
	count(case WHEN rating = 1 THEN 1 ELSE NULL end) as r1 
	from ID left join DriverRating
	on ID.request_id = DriverRating.request_id
	group by driver_id
	order by r5 desc,r4 desc,r3 desc,r2 desc,r1 desc;


select * from ans;

/*  diff on 0 and null
===========
  QUERY 7
===========
        Incorrect answer for query 7.

Expected:
--------- 

 driver_id | r5 | r4 | r3 | r2 | r1 
-----------+----+----+----+----+----
     33333 |  4 |  2 |  2 |  2 |   
     12345 |  4 |  1 |  2 |  1 |  1
     22222 |  1 |  1 |  1 |  1 |  1
(3 rows)


Actual:
------- 

 driver_id | r5 | r4 | r3 | r2 | r1 
-----------+----+----+----+----+----
     33333 |  4 |  2 |  2 |  2 |  0
     12345 |  4 |  1 |  2 |  1 |  1
     22222 |  1 |  1 |  1 |  1 |  1
(3 rows)
*/