-- Lookup Tables
CREATE TABLE dbo.PLACEMENTS (
Placement Varchar (30) not null PRIMARY KEY
)
INSERT INTO PLACEMENTS
VALUES ('Left Chest'), ('Front Adult'), ('Front Youth'), ('Back Adult'), ('Back Youth'), ('Sleeve
Standard'), ('Sleeve Stacked'), ('Hood Standard'), ('Hood Side'), ('Leg Stacked'), ('Leg
Sentenced')

CREATE TABLE dbo.COLORS (
Colors Varchar (20) not null PRIMARY KEY
)
INSERT INTO COLORS
VALUES ('Red'), ('Grey'), ('TieDye'), ('Pink'), ('Purple'), ('Black'), ('Blue'), ('Green'),
('Turquoise'), ('Yellow')
CREATE TABLE dbo.PURCHASE_TYPES (
Type Varchar (20) not null PRIMARY KEY
)

INSERT INTO PURCHASE_TYPES
VALUES ('Group Order'), ('Individual Order'), ('Fundraising')
CREATE TABLE dbo.SIZES (
Size Varchar (6) not null PRIMARY KEY
)
INSERT INTO SIZES
VALUES ('XS'), ('S'), ('M'), ('L'), ('XL'), ('XXL'), ('XXXL'), ('XXXXL')

CREATE TABLE dbo.SHIPPING_AREAS (
ShippingArea Varchar (20) not null PRIMARY KEY
)
INSERT INTO SHIPPING_AREAS
VALUES ('US'), ('CANADA'), ('INTERNATIONAL')
CREATE TABLE dbo.DELIVERY_OPTIONS (
DeliveryOption Varchar (20) not null PRIMARY KEY
)
INSERT INTO DELIVERY_OPTIONS
VALUES ('Standard'), ('Rush')

-- Tables
CREATE TABLE dbo.PRODUCTS (
ProductID Integer not null,
Brand Varchar (20) null,
Type Varchar (20) null,
Style Varchar (20) null,
Color Varchar (20) null,
Size Varchar (6) null,
Fabric Varchar (20) null,
MinQuantity Integer null default 1,
Price Money null,

CONSTRAINT PK_PRODUCTS PRIMARY KEY
(ProductID),
CONSTRAINT CK_MinQuantity CHECK (MinQuantity >=0),
CONSTRAINT FK_PRODUCTS_COLORS FOREIGN KEY (Color) REFERENCES
COLORS (Colors),
CONSTRAINT FK_PRODUCTS_SIZES FOREIGN KEY (Size) REFERENCES
SIZES (Size),
)

CREATE TABLE dbo.CARTS (
CartID Integer not null,
ShippingArea Varchar (20) null,
DeliveryOption Varchar (20) null,

CONSTRAINT PK_CARTS PRIMARY KEY (CartID),
CONSTRAINT FK_CARTS_SHIPPING FOREIGN KEY (ShippingArea)
REFERENCES SHIPPING_AREAS (ShippingArea),
CONSTRAINT FK_CARTS_DELIVERY FOREIGN KEY (DeliveryOption)
REFERENCES DELIVERY_OPTIONS (DeliveryOption)
)
CREATE TABLE dbo.CUSTOMERS (
EmailAddress Varchar (40) not null,
PhoneNumber Varchar (20) not null,
Name Varchar (20) null,
Gender Varchar (2) null,
Country Varchar (20) null,
City Varchar (30) null,
Street Varchar (30) null,
[CC - Number] Varchar (16) not null,
[CC - CVC] Varchar (3) not null,
[CC - ExpirationDate] Date not null,
CONSTRAINT PK_CUSTOMERS PRIMARY KEY (EmailAddress),
CONSTRAINT CK_Email CHECK (EmailAddress LIKE '%@%.%'),
CONSTRAINT CK_CC_NUMBER CHECK ([CC - Number] LIKE '[0-9][0-9][0-9][0-9][0-
9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
CONSTRAINT CK_CC_CVC CHECK ([CC - CVC] LIKE '[0-9][0-9][0-9]'),
CONSTRAINT AK_CC UNIQUE ([CC - Number], [CC - CVC], [CC - ExpirationDate]),
CONSTRAINT AK_PHONE UNIQUE (PhoneNumber)
)

CREATE TABLE dbo.ORDERS (
OrderID Integer not null,

DT Date not null,
PurchaseType Varchar (20) null,
TrackingNumber Integer not null,
CartID Integer null,
EmailAddress Varchar (40) not null,
CONSTRAINT PK_ORDERS PRIMARY KEY (OrderID),
CONSTRAINT AK_DT_EMAIL UNIQUE (DT, EmailAddress),
CONSTRAINT AK_TRACKING_NUMBER UNIQUE (TrackingNumber),
CONSTRAINT FK_CartID FOREIGN KEY (CartID) REFERENCES CARTS (CartID),
CONSTRAINT FK_EMAIL FOREIGN KEY (EmailAddress) REFERENCES
CUSTOMERS (EmailAddress),
CONSTRAINT FK_ORDERS_PURCHASE FOREIGN KEY (PurchaseType)
REFERENCES PURCHASE_TYPES (Type)
)
CREATE TABLE dbo.USERS (
[IP Address] Varchar (40) not null,
EntranceDT DateTime null,
EmailAddress Varchar (40) null,

CONSTRAINT PK_USERS PRIMARY KEY ([IP Address]),
CONSTRAINT CK_USERS_IP CHECK ((ParseName([IP Address], 4) BETWEEN 0
AND 255)

AND (ParseName([IP Address], 3) BETWEEN 0

AND 255)

AND (ParseName([IP Address], 2) BETWEEN 0

AND 255)

AND (ParseName([IP Address], 1) BETWEEN 0

AND 255)),
CONSTRAINT FK_USERS_EMAIL FOREIGN KEY (EmailAddress) REFERENCES
CUSTOMERS (EmailAddress)
)
CREATE TABLE dbo.DESIGNS (
DesignID Integer not null,
Name Varchar (20) null,
Art Varchar (200) null,

FontStyle Varchar (20) null,
Text Varchar (150) null,
Color Varchar (20) null,
[IP Address] Varchar (40) null,

CONSTRAINT PK_DESIGNS PRIMARY KEY (DesignID),
CONSTRAINT FK_DESIGNS_IP FOREIGN KEY ([IP Address]) REFERENCES
USERS ([IP Address]),
CONSTRAINT FK_DESIGNS_COLOR FOREIGN KEY (Color) REFERENCES
COLORS (Colors)
)
CREATE TABLE dbo.DESIGNED_PRODUCTS (
ProductID Integer not null,
DesignID Integer not null,
Placement Varchar (30) not null,
CartID Integer null,
Quantity Integer null,

CONSTRAINT PK_DESIGNED_PRODUCTS PRIMARY KEY
(ProductID, DesignID, Placement),
CONSTRAINT FK_DESIGNED_PRODUCT_PRODUCT FOREIGN KEY (ProductID)
REFERENCES PRODUCTS (ProductID),
CONSTRAINT FK_DESIGNED_PRODUCT_DESIGN FOREIGN KEY (DesignID)
REFERENCES DESIGNS (DesignID),
CONSTRAINT FK_DESIGNED_PRODUCT_PLACEMENT FOREIGN KEY
(Placement) REFERENCES PLACEMENTS (Placement),
CONSTRAINT FK_DESIGNED_PRODUCT_CART FOREIGN KEY (CartID)
REFERENCES CARTS (CartID)
)
--PART 3
select P.Type, Popularity = count (P.Type)
from PRODUCTS as P JOIN DESIGNED_PRODUCTS as DP

on P.ProductID= DP.ProductID JOIN ORDERS as O
on DP.CartID = O.CartID

where P.Type is not null
group by P.Type
order by Popularity desc

select P.Brand, P.ProductID, P.Type , NumOfOrders = count (P.ProductID)
from PRODUCTS as P JOIN DESIGNED_PRODUCTS as DP

on P.ProductID= DP.ProductID JOIN ORDERS as O
on DP.CartID = O.CartID
where P.Type = 'Jackets&Vests'
group by P.Type, P.Brand, P.ProductID
having count (P.ProductID) > 4
order by NumOfOrders desc

SELECT Country
FROM CUSTOMERS
WHERE Country NOT IN (SELECT C.Country

FROM CUSTOMERS as C JOIN ORDERS as O ON
C.EmailAddress = O.EmailAddress
WHERE Year(O.DT) = 2021 AND MONTH (O.DT) IN (1,2)
GROUP BY C.Country)

GROUP BY Country

select C.EmailAddress, C.Name,

NumOfOrders = (select count(*)

from ORDERS as OO join CUSTOMERS as CC
on CC.EmailAddress = OO.EmailAddress
where CC.EmailAddress = C.EmailAddress)

from ORDERS as O join CUSTOMERS as C
on C.EmailAddress = O.EmailAddress
where (select count(*)
from ORDERS as OO join CUSTOMERS as CC
on CC.EmailAddress = OO.EmailAddress
where CC.EmailAddress = C.EmailAddress) > 1
group by C.EmailAddress, C.Name
order by NumOfOrders desc

-- Adds user without EMAIL
Insert INTO USERS ([IP Address], EntranceDT, EmailAddress) VALUES ('172.16.0.0',
'2021/10/25 10:34:09', null)
DELETE FROM USERS
WHERE [IP Address] IN (

SELECT [IP Address]
FROM USERS
WHERE EmailAddress IS NULL)

select P.productID
from PRODUCTS as P
WHERE P.productID not in (select DP.ProductID

from DESIGNED_PRODUCTS as DP join ORDERS AS O
ON O.CartID = DP.CartID join CARTS as C
ON C.CartID = O.CartID)

INTERSECT
select DP.ProductID
from CARTS as C join DESIGNED_PRODUCTS as DP
on DP.CartID =C.CartID
where C.CartID not in (select O.cartID

from DESIGNED_PRODUCTS as DP join ORDERS as O
on DP.CartID = O.CartID)

CREATE VIEW DATA_ANALYZE_TEAM_VIEW AS
SELECT EmailAddress, Name, Country, City, Street, PhoneNumber
FROM CUSTOMERS

CREATE VIEW FINANCE_TEAM_VIEW AS
SELECT EmailAddress, [CC - Number], [CC - CVC], [CC - ExpirationDate]
FROM CUSTOMERS

CREATE FUNCTION OrdersPerBrand (@Brand Varchar(15))
RETURNS int
AS BEGIN
DECLARE @OrderAmount int
SELECT @OrderAmount = COUNT(*)
FROM PRODUCTS as P JOIN DESIGNED_PRODUCTS as D
ON P.ProductID = D.ProductID
JOIN ORDERS as O ON D.CartID = O.CartID
WHERE P.Brand = @Brand
RETURN @OrderAmount END

SELECT Brand, Orders = dbo.OrdersPerBrand('Adidas')
FROM Products
WHERE Brand = 'Adidas'
GROUP BY Brand

CREATE FUNCTION SeasonalProducts (@Holiday Varchar(15)
RETURNS Table AS RETURN
SELECT P.Type, P.ProductID, month = month(O.dt),
NumOfOrders = count (*)
FROM PRODUCTS as P JOIN DESIGNED_PRODUCTS as D
ON P.ProductID = D.ProductID JOIN ORDERS as O
ON D.CartID = O.CartID
WHERE  month (O.dt) = CASE WHEN @Holiday = 'Christmas' THEN 12

WHEN @Holiday = 'Ramadan' THEN 03
WHEN @Holiday = 'Passover' THEN 04
ELSE 01 END
Group BY P.Type, P.ProductID, month(O.dt)
SELECT *
FROM SeasonalProducts('Passover')
Order By NumOfOrders desc
CREATE TABLE INFLUENCERS (
EmailAddress Varchar (40) not null,
PhoneNumber Varchar (20) not null,
Name Varchar (20) null,
Country Varchar (20) null,
CONSTRAINT PK_INFLUENCERS PRIMARY KEY (EmailAddress),
CONSTRAINT CK_Email_INFLUENCERS CHECK (EmailAddress LIKE '%@%.%&'),
CONSTRAINT AK_PHONE_INFLUENCERS UNIQUE (PhoneNumber))
CREATE TRIGGER FundraisingOrder_Trigger
ON ORDERS
FOR INSERT, UPDATE
AS
INSERT INTO INFLUENCERS
SELECT O.EmailAddress, C.PhoneNumber, C.Name, C.Country
FROM CUSTOMERS as C JOIN ORDERS as O ON C.EmailAddress = O.EmailAddress
WHERE O.PurchaseType = 'Fundraising'
GROUP BY O.EmailAddress, C.PhoneNumber, C.Name, C.Country
HAVING COUNT(*) > 2
INTERSECT
SELECT I.EmailAddress, C.PhoneNumber, C.Name, C.Country
FROM CUSTOMERS as C JOIN INSERTED as I ON C.EmailAddress = I.EmailAddress
WHERE I.PurchaseType = 'Fundraising'
GROUP BY I.EmailAddress, C.PhoneNumber, C.Name, C.Country

INSERT INTO ORDERS VALUES (333,'2022/04/14 8:32','Fundraising', 111, 1185,
'Erinbrave@gmx.net')
-- A customer added into the table
SELECT *
FROM INFLUENCERS
DELETE FROM ORDERS WHERE OrderID = 333

ALTER TABLE PRODUCTS ADD InStock bit
ALTER TABLE PRODUCTS ADD NotInStockDate Datetime
-- defult 0, 1 = discontinued
DROP PROCEDURE sp_NotInStockProduct
CREATE PROCEDURE sp_NotInStockProduct @ProductID int
AS BEGIN

IF (SELECT Object_ID('NotInStockProduct')) IS NOT NULL DROP Table NotInStockProduct
UPDATE PRODUCTS
SET
InStock = 1,
NotInStockDate = Getdate()
WHERE ProductID = @ProductID
END
EXECUTE sp_NotInStockProduct 664

CREATE VIEW VIEW_CustomInk AS
SELECT P.ProductID, P.Brand, P.Type, P.Color, P.Size, P.Price,
CUS.EmailAddress, CUS.City, CUS.Country, CUS.Gender,
C.CartID, C.DeliveryOption, O.OrderID, O.PurchaseType, [Date Of Purchase] = O.DT,
DP.Quantity
FROM CARTS AS C full JOIN DESIGNED_PRODUCTS AS DP ON C.CartID = DP.CartID
full JOIN PRODUCTS AS P ON DP.ProductID = P.ProductID
JOIN DESIGNS AS D ON D.DesignID = DP.DesignID
full JOIN ORDERS AS O ON O.CartID = C.CartID
JOIN USERS AS U ON U.[IP Address] = D.[IP Address]
JOIN CUSTOMERS AS CUS ON CUS.EmailAddress = U.EmailAddress

CREATE VIEW VIEW_ORDERS as
SELECT C.EmailAddress, C.Country, O.PurchaseType, DP.Quantity, P.Price
FROM CUSTOMERS AS C JOIN ORDERS AS O
ON C.EmailAddress = O.EmailAddress
JOIN DESIGNED_PRODUCTS AS DP ON DP.CartID = O.CartID
JOIN PRODUCTS AS P ON P.ProductID = DP.ProductID

SELECT C.Country, [Total amount] = SUM(C.[Total amount]),
FIRST_VALUE (C.Country) OVER (ORDER BY SUM(C.[Total amount])) [Most
unprofitable Country],
LAST_VALUE (C.Country) OVER (ORDER BY SUM(C.[Total amount]) RANGE BETWEEN
UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) [Most profitable Country]
FROM (SELECT Country, [Total amount] = SUM(Price*Quantity)

FROM VIEW_ORDERS
GROUP BY Country) AS C
GROUP BY Country, C.[Total amount]
ORDER BY [Total amount] DESC

SELECT X.Country, COUNT (DISTINCT X.EmailAddress) [Number Of Customers],
RANK () OVER (PARTITION BY X.PurchaseType ORDER BY COUNT (DISTINCT
X.EmailAddress) DESC) [RANK By Number Of orders],
NTILE (3) OVER (ORDER BY X.PurchaseType) [Group Of Purchase Type],
X.PurchaseType
FROM (SELECT Country, EmailAddress, PurchaseType
FROM VIEW_ORDERS) AS X
GROUP BY Country, PurchaseType
ORDER BY Country, [RANK By Number Of orders]

CREATE VIEW VIEW_Sales as
SELECT YEAR = YEAR (O.DT), P.Brand,
[Quantity Per Year] = SUM(DP.Quantity),

[This year profit] = SUM (P.Price*DP.Quantity)
FROM ORDERS AS O JOIN DESIGNED_PRODUCTS AS DP
ON O.CartID = DP.CartID
JOIN PRODUCTS AS P
ON P.ProductID = DP.ProductID
GROUP BY YEAR (O.DT), P.Brand

SELECT Sales.YEAR , Sales.Brand, Sales.[This year profit],
LAG ( Sales.[This year profit],13) OVER (ORDER BY YEAR) AS [Previous year
profit],
[Change in % from previous year] = ROUND (( Sales.[This year profit] /
Sales.[Previous year profit])*100,2) ,
RANK() OVER (PARTITION BY Brand ORDER BY Sales.[This year profit] ASC)
Brand_RANK_By_Years
FROM (SELECT YEAR, Brand, [This year profit], LAG ([This year profit],13) OVER (ORDER
BY YEAR) AS [Previous year profit]
FROM VIEW_Sales) AS Sales
ORDER BY Brand, Year

-- Creating function
CREATE FUNCTION OrdersByProducts (@ProductID INT)
RETURNS INT
AS BEGIN
DECLARE @Orders INT
SELECT @Orders = COUNT(DISTINCT O.OrderID)
FROM PRODUCTS as P JOIN DESIGNED_PRODUCTS as D ON P.ProductID = D.ProductID
JOIN ORDERS as O ON D.CartID = O.CartID
WHERE P.ProductID = @ProductID
RETURN @Orders
END
-- Creating Trigger
CREATE TRIGGER Delete_Designed_Products
ON PRODUCTS
INSTEAD OF DELETE
AS
DELETE FROM DESIGNED_PRODUCTS
WHERE DESIGNED_PRODUCTS.ProductID = (SELECT ProductID FROM deleted)
DELETE FROM PRODUCTS
WHERE PRODUCTS.ProductID = (SELECT ProductID FROM deleted)
-- Creating Procedure
CREATE PROCEDURE SP_DeleteProduct @ProductID INT
AS
SELECT ProductsBefore = COUNT(DISTINCT ProductID), DesignedProductsBefore = (SELECT
COUNT(*) FROM DESIGNED_PRODUCTS), OrdersNum = dbo.OrdersByProducts(@ProductID)
FROM PRODUCTS
DELETE FROM PRODUCTS
WHERE PRODUCTS.ProductID = @ProductID
SELECT ProductsAfter = COUNT(DISTINCT ProductID), DesignedProductsAfter = (SELECT
COUNT(*) FROM DESIGNED_PRODUCTS)
FROM PRODUCTS

-- Insert Product &amp; Designed Products &amp; Orders -------------------------------
INSERT INTO PRODUCTS (ProductID, Brand, Type, Style, Color, Size, Fabric, MinQuantity,
Price) VALUES (8582, 'Puma', 'Pants&Shorts', 'MeshShorts', 'Black', 'S', 'Mesh', 6,
45)
INSERT INTO CARTS (CartID, ShippingArea, DeliveryOption) VALUES
(10000, 'INTERNATIONAL', 'Rush'),
(10001, 'INTERNATIONAL', 'Rush'),
(10002, 'INTERNATIONAL', 'Rush')
INSERT INTO DESIGNED_PRODUCTS (ProductID, DesignID, Placement, CartID, Quantity)
VALUES
(8582, 1, 'Front Adult', 10000, 350),
(8582, 2, 'Front Adul', 10001, 220),
(8582, 3, 'Front Adult', 10002, 150)
INSERT INTO ORDERS (OrderID, DT, PurchaseType, TrackingNumber, CartID, EmailAddress)
VALUES
(700, '2021/10/25', 'Fundraising', 565, 10000, 'adventurousBrian44@uol.com.br'),
(701, '2021/03/29', 'Group Order', 852, 10002, 'adventurousBrian44@uol.com.br')
EXECUTE SP_DeleteProduct 8582
------------------------------------------------------------------------------
-- DELETE ORDERS &amp; CARTS
DELETE FROM ORDERS WHERE OrderID = 700
DELETE FROM ORDERS WHERE OrderID = 701
DELETE FROM CARTS WHERE CartID = 10000
DELETE FROM CARTS WHERE CartID = 10001
DELETE FROM CARTS WHERE CartID = 10002

-- Creating Function
CREATE FUNCTION YearRange (@Email Varchar(100))
RETURNS INT
AS BEGIN
DECLARE @Range INT
SELECT @Range = MAX(Year(O.DT)) - MIN(Year(O.DT))
FROM CUSTOMERS as C JOIN ORDERS as O ON C.EmailAddress = O.EmailAddress
WHERE C.EmailAddress = @Email
RETURN @Range
END
-- WITH
WITH
CUSTOMER_ORDERS AS (
SELECT C.EmailAddress, Orders = COUNT(DISTINCT OrderID)
FROM CUSTOMERS as C JOIN ORDERS as O ON C.EmailAddress = O.EmailAddress
GROUP BY C.EmailAddress
),
ORDER_DETAILS AS (
SELECT CO.EmailAddress, O.OrderID, O.DT, O.CartID
FROM CUSTOMER_ORDERS as CO JOIN ORDERS as O ON CO.EmailAddress = O.EmailAddress
),
TRANSACTIONS_DETAILS AS (

SELECT OD.EmailAddress, TotalAmount = SUM(P.Price * DP.Quantity)
FROM ORDER_DETAILS as OD JOIN DESIGNED_PRODUCTS as DP ON OD.CartID = DP.CartID
JOIN PRODUCTS as P ON DP.ProductID = P.ProductID
GROUP BY OD.EmailAddress
),
CUSTOMER_DESIGNS AS (
SELECT C.EmailAddress, Designs = COUNT(*)
FROM CUSTOMERS as C JOIN USERS as U ON C.EmailAddress = U.EmailAddress
JOIN DESIGNS as D ON U.[IP Address] = D.[IP Address]
GROUP BY C.EmailAddress
)
-- Main Query
SELECT C.EmailAddress, C.Gender, C.Country,
Orders = CO.Orders,
[Average Orders Per Year] = CASE

WHEN

dbo.YearRange(C.EmailAddress) > 0 THEN (CO.Orders / CAST(dbo.YearRange(C.EmailAddress)
AS DECIMAL(3,1)))

WHEN

dbo.YearRange(C.EmailAddress) = 0 THEN CO.Orders
END,

TotalAmount = TD.TotalAmount,
[Average Expense Per Order] = TD.TotalAmount / CO.Orders,
[Designs-Orders Ratio] = CD.Designs / CAST(CO.Orders AS DECIMAL(4,1))
FROM CUSTOMERS as C JOIN TRANSACTIONS_DETAILS as TD ON C.EmailAddress =
TD.EmailAddress
JOIN CUSTOMER_ORDERS as CO ON CO.EmailAddress = C.EmailAddress
JOIN CUSTOMER_DESIGNS as CD ON CD.EmailAddress = C.EmailAddress
WHERE C.EmailAddress IN (SELECT EmailAddress FROM TRANSACTIONS_DETAILS WHERE
TotalAmount / CO.Orders > 4000)
ORDER BY [Average Expense Per Order] DESC
--DROP TABELS
DROP FUNCTION YearRange
DROP PROCEDURE SP_DeleteProduct
DROP TRIGGER Delete_Designed_Products
DROP FUNCTION OrdersByProducts
DROP VIEW VIEW_Sales
DROP VIEW VIEW_ORDERS
DROP VIEW VIEW_CustomInk
DROP PROCEDURE sp_NotInStockProduct
DROP TRIGGER FundraisingOrder_Trigger
DROP TABLE INFLUENCERS
DROP FUNCTION SeasonalProducts
DROP FUNCTION OrdersPerBrand
DROP VIEW FINANCE_TEAM_VIEW
DROP VIEW DATA_ANALYZE_TEAM_VIEW
DROP TABLE DESIGNED_PRODUCTS
DROP TABLE DESIGNS

DROP TABLE USERS
DROP TABLE ORDERS
DROP TABLE CUSTOMERS
DROP TABLE CARTS
DROP TABLE PRODUCTS
DROP TABLE DELIVERY_OPTIONS
DROP TABLE SHIPPING_AREAS
DROP TABLE SIZES
DROP TABLE PURCHASE_TYPES
DROP TABLE COLORS
DROP TABLE PLACEMENTS