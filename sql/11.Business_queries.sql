--1.Daily net revenue per country
SELECT
	dss.sales_date,
	dss.country,
	ROUND(SUM(net_revenue), 2) AS daily_net_revenue
FROM gold.daily_sales_summary dss
GROUP BY dss.sales_date, dss.country
ORDER BY dss.sales_date, dss.country;
--2.TOP 5 customers by net revenue
SELECT 
	ca.customer_id,
	ca.customer_name,
	ca.country,
	ca.total_net_revenue,
	ca.customer_lifetime_rank
FROM gold.customer_analytics ca
ORDER BY ca.total_net_revenue DESC, ca.customer_id 
LIMIT 5;
--3.TOP 3 products by category and month
SELECT
	TO_CHAR(ppm.sales_month, 'YYYY-MM') AS sales_month,
	ppm.category,
	ppm.product_id,
	ppm.product_name,
	ppm.units_sold,
	ppm.net_revenue,
	ppm.category_rank_by_revenue
FROM gold.product_performance_monthly ppm 
WHERE ppm.category_rank_by_revenue <= 3
ORDER BY ppm.sales_month, ppm.category, ppm.category_rank_by_revenue;
--4.Monthly net revenue
SELECT
	TO_CHAR(ppm.sales_month, 'YYYY-MM') AS sales_month,
	ROUND(SUM(ppm.net_revenue), 2) AS monthly_net_revenue
FROM gold.product_performance_monthly ppm
GROUP BY ppm.sales_month
ORDER BY ppm.sales_month;
--5.Discount share in gross revenue
SELECT
	ROUND(SUM(dss.gross_revenue), 2) AS total_gross_revenue,
	ROUND(SUM(dss.discount_value), 2) AS total_discount_value,
	ROUND(
		SUM(dss.discount_value) * 100.0 /
		NULLIF(SUM(dss.gross_revenue), 0), 2
	) AS discount_share_percent
FROM gold.daily_sales_summary dss;
--6.Orders by payment status
SELECT
	oe.payment_status,
	COUNT(oe.order_id) AS orders_count
FROM silver.orders_enriched oe
GROUP BY oe.payment_status
ORDER BY orders_count DESC;
