CREATE INDEX IF NOT EXISTS idx_silver_orders_customer_id
ON silver.orders_enriched(customer_id);
--
CREATE INDEX IF NOT EXISTS idx_silver_order_items_order_id
ON silver.order_items_enriched(order_id);
--
CREATE INDEX IF NOT EXISTS idx_gold_customer_revenue
ON gold.customer_analytics(total_net_revenue DESC);
--
CREATE INDEX IF NOT EXISTS idx_gold_product_top3
ON gold.product_performance_monthly(sales_month, category, category_rank_by_revenue)
WHERE category_rank_by_revenue <= 3;