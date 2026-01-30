CREATE DATABASE food_delivery_db;
USE food_delivery_db;

CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15)
);

CREATE TABLE Address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    street VARCHAR(150),
    city VARCHAR(50),
    state VARCHAR(50),
    pincode VARCHAR(10)
);

CREATE TABLE Customer_Address (
    customer_id INT,
    address_id INT,
    PRIMARY KEY(customer_id, address_id),
    FOREIGN KEY(customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY(address_id) REFERENCES Address(address_id)
);

CREATE TABLE Restaurant (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    rating DECIMAL(2,1)
);

CREATE TABLE Category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE Restaurant_Category (
    restaurant_id INT,
    category_id INT,
    PRIMARY KEY(restaurant_id, category_id),
    FOREIGN KEY(restaurant_id) REFERENCES Restaurant(restaurant_id),
    FOREIGN KEY(category_id) REFERENCES Category(category_id)
);

CREATE TABLE Menu (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT,
    FOREIGN KEY(restaurant_id) REFERENCES Restaurant(restaurant_id)
);

CREATE TABLE Menu_Item (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    menu_id INT,
    item_name VARCHAR(100),
    price DECIMAL(10,2),
    FOREIGN KEY(menu_id) REFERENCES Menu(menu_id)
);

CREATE TABLE `Order` (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(30),
    FOREIGN KEY(customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY(restaurant_id) REFERENCES Restaurant(restaurant_id)
);

CREATE TABLE Order_Item (
    order_id INT,
    item_id INT,
    quantity INT,
    PRIMARY KEY(order_id, item_id),
    FOREIGN KEY(order_id) REFERENCES `Order`(order_id),
    FOREIGN KEY(item_id) REFERENCES Menu_Item(item_id)
);

CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(30),
    FOREIGN KEY(order_id) REFERENCES `Order`(order_id)
);

CREATE TABLE Delivery_Agent (
    agent_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(15),
    vehicle_type VARCHAR(50)
);

CREATE TABLE Delivery (
    delivery_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    agent_id INT,
    delivery_status VARCHAR(30),
    delivery_time INT,
    FOREIGN KEY(order_id) REFERENCES `Order`(order_id),
    FOREIGN KEY(agent_id) REFERENCES Delivery_Agent(agent_id)
);

CREATE TABLE Review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    rating INT,
    comment TEXT,
    FOREIGN KEY(customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY(restaurant_id) REFERENCES Restaurant(restaurant_id)
);

INSERT INTO Customer (name,email,phone) VALUES
('Aarav','aarav@gmail.com','9001'),
('Neha','neha@gmail.com','9002'),
('Rahul','rahul@gmail.com','9003'),
('Priya','priya@gmail.com','9004'),
('Karan','karan@gmail.com','9005');

INSERT INTO Address (street,city,state,pincode) VALUES
('Street1','CityA','StateA','111111'),
('Street2','CityB','StateB','222222'),
('Street3','CityC','StateC','333333'),
('Street4','CityD','StateD','444444'),
('Street5','CityE','StateE','555555');

INSERT INTO Customer_Address VALUES
(1,1),(1,2),(2,3),(3,4),(4,5);

INSERT INTO Restaurant (name,city,rating) VALUES
('FoodHub','CityA',4.5),
('TasteBox','CityB',4.2),
('QuickEats','CityC',4.7),
('DailyMeals','CityD',4.0),
('YummyCorner','CityE',4.3);

INSERT INTO Category (category_name) VALUES
('Indian'),('Chinese'),('Italian'),('FastFood'),('Desserts');

INSERT INTO Restaurant_Category VALUES
(1,1),(1,4),(2,2),(3,3),(4,4),(5,5);

INSERT INTO Menu (restaurant_id) VALUES
(1),(2),(3),(4),(5);

INSERT INTO Menu_Item (menu_id,item_name,price) VALUES
(1,'Biryani',250),
(1,'Curry',180),
(2,'Noodles',160),
(3,'Pizza',300),
(4,'Burger',150),
(5,'IceCream',120);

INSERT INTO `Order` (customer_id,restaurant_id,status) VALUES
(1,1,'Completed'),
(2,2,'Completed'),
(3,3,'Completed'),
(4,4,'Pending'),
(5,5,'Completed');

INSERT INTO Order_Item VALUES
(1,1,2),(1,2,1),(2,3,2),(3,4,1),(4,5,2);

INSERT INTO Payment (order_id,amount,payment_method,payment_status) VALUES
(1,680,'Card','Success'),
(2,320,'UPI','Success'),
(3,300,'Card','Success'),
(4,300,'Cash','Pending'),
(5,240,'UPI','Success');

INSERT INTO Delivery_Agent (name,phone,vehicle_type) VALUES
('Ramesh','8001','Bike'),
('Suresh','8002','Scooter'),
('Anil','8003','Bike');

INSERT INTO Delivery (order_id,agent_id,delivery_status,delivery_time) VALUES
(1,1,'Delivered',30),
(2,2,'Delivered',25),
(3,3,'Delivered',35),
(4,1,'On the way',20),
(5,2,'Delivered',28);

INSERT INTO Review (customer_id,restaurant_id,rating,comment) VALUES
(1,1,5,'Excellent'),
(2,2,4,'Good'),
(3,3,5,'Amazing'),
(4,4,3,'Average'),
(5,5,4,'Nice');

CREATE VIEW Restaurant_Revenue AS
SELECT r.name, SUM(p.amount) AS total_revenue
FROM Restaurant r
JOIN `Order` o ON r.restaurant_id = o.restaurant_id
JOIN Payment p ON o.order_id = p.order_id
GROUP BY r.name;

CREATE VIEW Delivery_Performance AS
SELECT da.name, COUNT(d.delivery_id) AS total_deliveries, AVG(d.delivery_time) AS avg_time
FROM Delivery d
JOIN Delivery_Agent da ON d.agent_id = da.agent_id
GROUP BY da.name;

-- High value customers
SELECT c.name, SUM(p.amount) AS total_spent
FROM Customer c
JOIN `Order` o ON c.customer_id = o.customer_id
JOIN Payment p ON o.order_id = p.order_id
GROUP BY c.name
HAVING SUM(p.amount) > 500;

-- Restaurant performance
SELECT r.name,
AVG(rv.rating) AS avg_rating,
COUNT(o.order_id) AS total_orders,
CASE 
 WHEN AVG(rv.rating)>=4.5 THEN 'Excellent'
 WHEN AVG(rv.rating)>=4.0 THEN 'Good'
 ELSE 'Average'
END AS performance
FROM Restaurant r
LEFT JOIN Review rv ON r.restaurant_id=rv.restaurant_id
LEFT JOIN `Order` o ON r.restaurant_id=o.restaurant_id
GROUP BY r.name;

-- Above average orders
SELECT o.order_id,p.amount
FROM `Order` o
JOIN Payment p ON o.order_id=p.order_id
WHERE p.amount > (SELECT AVG(amount) FROM Payment);

-- Delivery ranking (window function)
SELECT da.name,
COUNT(d.delivery_id) AS total_deliveries,
RANK() OVER(ORDER BY COUNT(d.delivery_id) DESC) AS rank_no
FROM Delivery d
JOIN Delivery_Agent da ON d.agent_id=da.agent_id
GROUP BY da.name;

-- Popular items
SELECT mi.item_name,SUM(oi.quantity) AS total_ordered
FROM Menu_Item mi
JOIN Order_Item oi ON mi.item_id=oi.item_id
GROUP BY mi.item_name
ORDER BY total_ordered DESC;


DELIMITER $$
CREATE PROCEDURE GetCustomerOrders(IN cid INT)
BEGIN
SELECT o.order_id,o.order_date,p.amount
FROM `Order` o
JOIN Payment p ON o.order_id=p.order_id
WHERE o.customer_id=cid;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION DeliveryRating(avg_time INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
DECLARE result VARCHAR(20);
IF avg_time<=25 THEN SET result='Fast';
ELSEIF avg_time<=35 THEN SET result='Normal';
ELSE SET result='Slow';
END IF;
RETURN result;
END$$
DELIMITER ;



CALL GetCustomerOrders(1);



CALL GetCustomerOrders(2);




CALL GetCustomerOrders(3);


SELECT c.name,r.name,mi.item_name,SUM(oi.quantity)
FROM Customer c
JOIN `Order` o ON c.customer_id=o.customer_id
JOIN Order_Item oi ON o.order_id=oi.order_id
JOIN Menu_Item mi ON oi.item_id=mi.item_id
JOIN Restaurant r ON o.restaurant_id=r.restaurant_id
GROUP BY c.name,r.name,mi.item_name;

CREATE INDEX idx_order_customer ON `Order`(customer_id);
CREATE INDEX idx_order_restaurant ON `Order`(restaurant_id);
CREATE INDEX idx_orderitem_order ON Order_Item(order_id);
CREATE INDEX idx_orderitem_item ON Order_Item(item_id);

SELECT r.name,mi.item_name,SUM(oi.quantity)
FROM `Order` o
JOIN Order_Item oi ON o.order_id=oi.order_id
JOIN Menu_Item mi ON oi.item_id=mi.item_id
JOIN Restaurant r ON o.restaurant_id=r.restaurant_id
GROUP BY r.name,mi.item_name;






