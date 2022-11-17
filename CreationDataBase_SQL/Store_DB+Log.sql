create table product (id serial primary key, name varchar, amount int, price int, id_store int, id_manufacturer int, id_sales_data int);
create table store (id serial primary key, name varchar);
create table sales_data (id serial primary key, amount int, date TIMESTAMP);
create table directory_cities (id serial primary key, name varchar);
create table manufacturer (id serial primary key, name varchar, city_id int);

select *from product
delete from product where id > 0

alter table manufacturer add constraint new_con foreign key (city_id) references directory_cities (id) on delete set null on update cascade;

alter table product add constraint prod_store foreign key (id_store) references store (id) on delete set null on update cascade;

alter table product add constraint prod_man foreign key (id_manufacturer) references manufacturer (id) on delete set null on update cascade;

alter table product add constraint prod_sale foreign key (id_sales_data) references sales_data (id) on delete set null on update cascade;


-- INSERT
insert into store values (1, 'store1'), (2, 'store2'), (3, 'store3'), (4, 'store4'), (5, 'store5'), (6, 'store6');

insert into directory_cities values (1, 'Novosibirsk'), (2, 'Biysk'), (3, 'Barnaul'), (4, 'Tomsk');

insert into manufacturer values (1, 'Orion', 1),  (2, 'Aroma', 2), (3, 'Plast', 3), (4, 'Mir', 4);


insert into sales_data values (1, 40, '2020-01-09 09:09:09');
insert into sales_data values (2, 60, '2021-01-09 09:09:09');
insert into sales_data values (3, 90, '2022-01-09 09:09:09');
insert into sales_data values (4, 40, '2020-01-09 09:09:09');
insert into sales_data values (5, 50, '2020-01-10 13:13:09'), (6, 60, '2020-01-10 12:01:09');
insert into sales_data values (7, 200, '2020-01-10 13:03:09'), (8, 80, '2020-01-10 02:02:09'), (9, 100, '2020-01-10 04:04:09');


insert into product values (1, 'Orange', 10, 30, 1, 1, 1),  (2, 'Coke', 20, 60, 2, 2, 2), (3, 'Water', 100, 50, 3, 3, 3), (4, 'Juice', 100, 70, 4, 4, 4 ); 
insert into product values (5, 'Milk', 300, 100, 1, 1, 5), (6, 'Bread', 400, 40, 2, 2, 6), (7, 'Apple', 300, 30, 3, 3, 7), (8, 'Egg', 300, 30, 3, 3, 8);


select *from manufacturer;
select *from sales_data;
select *from product;
select *from store;


-- Create functions
-- create some tables to create functions
create table day_type(type varchar primary key, start_time integer, end_time integer);
insert into day_type values ('night', 0, 4), ('morning', 5, 11), ('day', 12, 17), ('evening', 18, 23);
select *from day_type;

-- FUNCTIONS
create or replace function rating () returns setof product as 
$body$ 
declare r product%rowtype; 
begin 
for r in select *from product join sales_data on product.id_sales_data=sales_data.id 
where product.id>0 order by sales_data.amount DESC loop return next r; end loop; return; 
end 
$body$ 
language plpgsql;

create or replace function bill (varchar) returns integer as 
$body$ 
declare gr1 integer; gr2 integer; a integer; 
begin 
gr1:=(select start_time from day_type where type = $1); 
gr2:=(select end_time from day_type where type = $1); 
a:= (select avg(product.price*sales_data.amount) from product join sales_data on product.id_sales_data = sales_data.id 
where (extract(hour from sales_data.date))>=gr1 and (extract(hour from sales_data.date))<=gr2); return a; 
end 
$body$ 
language plpgsql;


create or replace function analysis (varchar) returns integer as 
$body$ 
declare a integer; 
begin 
if $1 = 'inside' then a:= (select sum(sales_data.amount) from product join sales_data on product.id_sales_data = sales_data.id 
join manufacturer on product.id_manufacturer = manufacturer.id join directory_cities on manufacturer.city_id = directory_cities.id 
where directory_cities.name = 'Novosibirsk'); elsif $1 = 'outside' then a:= (select sum(sales_data.amount) from product 
join sales_data on product.id_sales_data = sales_data.id join manufacturer on product.id_manufacturer = manufacturer.id 
join directory_cities on manufacturer.city_id = directory_cities.id where directory_cities.name != 'Novosibirsk'); else a:=0; end if; 
return a; 
end 
$body$ 
language plpgsql;

select rating()
select *from bill('day')
select analysis('inside')


-- Creating a Log
CREATE TABLE logs (
tablename varchar(32) NOT NULL,
operation varchar(32) NOT NULL,
record_value text NOT NULL,
addition_time timestamp NOT NULL,
username varchar(32) NOT NULL );

--Now we will create some functions and triggers which will track the operations with our tables and will insert information about that in log
-- directory_city table
create function directory_city_log () returns trigger as
$$
declare
rec text;
begin
if(tg_op = 'DELETE') then
rec := format('id = %s, name = %s', old.id, old.name);
elsif (tg_op = 'INSERT') then
rec := format('id = %s, name = %s', new.id, new.name);
elsif (tg_op = 'UPDATE') then
rec := format('(id = %s, name = %s) to (id = %s, name = %s)', old.id, old.name, new.id, new.name);
elsif (tg_op = 'TRUNACTE') then
rec := 'truncate table';
end if;

insert into logs (tablename, operation, record_value, addition_time, username) values ('directory_cities', tg_op, rec, current_timestamp, current_user);
return null;
end
$$
language plpgsql;

create trigger directory_cities_trigger after insert or update or delete on directory_cities
for each row
execute procedure directory_city_log();

create trigger directory_cities_truncate_trigger after truncate on directory_cities for statement execute procedure directory_city_log ();


-- store table
create function store_log () returns trigger as
$$
declare
rec text;
begin
if(tg_op = 'DELETE') then
rec := format('id = %s, name = %s', old.id, old.name);
elsif (tg_op = 'INSERT') then
rec := format('id = %s, name = %s', new.id, new.name);
elsif (tg_op = 'UPDATE') then
rec := format('(id = %s, name = %s) to (id = %s, name = %s)', old.id, old.name, new.id, new.name);
elsif (tg_op = 'TRUNCATE') then
rec := 'truncate table';
end if;
insert into logs (tablename, operation, record_value, addition_time, username) values ('store', tg_op, rec, current_timestamp, current_user);
return null;
end
$$
language plpgsql;

create trigger store_trigger after insert or update or delete on store
for each row
execute procedure store_log();

create trigger store_truncate_trigger after truncate on store for statement execute procedure store_log ();


-- maufacturer table
create function manufacturer_log () returns trigger as
$$
declare
rec text;
begin
if(tg_op = 'DELETE') then
rec := format('id = %s, name = %s, city_id = %s', old.id, old.name, old.city_id);
elsif (tg_op = 'INSERT') then
rec := format('id = %s, name = %s, city_id = %s', new.id, new.name, new.city_id);
elsif (tg_op = 'UPDATE') then
rec := format('(id = %s, name = %s, city_id = %s) to (id = %s, name = %s, city_id = %s )', old.id, old.name, old.city_id,  new.id, new.name, new.city_id);
elsif (tg_op = 'TRUNCATE') then
rec := 'truncate table';
end if;
insert into logs (tablename, operation, record_value, addition_time, username) values ('manufacturer', tg_op, rec, current_timestamp, current_user);
return null;
end
$$
language plpgsql;

create trigger manufacturer_trigger after insert or update or delete on manufacturer
for each row
execute procedure manufacturer_log();

create trigger manufacturer_truncate_trigger after truncate on manufacturer for statement execute procedure manufacturer_log ();


-- sales_data table
create function sales_data_log () returns trigger as
$$
declare
rec text;
begin
if(tg_op = 'DELETE') then
rec := format('id = %s, amount = %s, date = %s', old.id, old.amount, old.date);
elsif (tg_op = 'INSERT') then
rec := format('id = %s, amount = %s, date = %s', new.id, new.amount, new.date);
elsif (tg_op = 'UPDATE') then
rec := format('(id = %s, amount = %s, date = %s) to (id = %s, amount = %s, date = %s )', old.id, old.amount, old.date,  new.id, new.amount, new.date);
elsif (tg_op = 'TRUNCATE') then
rec := 'truncate table';
end if;
insert into logs (tablename, operation, record_value, addition_time, username) values ('sales_data', tg_op, rec, current_timestamp, current_user);
return null;
end
$$
language plpgsql;

create trigger sales_data_trigger after insert or update or delete on sales_data
for each row
execute procedure sales_data_log();

create trigger sales_data_truncate_trigger after truncate on sales_data for statement execute procedure sales_data_log (); 


-- product table
create function product_log () returns trigger as
$$
declare
rec text;
begin
if(tg_op = 'DELETE') then
rec := format('id = %s, name = %s, amount = %s, price = %s, id_store = %s, id_manufacturer = %s, id_sales_data = %s', 
			  old.id, old.name ,old.amount, old.price, old.id_store, old.id_manufacturer, old.id_sales_data);
elsif (tg_op = 'INSERT') then
rec := format('id = %s, name = %s, amount = %s, price = %s, id_store = %s, id_manufacturer = %s, id_sales_data = %s', 
			  new.id, new.name ,new.amount, new.price, new.id_store, new.id_manufacturer, new.id_sales_data);
elsif (tg_op = 'UPDATE') then
rec := format('(id = %s, name = %s, amount = %s, price = %s, id_store = %s, id_manufacturer = %s, id_sales_data = %s) 
			  to (id = %s, name = %s, amount = %s, price = %s, id_store = %s, id_manufacturer = %s, id_sales_data = %s)', 
			  old.id, old.name ,old.amount, old.price, old.id_store, old.id_manufacturer, old.id_sales_data,  
			  new.id, new.name ,new.amount, new.price, new.id_store, new.id_manufacturer, new.id_sales_data);
elsif (tg_op = 'TRUNCATE') then
rec := 'truncate table';
end if;                                                                                                                                                           
insert into logs (tablename, operation, record_value, addition_time, username) 
values ('product', tg_op, rec, current_timestamp, current_user);                   
return null;
end
$$
language plpgsql;

create trigger product_trigger after insert or update or delete on product
for each row
execute procedure product_log();

create trigger product_truncate_trigger after truncate on product for statement execute procedure product_log (); 


-- Some inserts for tasting log
insert into sales_data values (10, 200, '2020-02-10 13:05:09'), (11, 90, '2020-01-10 10:10:09'), (12, 30, '2020-01-10 11:04:09')
insert into sales_data values (13, 50, '2020-04-10 21:05:09'), (14, 90, '2020-04-10 22:10:09'), (15, 30, '2020-04-10 23:04:09')

insert into product values (9, 'Eggplant', 100, 100, 4, 4, 9), (10, 'Sugar', 500, 200, 1, 1, 10), (11, 'Fish', 255, 345, 2, 2, 11), (12, 'Pasta', 500, 80, 3, 3, 12);
insert into product values (13, 'Donut', 30, 50, 4, 4, 13), (14, 'Sweets', 500, 250, 1, 1, 14), (15, 'Melon', 10, 400, 2, 2, 15);
insert into store values (7, 'store7'), (8, 'store8'), (9, 'store9'), (10, 'store10');

select *from logs
