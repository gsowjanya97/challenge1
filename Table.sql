CREATE TABLE Products
(
   ProductID int,
   ProductName varchar(1000),
   Quantity int
)

INSERT INTO Products(ProductID,ProductName,Quantity) VALUES (1, 'Azure', 100)
INSERT INTO Products(ProductID,ProductName,Quantity) VALUES (2, 'GCP', 200)
INSERT INTO Products(ProductID,ProductName,Quantity) VALUES (3, 'AWS', 300)

SELECT * FROM Products
