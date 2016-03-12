SET search_path TO uber, public;
/*
duration: time bw pickup and dropoff
total duration: sum of driver rides whose pickup and droppff on same day
break: time bw dropoff and next pickup (same day)
no break before 1st pickup || after last dropoff

by law:   
	drive during >= 12 hours per day, 
	break < 15 minutes
	and 3 days in a row
*/

drop view if exists basic cascade;
drop view if exists hasbreakdriver cascade;
drop view if exists brkview cascade;
drop view if exists aggregate cascade;
drop view if exists temp cascade;
drop view if exists basicbydate cascade;
drop view if exists raw cascade;
drop view if exists ans cascade;



create view basic as
	select dispatch.driver_id,dispatch.request_id,
		pickup.datetime::timestamp::date as start,
          dropoff.datetime::timestamp::date as end,
          pickup.datetime as stime, dropoff.datetime as etime,
		dropoff.datetime - pickup.datetime as duration 
	from pickup 
		join dropoff 
		on pickup.request_id = dropoff.request_id
		join dispatch 
		on dispatch.request_id = pickup.request_id;

/*
 drer_id | r_id |   start    |    end     
 |        stime        |        etime        | duration 
---------+------+------------+------------
+---------------------+---------------------+----------
   12345 |    1 | 2015-07-01 | 2015-07-01 
   | 2015-07-01 08:05:00 | 2015-07-01 22:10:00 | 14:05:00
   12345 |    2 | 2015-07-02 | 2015-07-02 
   | 2015-07-02 08:05:00 | 2015-07-02 14:10:00 | 06:05:00
   12345 |    3 | 2015-07-02 | 2015-07-02 
   | 2015-07-02 14:20:00 | 2015-07-02 22:25:00 | 08:05:00
   12345 |    4 | 2015-07-03 | 2015-07-03 
   | 2015-07-03 08:05:00 | 2015-07-03 22:10:00 | 14:05:00
(11 rows)
*/


-- the driver has more than 1 ride in same date
create view hasbreakdriver as 
     select driver_id,start,
            count(start) 
     from basic 
     group by start,driver_id 
     having count(start)>1;
/*
 driver_id |   start    | count 
-----------+------------+-------
     12345 | 2015-07-02 |     2
*/

-- select break for driver who should hasbreak
create view brkview as 
     select b1.start, b1.driver_id,
            b1.etime, b2.stime, 
            b2.stime - b1.etime as break
     from basic b1, basic b2
     where  b1.etime < b2.stime 
       and b1.start = b2.end -- ensure start & end in same date
       and b1.driver_id = b2.driver_id
       and b1.request_id != b2.request_id
       and (b1.driver_id,b1.start) in 
          (select driver_id,start from hasbreakdriver);
/*
   start    | driver_id |        etime        |        stime        |  break   
------------+-----------+---------------------+---------------------+----------
 2015-07-02 |     12345 | 2015-07-02 14:10:00 | 2015-07-02 14:20:00 | 00:10:00
 */

-- TODO: update when driver has 2 ride in same date to basic 
-- col of interest: driver_id, start, duration(sum over date for same driver)
create view aggregate as
     select b.driver_id,b.start,
          sum(duration) as duration, break
     from basic b join brkview k
       on b.driver_id = k.driver_id
         and b.start = k.start
     where (b.driver_id,b.start) 
          in (select driver_id,start from hasbreakdriver)
     group by b.driver_id,b.start,k.break;
/*
 driver_id |   start    | duration |  break   
-----------+------------+----------+----------
     12345 | 2015-07-02 | 14:10:00 | 00:10:00
*/
create view temp as 
     select request_id,stime,etime,start     
     from basic b
     where (driver_id,start) in 
     (select driver_id,start from hasbreakdriver);
/*
 request_id |        stime        |        etime        |   start    
------------+---------------------+---------------------+------------
          2 | 2015-07-02 08:05:00 | 2015-07-02 14:10:00 | 2015-07-02
          3 | 2015-07-02 14:20:00 | 2015-07-02 22:25:00 | 2015-07-02
*/

create view basicbydate as
     (select driver_id, start, duration, null as break
     from basic
     where request_id not in 
          (select request_id from temp))
     union
     (select driver_id, start, duration, break from aggregate);
/*
 driver_id |   start    | duration |  break   
-----------+------------+----------+----------
     12345 | 2015-07-03 | 14:05:00 | 
     12345 | 2015-07-01 | 14:05:00 | 
     12345 | 2015-07-02 | 14:10:00 | 00:10:00
*/

-- select driver who drive 3 days in a row
-- should select from view which is group by date
-- col of interest: driver_id, start, duration, break
create view raw as
     select b1.driver_id,
  b1.start as s1, b2.start as s2, b3.start as s3,
  -- b1.request_id as r1, b2.request_id as r2, b3.request_id as r3,
  b1.duration as d1, b2.duration as d2, b3.duration as d3,
  (b1.duration + b2.duration + b3.duration) as driving,
  (case when b1.break > INTERVAL '0' then b1.break else INTERVAL '0' end) +
  (case when b2.break > INTERVAL '0' then b2.break else INTERVAL '0' end) +
  (case when b3.break > INTERVAL '0' then b3.break else INTERVAL '0' end) 
  as break
     from basicbydate b1, basicbydate b2, basicbydate b3
     -- 3 day in a row
     where b1.start = b2.start -1 
       and b2.start = b3.start -1
     -- same driver
       and b1.driver_id = b2.driver_id 
       and b2.driver_id = b3.driver_id
     order by driving desc, break asc;
/*
 d_id |     s1     |     s2     |     s3     |    d1    |    d2    |    d3    
 | driving  |  break   
-----------+------------+------------+------------+----------+----------+------
---+----------+----------
|12345 | 2015-07-01 | 2015-07-02 | 2015-07-03 | 14:05:00 | 14:10:00 | 14:05:00 
| 42:20:00 | 00:10:00
*/

-- shoudl be driving >= 12 hours per day while break 15 min or less in a day
-- but i just did total >= 36 hour and < 45 min;
create view ans as
     select driver_id as driver,
     s1 as start,
     driving,
     break as breaks
     from  raw
     where driving >= interval '36 hours' 
       and break <= interval '45 minutes'
     order by driving desc, break asc;


select * from ans;

