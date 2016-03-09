SET search_path TO uber, public;

drop view if exists ID;

create view ID as
select driver.driver_id, Dropoff.request_id 
from Driver 
	left join Dispatch
		on driver.driver_id = Dispatch.driver_id
	join Pickup
		on Dispatch.request_id = Pickup.request_id
	join Dropoff
		on Pickup.request_id = Dropoff.request_id;

select driver_id, 
count(case WHEN rating = 5 THEN 1 ELSE NULL end) as r5, 
count(case WHEN rating = 4 THEN 1 ELSE NULL end) as r4, 
count(case WHEN rating = 3 THEN 1 ELSE NULL end) as r3, 
count(case WHEN rating = 2 THEN 1 ELSE NULL end) as r2, 
count(case WHEN rating = 1 THEN 1 ELSE NULL end) as r1
from ID left join DriverRating
on ID.request_id = DriverRating.request_id
group by driver_id;
