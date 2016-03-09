SET search_path TO uber, public;

drop view if exists c;

create view c as
SELECT client.client_id, client.email, request_id
FROM client LEFT JOIN request
ON client.client_id = request.client_id ;

-- select * from c;
-- select datetime from dispatch;

select client_id,email,count(DISTINCT to_char(datetime,'mm/yy')) as months
from dispatch right join c
on dispatch.request_id = c.request_id
group by client_id,email
order by months desc;

/*
//rv1
select client_id,email,count(to_char(datetime,'mm/yy')) as monthsfrom dispatch join c
on dispatch.request_id = c.request_id
group by client_id,email
order by months desc;

 client_id |          email          | months 
-----------+-------------------------+--------
       100 | dowager@dower-house.org |      7
        99 | daisy@kitchen.com       |      1


