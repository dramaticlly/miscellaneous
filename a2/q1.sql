
SET search_path TO uber, public;

drop view if exists c cascade;
drop view if exists ans cascade;


create view c as 
	SELECT client.client_id, client.email, request_id
	FROM client LEFT JOIN request  
	ON client.client_id = request.client_id ;

-- select * from c;
-- select datetime from dispatch;

create view ans as
	select client_id,email,count(DISTINCT to_char(datetime,'mm/yy')) as months
	from dispatch right join c
	on dispatch.request_id = c.request_id
	group by client_id,email
	order by months desc;

select * from ans;
/*
//rv1
select client_id,email,count(to_char(datetime,'mm/yy')) as months 
from dispatch join c
on dispatch.request_id = c.request_id
group by client_id,email
order by months desc;

 client_id |          email          | months 
-----------+-------------------------+--------
       100 | dowager@dower-house.org |      7
        99 | daisy@kitchen.com       |      1


//rv2
select client_id,email,count(to_char(datetime,'mm/yy')) as months
from dispatch join c
on dispatch.request_id = c.request_id
group by client_id,to_char(datetime,'mm/yy'),email
order by months desc;

 client_id |          email          | months 
-----------+-------------------------+--------
       100 | dowager@dower-house.org |      3
       100 | dowager@dower-house.org |      3
       100 | dowager@dower-house.org |      1
        99 | daisy@kitchen.com       |      1

*/

