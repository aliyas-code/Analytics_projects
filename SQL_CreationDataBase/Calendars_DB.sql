-- Creation DB Calendar Store
create table calendar(
id serial primary key,
type_id integer,
manufacturer_id integer,
price real,
date_of_sale date);

create table manufacturer(
id serial primary key,
name varchar,
city_id integer);

create table handbook_cities(
id serial primary key,
name varchar);

create table handbook_types(
id serial primary key,
name varchar);

alter table calendar add column amount_sold int;

-- Inserts
insert into calendar values (11, 3, 2, 103, now(), 5);
insert into calendar values (12, 4, 2, 140, now(), 13);
insert into calendar values (13, 5, 5, 128, '2021-10-02', 24);
insert into calendar values (14, 3, 7, 158, '2021-11-02', 18);
insert into calendar values (15, 2, 1, 197, '2021-12-03', 30);

insert into handbook_types values (1, 'quarterly calendar'), (2, 'wall calendar'), (3, 'poster calendar'), (4, 'desk calendar'), (5, 'pocket calendar');
insert into handbook_types values (6, 'interesting calendar');
insert into handbook_types values (9, 'new_type');

insert into handbook_cities values (1, 'Moscow'), (2, 'Novosibirsk'), (3, 'Berdsk'), (4, 'Barnaul'), (5, 'Yekaterinburg');

insert into manufacturer values (1, 'Rubicon', 1), (2, 'Granit', 2), (3, 'Bizone', 3), (4, 'Kvakpak', 4), (5, 'Karandashok', 5), (6, 'Kalendariki', 2), (7, 'Shtrikh', 4);


-- Some functions
-- General table for each calendar
create or replace function general_table() 
returns table (id integer, type varchar, manufacturer varchar, price real, date_sell date) as
$$
begin                                                                                                                         
return query                                                                                                                  
select calendar.id, handbook_types.name, manufacturer.name, calendar.price, calendar.date_of_sale from calendar join manufacturer on calendar.manufacturer_id = manufacturer.id join handbook_types on calendar.type_id = handbook_types.id;                
end                                                                                                                           
$$                                                                                                                            
language plpgsql;

-- Sorting calendars by date of sale
create or replace function sort_by_date() returns table (id integer, type varchar, date_sell date) as $$                                                                                                                            
begin                                                                                                                         
return query                                                                                                                  
select calendar.id, handbook_types.name, calendar.date_of_sale from calendar join handbook_types on calendar.type_id = handbook_types.id order by calendar.date_of_sale;
end                                                                                                                           
$$                                                                                                                           
language plpgsql;

-- Sort by manufacturer
create or replace function sort_by_manufacturer() returns table (id integer, type varchar, manufacturer varchar) as $$                                                                                                                            
begin                                                                                                                         
return query                                                                                                                  
select calendar.id, handbook_types.name, manufacturer.name from calendar join manufacturer on calendar.manufacturer_id = manufacturer.id join handbook_types on calendar.type_id = handbook_types.id order by manufacturer.name;                            
end                                                                                                                           
$$                                                                                                                           
language plpgsql;

-- Sort by price
create or replace function sort_by_price() returns table (id integer, type varchar, price real)
as $$                                                                                                                            
begin                                                                                                                         
return query                                                                                                                  
select calendar.id, handbook_types.name, calendar.price from calendar join handbook_types on calendar.type_id = handbook_types.id order by calendar.price;                                                                                                  
end                                                                                                                           
$$                                                                                                                            
language plpgsql;


-- Finding the most expensive calendar
create or replace function max_cost() returns table (id integer, type varchar, price real) 
as $$                                                                              
begin                                                                           
return query                                                                    
select calendar.id, handbook_types.name, calendar.price from calendar join handbook_types on calendar.type_id = handbook_types.id where calendar.price = (select max(calendar.price) from calendar);                                            
end                                                                             
$$                                                                             
language plpgsql;


-- Finding the cheapest calendar
create or replace function min_cost() returns table (id integer, type varchar, price real) as                                                             $$                                                                              
begin                                                                           
return query                                                                    
select calendar.id, handbook_types.name, calendar.price from calendar join handbook_types on calendar.type_id = handbook_types.id where calendar.price = (select min(calendar.price) from calendar);                                            
end                                                                             
$$                                                                              
language plpgsql;

-- Finding average price for each type of calendar
create or replace function avg_cost_types() returns table (type varchar, avg double precision) as
$$
begin return query
select handbook_types.name, avg(calendar.price) from calendar join handbook_types on calendar.type_id = handbook_types.id group by handbook_types.name;
end
$$
language plpgsql;


-- Finding average price for all calendars
create or replace function avg_cost() returns float4 as                  
$$                                                                              
begin 
return(select avg(calendar.price) as average_price from calendar);        
end                                                                             
$$                                                                              
language plpgsql;


-- Finding all calnedars with price within specified limits for each type of calendar and for all
-- When one input variable
create or replace function price_limits(a real) returns table (id integer, type varchar, price real) as
$$
begin
return query
select calendar.id, handbook_types.name, calendar.price from calendar join handbook_types on calendar.type_id = handbook_types.id where calendar.price > a; 
end
$$
language plpgsql; 


-- When two input variables
create or replace function price_limits(a real, b real) returns table (id integer, type varchar, price real) as
$$                                                                                                
begin                                                                                              
return query                                                                                      
select calendar.id, handbook_types.name, calendar.price from calendar join handbook_types on calendar.type_id = handbook_types.id where calendar.price > a and calendar.price < b;
end               
$$                                                                                                 
language plpgsql;



-- Finding all calendars of a specifying manufacturer
create or replace function find_man(man varchar) returns table (id integer, type varchar, manufacturer varchar) as
$$
begin
return query
select calendar.id, handbook_types.name, manufacturer.name from calendar join handbook_types on calendar.type_id = handbook_types.id join manufacturer on calendar.manufacturer_id = manufacturer.id where manufacturer.name = man;
end
$$
language plpgsql;


-- Finding a ratio between cheap calnedars and all calendars
create or replace function percent_cheap(a real)
returns real
as
$$
begin
return ((select count(*)::real from calendar where price < a)/(select count(*)::real from calendar) * 100);
end
$$
language plpgsql;


-- Finding all calendars with specifying date of sale
create or replace function find_date(date) returns table (id integer, type varchar, sell_date date) as
$$
begin
return query
select calendar.id, handbook_types.name, calendar.date_of_sale from calendar join handbook_types on calendar.type_id = handbook_types.id where calendar.date_of_sale = $1;
end
$$
language plpgsql


-- Finding the proportion of sold calendars in specifying period of time of general sale time
create or replace function percent_date(date, date)
returns real
as
$$
begin
return ((select sum(amount_sold)::real from calendar where date_of_sale > $1 and date_of_sale < $2)/(select sum(amount_sold)::real from calendar) * 100);
end
$$
language plpgsql;


-- Finding the most popular calendar
create or replace function most_popular() returns table (id integer, type varchar, amount_sold integer) as
$$
begin
return query
select calendar.id, handbook_types.name, calendar.amount_sold from calendar join handbook_types on calendar.type_id = handbook_types.id where calendar.amount_sold = (select max(calendar.amount_sold) from calendar);
end
$$
language plpgsql;



-- Finding all calendars, which went on sale from specifying manufacturer, which price more then the average price of calendars, wich went from specifying city
create or replace function find_calendar(man varchar, city varchar)
returns table (id integer, type varchar, manufacturer varchar, price real, avg_price real) as
$$
declare
a real;
begin
a:= (select avg(calendar.price) from calendar join manufacturer on calendar.manufacturer_id = manufacturer.id join handbook_cities on manufacturer.city_id = handbook_cities.id where handbook_cities.name = city);
return query
select calendar.id, handbook_types.name, manufacturer.name, calendar.price, a from calendar join handbook_types on calendar.type_id = handbook_types.id join manufacturer on calendar.manufacturer_id = manufacturer.id where manufacturer.name = man and calendar.price > a;
end
$$
language plpgsql;


-- Finding the proportion of cheap calendars of all calendars
create or replace function percent_expensive_calendar(integer, varchar)
returns real
as
$$
declare max real;
begin
max := (select count(*) from calendar);
return ((select count(*) from calendar join manufacturer on calendar.manufacturer_id = manufacturer.id join handbook_cities on manufacturer.city_id = handbook_cities.id where calendar.price > $1 and handbook_cities.name = $2)/max*100);
end
$$
language plpgsql;


-- Finding the average price of calendars, which was sold within specified period of time
create or replace function average_cost_date(date, date)
returns real
as
$$
begin
return (select avg(price) from calendar where date_of_sale > $1 and date_of_sale < $2);
end
$$
language plpgsql;


-- Finding all calendars, which price higher than the average price of calendars of specifying manufacturer
create or replace function expensive_calendars(varchar)
returns table(id integer, type varchar, price real, avg_price real, manufacturer varchar) as
$$
declare
sup real;
begin
sup := (select avg(calendar.price) from calendar join manufacturer on calendar.manufacturer_id = manufacturer.id where manufacturer.name = $1);
return query
select calendar.id, handbook_types.name, calendar.price, sup, manufacturer.name from calendar join handbook_types on calendar.type_id = handbook_types.id join manufacturer on calendar.manufacturer_id = manufacturer.id where calendar.price > sup and manufacturer.name != $1;
end
$$
language plpgsql;


-- Finding the amount of sales for month, quarter, year. And finding thhe average price, the most expeensive calendar, the cheapiest calendar withhin this period of time
create or replace function last_function(varchar)
returns table (volume_of_sales real, avg real, min_calendar_id integer, max_aclendar_id integer) as
$$
declare
min integer;
max integer;
volume real;
avg_sale real;
sup integer;
begin
if $1 = 'month' then sup:= 1;
elseif $1  = 'quarter' then sup:= 3;
elseif $1  = 'year' then sup:= 12;
else sup:=0;
end if;
volume:=(select sum(amount_sold) from calendar where now()-date_of_sale <= sup*interval '1 month');
avg := (select avg(price) from calendar where now()-date_of_sale <= sup*interval '1 month'); 
max := (select id from calendar where price = (select max(price) from calendar where now()-date_of_sale <=sup*interval '1 month'));                                                             
min := (select id from calendar where price = (select min(price) from calendar where now()-date_of_sale <=sup*interval '1 month'));                                                             
return query                                                                                    
select volume, avg, max, min;  
end                                                              
$$                                                                                              
language plpgsql;


select *from general_table();

Select *from sort_by_date();

Select *from sort_by_manufacturer();

Select *from sort_by_price();

Select *from max_cost();

Select *from min_cost();

Select *from avg_cost_types();

Select *from avg_cost();

Select *from price_limits(100);

Select *from price_limits(100, 140);

Select *from find_man('Granit');

Select *from percent_cheap(151);

Select *from find_date('2021-01-10');

Select *from percent_date('2020-12-13', '2021-05-02');

Select *from most_popular();

Select *from find_calendar('Kalendariki', 'Barnaul');

Select *from percent_expensive_calendar(120, 'Novosibirsk');

Select *from average_cost_date('2021-02-09', '2021-08-23');

Select *from expensive_calendars('Granit');

Select *from last_function('month');

Select *from last_function('quarter');

Select *from last_function('year');






