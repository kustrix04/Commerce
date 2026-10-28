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
--7.Cancellation rate by sales channel
SELECT
	oe.sales_channel,
	COUNT(oe.order_id) AS total_orders,
	SUM(
		CASE
			WHEN oe.order_status = 'cancelled' THEN 1
			ELSE 0
		END
	) AS cancelled_orders,
	ROUND(
		SUM(
			CASE 
				WHEN oe.order_status = 'cancelled' THEN 1
				ELSE 0
			END
		) * 100.0 / COUNT(oe.order_id)
		, 2
	) AS cancellation_rate_percent
FROM silver.orders_enriched oe
GROUP BY oe.sales_channel 
ORDER BY cancellation_rate_percent DESC;
--8.Month by month revenue growth
WITH monthly_revenue AS(
	SELECT
		ppm.sales_month,
		SUM(ppm.net_revenue) AS net_revenue
	FROM gold.product_performance_monthly ppm
	GROUP BY ppm.sales_month
),
previous_revenue AS(
	SELECT
		mr.sales_month,
		mr.net_revenue,
		LAG(mr.net_revenue) OVER(
			ORDER BY mr.sales_month
		) AS previous_month_revenue
	FROM monthly_revenue mr
)
SELECT
	TO_CHAR(pr.sales_month, 'YYYY-MM') AS sales_month,
	pr.net_revenue,
	pr.previous_month_revenue,
	CASE
		WHEN pr.previous_month_revenue IS NULL 
			OR pr.previous_month_revenue = 0 
		THEN NULL
		ELSE ROUND(
			(pr.net_revenue - pr.previous_month_revenue) * 100 /
				pr.previous_month_revenue, 2
				)
	END AS growth_percent
FROM previous_revenue pr
ORDER BY pr.sales_month;