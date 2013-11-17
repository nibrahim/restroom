CREATE TABLE ratings (
       userhash  varchar(40),
       package   varchar(100),
       rating    integer DEFAULT 0
);

select * from ratings;
