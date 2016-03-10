/*
insert into client values
(137,'Ella','Wang','ellawang@gmail.com'),
(138,'Sitong','Gui','gst@gmail.com');
*/

insert into driver values
(54321, '5Snow', '5Jon', 'January 5, 1995', '5The Wall', 'BGSW 520', false);

insert into request values
(11, 99, '2016-01-08 05:10', 'eaton centre', 'pearson international airport'),
(12, 100, '2016-01-08 04:50', 'eaton centre', 'pearson international airport');

insert into dispatch values
(11, 54321, '(1, 4)', '2016-01-08 05:11'),
(12, 54321, '(1, 4)', '2016-01-08 04:51');


insert into pickup values
(11, '2016-01-08 05:14'),
(12, '2013-02-01 05:06');

insert into dropoff values
(11, '2016-01-08 05:14'),
(12, '2013-02-01 05:16');

insert into driverrating values
(11,3);-- client 99 rate 54321, while client 100 does not