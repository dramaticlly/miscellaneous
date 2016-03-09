SET search_path TO uber, public;

drop view if exists ratedclient;

-- the client has ever rate any ride
create view ratedclient as
	select client.client_id, dispatch.driver_id, DriverRating.request_id 
	from client 
	join request
		on client.client_id = request.client_id
	join dispatch 
		on request.request_id = dispatch.request_id
	join pickup
		on dispatch.request_id = pickup.request_id
	join dropoff
		on pickup.request_id = dropoff.request_id
	join DriverRating 
		on DriverRating.request_id = dropoff.request_id;

create view uniqueCD as 
select distinct client_id, driver_id from ratedclient;
/*
 client_id | driver_id 
-----------+-----------
       100 |     22222
        99 |     12345
        99 |     22222
*/


/*
select * from retedclient
 client_id | driver_id | request_id 
-----------+-----------+------------
        99 |     12345 |          1
       100 |     22222 |          2
       100 |     22222 |          3
       100 |     22222 |          4
        99 |     22222 |         10
*/
-- if i know the driver_id and client_id, 
-- need to make sure this one of the request_id is appeared in driverrating table



select client.client_id, client.email
from ratedclient join client 
on ratedclient.client_id = client.client_id
group by client.client_id, client.email;
