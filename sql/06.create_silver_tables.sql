CREATE TABLE silver.customers_clean(
	customer_id int PRIMARY KEY,
	customer_name varchar(100),
	email varchar(150),
	country varchar(2),
	signup_date date,
	acquisition_channel varchar(30)
);
CREATE TABLE silver.products_clean(
	product_id int PRIMARY KEY,
	product_name varchar(100),
	category varchar(50),
	base_price NUMERIC(10,2)
);
CREATE TABLE silver.orders_enriched(
	order_id int PRIMARY KEY,
	customer_id int,
	order_date date,
	order_timestamp timestamp,
	order_month date,
	order_status varchar(30),
	currency varchar(3),
	sales_channel varchar(30),
	payment_status varchar(30),
	payment_method varchar(30),
	is_paid boolean,
	first_order_date date
);
CREATE TABLE silver.order_items_enriched (
    order_item_id int PRIMARY KEY,
    order_id int,
    product_id int,
    product_name varchar(100),
    category varchar(50),
    quantity int,
    unit_price numeric(10,2),
    discount_percent numeric(5,2),
    gross_value numeric(14,2),
    discount_value numeric(14,2),
    net_value numeric(14,2)
);
