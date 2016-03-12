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

create view basic as
	select dispatch.driver_id,dispatch.request_id,
		pickup.datetime as start, dropoff.datetime as end,
		dropoff.datetime - pickup.datetime as duration 
	from pickup 
		join dropoff 
		on pickup.request_id = dropoff.request_id
		join dispatch 
		on dispatch.request_id = pickup.request_id;

/*
 driver_id | request_id |      datetime       |      datetime       |     duration      
-----------+------------+---------------------+---------------------+-------------------
     12345 |          1 | 2016-01-08 04:14:00 | 2016-01-08 04:14:00 | 00:00:00
     22222 |          2 | 2013-02-01 08:06:00 | 2013-02-01 08:16:00 | 00:10:00
     22222 |          3 | 2013-02-02 08:06:00 | 2013-02-02 08:16:00 | 00:10:00
     22222 |          4 | 2013-02-03 08:06:00 | 2013-02-03 08:16:00 | 00:10:00
     22222 |          5 | 2014-07-01 08:06:00 | 2014-07-01 08:16:00 | 00:10:00
     22222 |          6 | 2014-07-02 08:06:00 | 2014-07-02 08:16:00 | 00:10:00
     22222 |          7 | 2014-07-03 08:06:00 | 2014-07-03 08:16:00 | 00:10:00
     22222 |         10 | 2015-07-04 08:16:00 | 2015-07-04 08:16:00 | 00:00:00
     54321 |         11 | 2016-01-08 05:14:00 | 2016-01-08 05:14:00 | 00:00:00
     54321 |         12 | 2013-02-01 05:06:00 | 2013-02-01 05:16:00 | 00:10:00
     22222 |          8 | 2015-07-01 08:06:00 | 2015-11-01 08:16:00 | 123 days 00:10:00

(11 rows)
*/


-- we should only be interest (driver, date) combination, and it's duration in each date
select driver_id,start,sum(duration)
from basic
group by driver_id,start
order by driver_id,start;
/*
 driver_id |        start        |        sum        
-----------+---------------------+-------------------
     12345 | 2016-01-08 04:14:00 | 00:00:00
     22222 | 2013-02-01 08:06:00 | 00:10:00
     22222 | 2013-02-02 08:06:00 | 00:10:00
     22222 | 2013-02-03 08:06:00 | 00:10:00
     22222 | 2014-07-01 08:06:00 | 00:10:00
     22222 | 2014-07-02 08:06:00 | 00:10:00
     22222 | 2014-07-03 08:06:00 | 00:10:00
     22222 | 2015-07-01 08:06:00 | 123 days 00:10:00
     22222 | 2015-07-04 08:16:00 | 00:00:00
     54321 | 2013-02-01 05:06:00 | 00:10:00
     54321 | 2016-01-08 05:14:00 | 00:00:00
(11 rows)
*/
