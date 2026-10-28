BEGIN;
INSERT INTO silver.customers_clean(
	customer_id,
	customer_name,
	email,
	country,
	signup_date,
	acquisition_channel
)
SELECT
	c.customer_id,
	INITCAP(TRIM(c.customer_name)) AS customer_name,
	lower(trim(c.email)) AS email,
	upper(trim(c.country)) AS country,
	c.signup_date AS signup_date,
	lower(trim(c.acquisition_channel)) AS acquisition_channel
FROM bronze.customers c;
COMMIT;
BEGIN;
INSERT INTO silver.products_clean(
	product_id,
	product_name,
	category,
	base_price
)
SELECT
	p.product_id,
	trim(p.product_name) AS product_name,
	lower(trim(p.category)) AS category,
	p.base_price
FROM bronze.products p;
COMMIT;
BEGIN;
INSERT INTO silver.orders_enriched(
	order_id,
    customer_id,
    order_date,
    order_timestamp,
    order_month,
    order_status,
    currency,
    sales_channel,
    payment_status,
    payment_method,
    is_paid,
    first_order_date
 )
SELECT 
	o.order_id,
	o.customer_id,		
	CAST(o.order_timestamp AS date) AS order_date,
	o.order_timestamp,
	CAST(DATE_TRUNC('month', o.order_timestamp) AS DATE) AS order_month,
	lower(trim(o.status)) AS order_status,
	upper(trim(o.currency)) AS currency,
	lower(trim(o.sales_channel)) AS sales_channel,
	lower(trim(p.payment_status)) AS payment_status,
	lower(trim(p.payment_method)) AS payment_method,
	CASE
		WHEN lower(trim(p.payment_status)) = 'paid' THEN TRUE
		ELSE FALSE
	END AS is_paid,
	MIN(CAST(o.order_timestamp AS date)) OVER(
		PARTITION BY o.customer_id
	) AS first_order_date
FROM bronze.orders o
LEFT JOIN bronze.payments p 
	ON o.order_id = p.order_id;
COMMIT;
BEGIN;
INSERT INTO silver.order_items_enriched(
	order_item_id,
	order_id,
	product_id,
	product_name,
	category,
	quantity,
	unit_price,
	discount_percent,
	gross_value,
	discount_value,
	net_value
)
SELECT
	oi.order_item_id,
	oi.order_id,
	oi.product_id,
	pc.product_name,
	pc.category,
	oi.quantity,
	oi.unit_price,
	oi.discount_percent,
	(oi.quantity * oi.unit_price) AS gross_value,
	(oi.quantity * oi.unit_price * oi.discount_percent / 100) AS discount_value,
	(oi.quantity * oi.unit_price *
		(1 - oi.discount_percent / 100)) AS net_value
FROM bronze.order_items oi 
LEFT JOIN silver.products_clean pc
	ON oi.product_id = pc.product_id;
COMMIT;
