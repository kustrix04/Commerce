CREATE TABLE gold.daily_sales_summary(
	sales_date date NOT NULL,
	country varchar(2) NOT NULL,
	sales_channel varchar(30) NOT NULL,
	orders_count int,
	paid_orders_count int,
	cancelled_orders_count int,
	gross_revenue numeric(14,2),
	discount_value numeric(14,2),
	net_revenue numeric(14,2),
	PRIMARY KEY(sales_date, country, sales_channel)
);
CREATE TABLE gold.customer_analytics(
    customer_id int PRIMARY KEY,
    customer_name varchar(100),
    country varchar(2),
    first_order_date date,
    last_order_date date,
    orders_count int,
    total_net_revenue numeric(14,2),
    average_order_value numeric(14,2),
    customer_lifetime_rank int
);
CREATE TABLE gold.product_performance_monthly(
    sales_month date NOT NULL,
    category varchar(50),
    product_id int NOT NULL,
    product_name varchar(100),
    units_sold int,
    gross_revenue numeric(14,2),
    net_revenue numeric(14,2),
    category_rank_by_revenue int,
	PRIMARY KEY (sales_month, product_id)
);