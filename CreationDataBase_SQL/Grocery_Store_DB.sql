-- Creation tables

CREATE TABLE directory_products (
	id serial PRIMARY KEY,
	name_type varchar NOT NULL
);

select *from directory_products

CREATE TABLE directory_cities (
	id serial PRIMARY KEY,
	name_city varchar NOT NULL
);

CREATE TABLE manufacturer (
	id serial PRIMARY KEY,
	name_manufacturer varchar NOT NULL,
	city_id integer,
	FOREIGN KEY (city_id) REFERENCES directory_cities (id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE product (
	id serial PRIMARY KEY,
	name_product varchar NOT NULL,
	type_id integer,
	manufacturer_id integer,
	amount integer NOT NULL,
	purchase_price integer NOT NULL,
	
	FOREIGN KEY (type_id) REFERENCES directory_products (id) ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (manufacturer_id) REFERENCES manufacturer (id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE sale (
	price integer NOT NULL,
	amount integer NOT NULL,
	product_id integer,
	
	FOREIGN KEY (product_id) REFERENCES product (id) ON DELETE SET NULL ON UPDATE CASCADE
);

INSERT INTO directory_cities (id, name_city) VALUES 
(1, 'Novosibirsk'), 
(2, 'Moscow'), 
(3, 'Barnaul'), 
(4, 'Saint Petersburg'), 
(5, 'Yekaterinburg'), 
(6, 'Ivanovo'), 
(7, 'Izhevsk'), 
(8, 'Irkutsk'), 
(9, 'Kazan'), 
(10, 'Kaliningrad'); 

INSERT INTO directory_products (id, name_type) VALUES 
(1, 'Fruits'), 
(2, 'Clothes'), 
(3, 'Shoes'), 
(4, 'Drinks'),
(5, 'Deviсes'),
(6, 'Type_6'),
(7, 'Type_7'),
(8, 'Type_8'),
(9, 'Type_9'),
(10, 'Type_10'); 


INSERT INTO manufacturer (id, name_manufacturer, city_id) VALUES 
(1, 'MA', 1),
(2, 'MP', 2),
(3, 'ZARA', 3),
(4, 'LEVIS', 4),
(5, 'Nike', 5),
(6, 'Greenfield', 6),
(7, 'Arabic', 7),
(8, 'Apple', 8),
(9, 'Mi', 9),
(10, 'Samsung', 10); 


INSERT INTO product (id, name_product, type_id, manufacturer_id, amount, purchase_price) VALUES 
(1, 'Apple', 1, 1, 1000, 30),
(2, 'Pineapple', 1, 2, 1000, 100),
(3, 'T-shirt', 2, 3, 50, 1500),
(4, 'Jeans', 2, 4, 30, 2000),
(5, 'Sneakers', 3, 5, 35, 4000),
(6, 'Tea', 4, 6, 200, 70),
(7, 'Coffee', 4, 7, 200, 90),
(8, 'iPhone', 5, 8, 10,  100000),
(9, 'Xiaomi redmi', 5, 9, 10,  15000),
(10, 'Samsung galaxy', 5, 10, 10, 50000); 


INSERT INTO sale (price, amount, product_id) VALUES 
(40, 1000, 1),
(110, 800, 2),
(2000, 10, 3),
(3000, 9, 4),
(10000, 3, 5),
(75, 200, 6),
(95, 200, 7),
(130000, 2, 8),
(12000, 10, 9),
(60000, 5, 10); 

CREATE TABLE main_information AS 
SELECT product.name_product, directory_products.name_type, manufacturer.name_manufacturer, directory_cities.name_city, sale.price 
FROM product JOIN directory_products ON directory_products.id = product.type_id JOIN sale ON product.id = sale.product_id JOIN manufacturer ON manufacturer.id = product.manufacturer_id JOIN directory_cities ON directory_cities.id = manufacturer.id;

select *from main_information;


-- Delete some rows before using constraints
delete from sale where price > 15000 or price < 10;
delete from product where purchase_price > 15000;
delete from product where type_id > 3;

--Constraints
alter table sale add check (price >= 10 and price < 15000);

alter table product add check (purchase_price >= 10);

alter table product add check (purchase_price <= 15000);

alter table sale add check (amount>=0);

alter table product add purchase_date date;

alter table product add check (purchase_date <= now());

alter table product add check(type_id = 1 or type_id = 2 or type_id = 3); 


-- Queries
select max(purchase_price) from product where type_id=1;

select min(purchase_price) from product where manufacturer_id = 4;

select avg(purchase_price) from product where manufacturer_id=1;

select count(*) from product where manufacturer_id = 2;

select sum(purchase_price) from product where manufacturer_id = 4;


-- Working with massives and transaction
begin;
create table new_manufacturer (id serial primary key, name varchar NOT NULL, city varchar[]);
insert into new_manufacturer values (1,'man_1', '{"Moscow", "Novosibirsk", "Ekaterinburg"}');
insert into new_manufacturer values (2,'man_2', '{"Moscow", "Novosibirsk", "Ekaterinburg", "Volgograd"}');
insert into new_manufacturer values (3,'man_3', '{"Moscow", "Saint Petersburg", "Ekaterinburg"}');

select city[1] from new_manufacturer;

select city[4] from new_manufacturer where city[4] is not null;

select city[1:3] from new_manufacturer;

select array_dims(city) from new_manufacturer;

update new_manufacturer set city='{"Moscow", "Barnaul", "Biysk"}' where id = 2;

update new_manufacturer set city[1]='Biysk' where id = 1;

create table new_product (comment varchar) inherits (product);
rollback;


-- Queries with join
-- some changes before:
alter table directory_cities add country varchar;
update directory_cities set country = 'Russia' where id >0;
insert into directory_cities values (13, 'Mumbai', 'India');
insert into directory_cities values (14, 'Calcutta', 'India');
select *from manufacturer;
insert into manufacturer values (11, 'manufacturer_mumbai', 13);
insert into product values (14, 'flour_type2', 1, 8, 5000, 600, now());

insert into directory_cities values (11, 'Omsk', 'Russia');
insert into directory_cities values (12, 'Tomsk', 'Russia');
insert into manufacturer values (12, 'manufacturer_ommsk', 11);
insert into manufacturer values (13, 'manufacturer_tomsk', 12);
insert into product values (12, 'milk_type2', 2, 6, 1000, 300, now());
insert into product values (13, 'butter_type2', 2, 7, 500, 400, now());
insert into product values (6, 'butter', 1, 7, 500, 10000, now());
update product set purchase_price = 15000 where name_product = 'butter_type2';


select name_product from product 
where type_id = 1 and purchase_price > (select avg(purchase_price) 
from product join manufacturer on product.manufacturer_id = manufacturer.id 
join directory_cities on manufacturer.city_id = directory_cities.id where directory_cities.name_city = 'Moscow' and product.type_id = 1);

select name_product from product 
join manufacturer on product.manufacturer_id = manufacturer.id 
join directory_cities on manufacturer.city_id = directory_cities.id  
where (directory_cities.name_city = 'Novosibirsk' or directory_cities.name_city = 'Izhevsk') 
and type_id = 2 and purchase_price > (select avg(purchase_price) from product where purchase_date >= now() - interval '3 month');

select name_product from product 
where (purchase_date >= now() - interval '6 month') and purchase_price > (select avg(purchase_price) 
from product join manufacturer on product.manufacturer_id = manufacturer.id 
join directory_cities on manufacturer.city_id = directory_cities.id 
where directory_cities.country = 'Russia' or directory_cities.country = 'India');

-- Function
create function add_n(int) returns char as 'declare t int; begin select max(id) into t from directory_cities; for k in (t+1)..($1+t+1) loop insert into directory_cities(id, name_city, country) values(k, round(random()*10^12) || '' '' || round(random()*10^5), round(random()*10^12) || '' '' || round(random()*10^5)); end loop; return ''Done!''; end;' language 'plpgsql';

select add_n(1000); 

select *from directory_cities;


-- ANALYSIS
 EXPLAIN ANALYSE select * from directory_cities where id>500;
 EXPLAIN ANALYSE select * from directory_cities where id=500;
 EXPLAIN ANALYSE select * from directory_cities where id<500;
 EXPLAIN ANALYSE select * from directory_cities where id between 10 and 100;

-- Changing Indexes
-- Btree index
create index on directory_cities using btree(id);

EXPLAIN ANALYSE select * from directory_cities where id>500;
EXPLAIN ANALYSE select * from directory_cities where id=500;
EXPLAIN ANALYSE select * from directory_cities where id<500;
EXPLAIN ANALYSE select * from directory_cities where id between 10 and 100;

drop index directory_cities_id_idx;

-- Hash index
create index on directory_cities using hash(id);
EXPLAIN ANALYSE select * from directory_cities where id>500;
EXPLAIN ANALYSE select * from directory_cities where id=500;
EXPLAIN ANALYSE select * from directory_cities where id<500;
EXPLAIN ANALYSE select * from directory_cities where id between 10 and 100;

SELECT * FROM pg_indexes WHERE tablename = 'directory_cities';

drop index directory_cities_id_idx

-- Upper index
 EXPLAIN ANALYSE select * from directory_cities where upper(name_city) = 'MOSCCOW';
 EXPLAIN ANALYSE select * from directory_cities where upper(name_city) < 'MOSCCOW';
 EXPLAIN ANALYSE select * from directory_cities where upper(name_city) > 'MOSCCOW';
 EXPLAIN ANALYSE select * from directory_cities where upper(name_city) between 'MOSCCOW' and 'NOVOSIBIRSK';
 

-- In ways, when we need to process a lot of rows, 'Explayn' with indexes work in two times faster. 
-- But when we need process a few rows, the process without indexes is faster.
-- But if we tried to use it in practical, I think it would be useless.

 
-- Delete useless rows
delete from directory_cities where id > 14


-- Some queries
select name_product from product join sale on sale.product_id = product.id where sale.price-product.purchase_price > product.purchase_price*0.1;

select name_product from product join sale on sale.product_id = product.id;

select name_product from product join sale on sale.product_id = product.id join manufacturer on product.manufacturer_id = manufacturer.id 
where sale.amount > 25 and manufacturer.name_manufacturer = 'grocery_manufacturer';

select name_product from product join manufacturer on product.manufacturer_id = manufacturer.id 
join directory_cities on manufacturer.city_id = directory_cities.id 
where directory_cities.name_city = 'Moscow' and (purchase_date >= now() - interval '6 month');

select name_product from product join manufacturer on product.manufacturer_id = manufacturer.id 
join directory_cities on manufacturer.city_id = directory_cities.id where (type_id =2 or type_id = 3) and (directory_cities.name_city = 'Moscow' 
or directory_cities.name_city = 'Yekaterinburg') and (manufacturer.name_manufacturer = 'Sibir_agro' or manufacturer.name_manufacturer = 'grocery_manufacturer') 
