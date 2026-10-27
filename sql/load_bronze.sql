BEGIN;

INSERT INTO bronze.customers 
SELECT * FROM raw.customers;

INSERT INTO bronze.products
SELECT * FROM raw.products;

INSERT INTO bronze.orders
SELECT * FROM raw.orders;

INSERT INTO bronze.order_items
SELECT * FROM raw.order_items;

INSERT INTO bronze.payments 
SELECT * FROM raw.payments;

COMMIT;