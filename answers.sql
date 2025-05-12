-- Question 1: Achieving 1NF (First Normal Form)
CREATE TABLE ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Step 2: Transform to 1NF - Split comma-separated products into individual rows.

WITH product_split AS (
  SELECT 
    OrderID,
    CustomerName,
    JSON_TABLE(
      JSON_ARRAYAGG(TRIM(product)),
      '$[*]' COLUMNS (productName VARCHAR(100) PATH '$')
    ) AS jt
  FROM (
    SELECT
      OrderID,
      CustomerName,
      TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', numbers.n), ',', -1)) AS product
    FROM 
      ProductDetail
    JOIN (
      SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
    ) numbers
    ON CHAR_LENGTH(Products) - CHAR_LENGTH(REPLACE(Products, ',', '')) >= numbers.n - 1
  ) AS split_products
  GROUP BY OrderID, CustomerName
)
SELECT OrderID, CustomerName, jt.productName
FROM product_split;

-- Question 2: Achieving 2NF (Second Normal Form) 
CREATE TABLE Customers (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

CREATE TABLE OrderProducts (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Customers(OrderID)
);

-- Step 2: Insert distinct OrderID and CustomerName into Customers
INSERT INTO Customers (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Step 3: Insert OrderID, Product, Quantity into OrderProducts
INSERT INTO OrderProducts (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;
