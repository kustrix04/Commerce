BEGIN;
INSERT INTO gold.daily_sales_summary(
    sales_date,
    country,
    sales_channel,
    orders_count,
    paid_orders_count,
    cancelled_orders_count,
    gross_revenue,
    discount_value,
    net_revenue
)
WITH order_totals AS(
	SELECT
		oi.order_id,
		SUM(oi.gross_value) AS gross_value,
		SUM(oi.discount_value) AS discount_value,
		SUM(oi.net_value) AS net_value
	FROM silver.order_items_enriched oi
	GROUP BY oi.order_id 
)
SELECT
	oe.order_date AS sales_date,
	cc.country,
	oe.sales_channel,
	COUNT(DISTINCT oe.order_id) AS orders_count,
	SUM(
		CASE
			WHEN oe.is_paid = TRUE THEN 1
			ELSE 0
		END
	) AS paid_orders_count,
	SUM(
		CASE
			WHEN oe.order_status = 'cancelled' THEN 1
			ELSE 0
		END
	) AS cancelled_orders_count,
	ROUND(
		SUM(
			CASE
				WHEN oe.is_paid = TRUE THEN COALESCE(ot.gross_value, 0)
				ELSE 0
			END
			), 2
	) AS gross_revenue,
	ROUND(
		SUM(
			CASE
				WHEN oe.is_paid = TRUE THEN COALESCE(ot.discount_value, 0)
				ELSE 0
			END
			), 2
	) AS discount_value,
	ROUND(
		SUM(
			CASE
				WHEN oe.is_paid = TRUE THEN COALESCE(ot.net_value, 0)
				ELSE 0
			END
			), 2
	) AS net_revenue
FROM silver.orders_enriched oe 
LEFT JOIN order_totals ot
	ON oe.order_id = ot.order_id 
LEFT JOIN silver.customers_clean cc
	ON oe.customer_id = cc.customer_id
GROUP BY oe.order_date, cc.country, oe.sales_channel;
COMMIT;
BEGIN;
INSERT INTO gold.customer_analytics (
    customer_id,
    customer_name,
    country,
    first_order_date,
    last_order_date,
    orders_count,
    total_net_revenue,
    average_order_value,
    customer_lifetime_rank
)
WITH order_totals AS(
	SELECT
		oi.order_id,
		SUM(oi.net_value) AS net_value
	FROM silver.order_items_enriched oi
	GROUP BY oi.order_id 
),
customer_sales AS(
	SELECT
		cc.customer_id,
		cc.customer_name,
		cc.country,
		MIN(oe.order_date) AS first_order_date,
		MAX(oe.order_date) AS last_order_date,
		COUNT(oe.order_id) AS orders_count,
		SUM(
			CASE
				WHEN oe.is_paid = TRUE 
				THEN COALESCE(ot.net_value, 0)
				ELSE 0
			END
		) AS total_net_revenue,
		COALESCE(
			AVG(
				CASE
					WHEN oe.is_paid = TRUE 
					THEN COALESCE(ot.net_value, 0)
				END
				), 0
		) AS average_order_value
	FROM silver.customers_clean cc
	LEFT JOIN silver.orders_enriched oe
		ON cc.customer_id = oe.customer_id 
	LEFT JOIN order_totals ot
		ON oe.order_id = ot.order_id
	GROUP BY cc.customer_id, cc.customer_name, cc.country
)
SELECT
	cs.customer_id,
	cs.customer_name,
	cs.country,
	cs.first_order_date,
	cs.last_order_date,
	cs.orders_count,
	ROUND(cs.total_net_revenue, 2) AS total_net_revenue,
	COALESCE(ROUND(cs.average_order_value, 2), 0) AS average_order_value,
	RANK() OVER(
		ORDER BY cs.total_net_revenue DESC
	) AS customer_lifetime_rank
FROM customer_sales cs;
COMMIT;
BEGIN;
INSERT INTO gold.product_performance_monthly(
	sales_month,
	category,
	product_id,
	product_name,
	units_sold,
	gross_revenue,
	net_revenue,
	category_rank_by_revenue
)
WITH monthly_product_sales AS(
	SELECT
		oe.order_month AS sales_month,
		oi.category,
		oi.product_id,
		oi.product_name,
		SUM(oi.quantity) AS units_sold,
		SUM(oi.gross_value) AS gross_revenue,
		SUM(oi.net_value) AS net_revenue
	FROM silver.order_items_enriched oi
	JOIN silver.orders_enriched oe
		ON oi.order_id = oe.order_id
	WHERE oe.is_paid = TRUE
	GROUP BY oe.order_month, oi.category, oi.product_id, oi.product_name
)
SELECT
    mps.sales_month,
    mps.category,
    mps.product_id,
    mps.product_name,
    mps.units_sold,
    ROUND(mps.gross_revenue, 2) AS gross_revenue,
    ROUND(mps.net_revenue, 2) AS net_revenue,
	DENSE_RANK() OVER(
		PARTITION BY mps.sales_month, mps.category
		ORDER BY mps.net_revenue DESC
	) AS category_rank_by_revenue
FROM monthly_product_sales mps;
COMMIT;
