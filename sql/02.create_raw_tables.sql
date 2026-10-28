CREATE TABLE raw.customers(
	customer_id int PRIMARY KEY,
	customer_name varchar(100) NOT NULL,
	email varchar(150),
	country varchar(2) NOT NULL,
	signup_date date NOT NULL,
	acquisition_channel varchar(30)
);
CREATE TABLE raw.products(
	product_id int PRIMARY KEY,
	product_name varchar(100) NOT NULL,
	category varchar(50) NOT NULL,
	base_price numeric(10,2) NOT NULL
);
CREATE TABLE raw.orders(
	order_id int PRIMARY KEY,
	customer_id int NOT NULL,
	order_timestamp timestamp NOT NULL,
	status varchar(30) NOT NULL,
	currency varchar(3) NOT NULL,
	sales_channel varchar(30) NOT NULL
);
CREATE TABLE raw.order_items(
	order_item_id int PRIMARY KEY,
	order_id int NOT NULL,
	product_id int NOT NULL,
	quantity int NOT NULL,
	unit_price NUMERIC(10,2) NOT NULL,
	discount_percent numeric(5,2) NOT NULL
);
CREATE TABLE raw.payments(
	payment_id int PRIMARY KEY,
	order_id int NOT NULL,
	payment_status varchar(30) NOT NULL,
	payment_method varchar(30) NOT NULL,
	paid_at timestamp
);
