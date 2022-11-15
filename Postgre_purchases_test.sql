create database purchases;

CREATE TABLE Users (
	userId INTEGER PRIMARY KEY,
	age INTEGER 
);


CREATE TABLE Purchases(
	purchaseId INTEGER PRIMARY KEY,
	userId INTEGER,
	itemId INTEGER,
	purchase_date DATE
);

CREATE TABLE Items(
	itemId INTEGER PRIMARY KEY,
	price INTEGER
);

INSERT INTO Users (userId, age)
VALUES (001, 17),
(002, 20),
(003, 25),
(004, 30),
(005, 35),
(006, 36),
(007, 48);

INSERT INTO Purchases (purchaseId, userId, itemId, purchase_date)
VALUES (123, 001, 11, '2022-01-01'),
(234, 002, 22, '2022-02-02'),
(345, 003, 33, '2022-02-02'),
(456, 004, 44, '2022-04-04'),
(567, 005, 55, '2022-05-05'),
(678, 006, 33, '2022-05-04'),
(789, 007, 55, '2022-06-05'),
(453, 004, 44, '2021-04-04'),
(566, 005, 55, '2021-05-05'),
(671, 006, 33, '2021-05-04'),
(780, 007, 55, '2021-06-05');

INSERT INTO Items (itemId, price)
VALUES (11, 2800),
(22, 3900),
(33, 4580),
(44, 3000),
(55, 1000);


SELECT * FROM Users; 
SELECT * FROM purchases; 
SELECT * FROM items; 


-- А) какую сумму в среднем в месяц тратит:
-- - пользователи в возрастном диапазоне от 18 до 25 лет включительно
-- - пользователи в возрастном диапазоне от 26 до 35 лет включительно

With A as 
(select p.userId, extract(month from p.purchase_date) as mnth, SUM(i.price) sum_price
from Purchases p
join Items i on p.itemId = i.itemId
join Users u on p.userId = u.userId
where age between 18 and 25
group by p.userId, extract(month from p.purchase_date))
Select avg(sum_price)
From A; 

With A as 
(select p.userId, extract(month from p.purchase_date) as mnth, sum(i.price) sum_price
from Purchases p
join Items i on p.itemId = i.itemId
join Users u ON p.userId = u.userId
where age between 26 and 35
group by p.userId, extract(month from p.purchase_date))
Select avg(sum_price)
From A; 

-- Б) в каком месяце года выручка от пользователей в возрастном диапазоне 35+ самая большая
With a as 
(select distinct extract(month from p.purchase_date), sum(price) sum_price
from Purchases p
join Items i on p.itemId = i.itemId
join Users u ON p.userId = u.userId
where u.age >= 35
Group by extract(month from p.purchase_date)
Order by extract(month from p.purchase_date) desc)
Select * 
From a
Limit 1 

-- В) какой товар обеспечивает дает наибольший вклад в выручку за последний год
select i.itemId, sum(price) sum_price
from Purchases p
join Items i on p.itemId = i.itemId
where date_part('year', p.purchase_date) = date_part('year', CURRENT_DATE)
Group by i.itemId
Order by sum_price  desc
limit 1 


-- Г) топ-3 товаров по выручке и их доля в общей выручке за любой год
with A as 
(select distinct i.itemId, extract(year from p.purchase_date) year_, sum(price) sum_price, 
	row_number() over (partition by extract(year from p.purchase_date) order by sum(price) desc)
from Purchases p
join Items i on p.itemId = i.itemId
Group by i.itemId, extract(year from p.purchase_date)
Order by sum_price desc),

B as 
(select A.year_, sum(sum_price) total_price from A 
group by A.year_)

select A.*, B.total_price,
	round(A.sum_price / B.total_price, 3)
from A 
left join B on A.year_ = B.year_
where row_number <= 3
order by A.year_, row_number asc;
