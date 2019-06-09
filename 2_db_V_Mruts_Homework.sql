USE master;

IF EXISTS(
	SELECT * FROM sys.databases
	WHERE name='V_MRUTS2'
	)
	DROP DATABASE V_MRUTS2;
GO

CREATE DATABASE V_MRUTS2;
GO

USE V_MRUTS2;
GO

------------Creating tables
create table [suppliers] (
	supplierid			integer,
	name				varchar(20),
	rating				integer,
	city				varchar(20),
	constraint supplr_pk PRIMARY KEY (supplierid)
);	

create table [details] (
	detailid			integer,
	name				varchar(20),
	color				varchar(20),
	weight				integer,
	city				varchar(20),
	constraint detail_pk PRIMARY KEY (detailid)
);	

create table [products] (
	productid			integer,
	name				varchar(20),
	city				varchar(20),
	constraint product_pk PRIMARY KEY (productid)
);		

create table [supplies] (
	supplierid			integer,
	detailid			integer,
	productid			integer,
	quantity			integer,
	constraint suppl_supplr_fk FOREIGN KEY (supplierid) REFERENCES suppliers (supplierid),
	constraint suppl_detail_fk FOREIGN KEY (detailid) REFERENCES details (detailid),
	constraint suppl_product_fk FOREIGN KEY (productid) REFERENCES products (productid),
);	


------------Inserting data
insert into suppliers(
	supplierid,
	name,
	rating,
	city
)
values
(1, 'Smith', 20, 'London'),
(2, 'Jonth', 10, 'Paris'),
(3, 'Blacke', 30, 'Paris'),
(4, 'Clarck', 20, 'London'),
(5, 'Adams', 30, 'Athens');

insert into details(
	detailid,
	name,
	color,
	weight,
	city
)
values
(1, 'Screw', 'red', 12, 'London'),
(2, 'Bolt', 'green', 17, 'Paris'),
(3, 'Male-screw', 'blue', 17, 'Roma'),
(4, 'Male-screw', 'red', 14, 'London'),
(5, 'Whell', 'blue', 12, 'Paris'),
(6, 'Bloom', 'red', 19, 'London');

insert into products(
	productid,
	name,
	city
)
values
(1, 'HDD', 'Paris'),
(2, 'Perforator', 'Roma'),
(3, 'Reader', 'Athens'),
(4, 'Printer', 'Athens'),
(5, 'FDD', 'London'),
(6, 'Terminal', 'Oslo'),
(7, 'Ribbon', 'London');

insert into supplies(
	supplierid,
	detailid,
	productid,
	quantity
	
)
values
(1, 1, 1, 200),
(1, 1, 4, 700),
(2, 3, 1, 400),
(2, 3, 2, 200),
(2, 3, 3, 200),
(2, 3, 4, 500),
(2, 3, 5, 600),
(2, 3, 6, 400),
(2, 3, 7, 800),
(2, 5, 2, 100),
(3, 3, 1, 200),
(3, 4, 2, 500),
(4, 6, 3, 300),
(4, 6, 7, 300),
(5, 2, 2, 200),
(5, 2, 4, 100),
(5, 5, 5, 500),
(5, 5, 7, 100),
(5, 6, 2, 200),
(5, 1, 4, 100),
(5, 3, 4, 200),
(5, 4, 4, 800),
(5, 5, 4, 400),
(5, 6, 4, 500);

---------Tasks
---[1]------
UPDATE suppliers
SET rating = rating + 10
WHERE rating < (SELECT rating FROM suppliers WHERE supplierid = 4);

---[2]------
SELECT productid
INTO london_product
FROM products
WHERE city = 'London' OR 
productid IN (
SELECT productid FROM supplies
INNER JOIN details ON supplies.detailid = details.detailid
WHERE details.city = 'London'
);

select * from london_product;

---[3]------
DELETE FROM products
WHERE productid NOT IN (
SELECT productid FROM supplies
INNER JOIN details ON supplies.detailid = details.detailid);

---[4]------
SELECT DISTINCT s1.supplierid, s1.detailid AS d1, s2.detailid AS d2 
INTO #sup_details
FROM supplies AS s1
INNER JOIN supplies AS s2
ON s1.supplierid = s2.supplierid
WHERE s1.detailid != s2.detailid AND s1.detailid > s2.detailid

---[5]------
UPDATE supplies
SET quantity = quantity + quantity * 0.1
WHERE supplierid IN 
(SELECT DISTINCT supplierid FROM supplies WHERE
detailid IN (SELECT detailid FROM details WHERE color = 'Red'));

---[6]------
SELECT DISTINCT color, city 
INTO color_city
FROM details;

SELECT * FROM color_city;

---[7]------
SELECT detailid 
INTO det_london
FROM details
WHERE detailid IN (SELECT DISTINCT detailid FROM supplies WHERE supplierid IN (SELECT supplierid FROM suppliers WHERE city = 'London'))
OR
detailid IN (SELECT DISTINCT detailid FROM supplies WHERE productid IN (SELECT productid FROM products WHERE city = 'London'));

---[8]------
insert into suppliers(
	supplierid,
	name,
	rating,
	city
)
values
(10, 'White', NULL, 'New-York');

---[9]------
DELETE s
FROM supplies AS s
INNER JOIN products AS p
  ON p.productid = s.productid
WHERE p.city = 'Roma';

DELETE FROM products WHERE city = 'Roma';

---[10]------
SELECT city FROM suppliers
UNION
SELECT city FROM products
UNION 
SELECT city FROM details
ORDER BY city ASC;

---[11]------
UPDATE details
SET color = 'yellow'
WHERE color = 'red' AND weight < 15;

---[12]------
SELECT detailid, city
INTO det_city_o
FROM details
WHERE city LIKE '_o%';

---[13]------
UPDATE suppliers
SET rating = rating + 10
WHERE supplierid IN
(SELECT s FROM(
SELECT supplierid AS s, SUM(quantity) AS q
FROM supplies
WHERE quantity > (SELECT AVG(quantity) FROM supplies)
GROUP BY supplierid) AS d);

---[14]------
SELECT supplierid, name
INTO suppl_product_1
FROM suppliers
WHERE supplierid IN (SELECT supplierid FROM supplies WHERE productid = 1);

---[15]------
INSERT INTO suppl_product_1 VALUES
(9, 'Mruts'),
(12, 'Surename');

---------Merge tasks
---[1]------
SELECT *
INTO tmp_details
FROM details
WHERE 1 = 2

INSERT INTO tmp_details (detailid, name, color, weight, city) 
VALUES 
(1, 'Screw', 'Blue', 13, 'Osaka'),
(2, 'Bolt', 'Pink', 12, 'Tokio'),
(18, 'Whell-24', 'Red', 14, 'Lviv'),
(19, 'Whell-28', 'Pink',  15, 'London');

---[2]------
SELECT * FROM details;
SELECT * FROM tmp_details;


MERGE details AS d
USING (SELECT detailid, name, color, weight, city FROM tmp_details
	) AS td(detailid, name, color, weight, city)
ON (d.detailid = td.detailid)

WHEN MATCHED THEN
	UPDATE SET d.color = td.color, d.weight = td.weight, d.city = td.city
WHEN NOT MATCHED THEN
	INSERT (detailid, name, color, weight, city) VALUES (td.detailid, td.name, td.color, td.weight, td.city);