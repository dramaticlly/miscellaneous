SET search_path TO uber, public;

drop view if exists ratedclient cascade;
drop view if exists uniqueCD cascade;
drop view if exists hasrating cascade;
drop view if exists diff cascade;
drop view if exists Dontcare cascade;
drop view if exists todelete cascade;
drop view if exists ans cascade;


-- the client has ever ride with any driver
/*
 client_id | driver_id | request_id | rating 
-----------+-----------+------------+--------
       100 |     22222 |          2 |      5
       100 |     22222 |          3 |      5
       100 |     22222 |          4 |      2
        99 |     22222 |         10 |      3
        99 |     54321 |         11 |      3
       100 |     54321 |         12 |      3
        99 |     12345 |          1 |      5
       100 |     22222 |          5 |       
       100 |     22222 |          8 |       
       100 |     22222 |          6 |       
       100 |     22222 |          7 |       
(11 rows)
*/
create view ratedclient as
	select client.client_id,
	dispatch.driver_id,
	dropoff.request_id,
	driverrating.rating
	from client 
	join request
		on client.client_id = request.client_id
	join dispatch 
		on request.request_id = dispatch.request_id
	join pickup
		on dispatch.request_id = pickup.request_id
	join dropoff
		on pickup.request_id = dropoff.request_id
	left join DriverRating 
		on DriverRating.request_id = dropoff.request_id;

-- debug
--select * from driverrating;

-- only rated ride
create view hasrating as 
	select * 
	from ratedclient
	where rating is not null;

-- debug
--select * from ratedclient;

-- the request that does not have rating
-- complement of hasrating
/* 
client_id | driver_id | request_id | rating 
-----------+-----------+------------+--------
       100 |     22222 |          7 |       
       100 |     22222 |          5 |       
       100 |     22222 |          6 |       
       100 |     22222 |          8 |       
(4 rows)
*/
create view diff as
	(select * from ratedclient)
	except
	(select * from hasrating);

-- debug
--select * from diff;

-- if same client, same driver, 
-- then we dont care about if rated since at least one rated in hasrated tbl
create view Dontcare as 
	select *
	from diff 
	where diff.driver_id in 
	(select driver_id 
	from hasrating
	where diff.client_id = hasrating.client_id
	and diff.driver_id = hasrating.driver_id);

-- the rest of unrated trip matters
create view todelete as
	(select * from diff)
	except
	(select * from Dontcare);

-- filter out unrated trip with different driver
create view final as 
(select client_id from hasrating) 
except
(select client_id from todelete);

-- use client_id to find email and order by email asc
create view ans as
	select client.client_id,email
	from client join final
	on client.client_id = final.client_id
	order by email;

select * from ans;

/*
===========
  QUERY 9
===========
        Correct answer for query 9.
*/


