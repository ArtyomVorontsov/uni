/*******************************************************
 * Author:      Artjoms Voroncovs
 * Date:        29-NOV-2025
 * Description: Sample Data for Retail Sales Reporting Database
 *              This script inserts data to demonstrate:
 *                - Multiple stores and product categories
 *                - Several customers with multiple purchases
 *                - A mix of discounted and regular orders
 *                - Orders covering at least two consecutive months
 *              Data includes entries for:
 *                - CUSTOMERS
 *                - PRODUCTS
 *                - STORES
 *                - ORDERS
 *                - ORDER_LINES
 *******************************************************/

---------------------------------------------------------------
-- SAMPLE DATA INSERTS (DML)
---------------------------------------------------------------
-- ==============
-- CUSTOMERS
-- ==============
INSERT INTO
    CUSTOMERS (name, region, loyalty_level)
VALUES
    ('Alice Johnson', 'North', 'Gold'),
    ('Bob Smith', 'South', 'Silver'),
    ('Carol White', 'West', 'Bronze'),
    ('David Green', 'East', 'Platinum');

-- ==============
-- PRODUCTS
-- ==============
INSERT INTO
    PRODUCTS (name, category, price)
VALUES
    ('Laptop X200', 'Electronics', 1200.00),
    ('Wireless Mouse', 'Electronics', 25.00),
    ('Office Chair', 'Furniture', 180.00),
    ('Coffee Beans 1kg', 'Groceries', 15.00),
    ('Headphones Pro', 'Electronics', 150.00),
    ('Desk Lamp', 'Furniture', 40.00);

-- ==============
-- STORES
-- ==============
INSERT INTO
    STORES (name, store_type)
VALUES
    ('Online Store', 'online'),
    ('City Center Shop', 'physical'),
    ('Mall Outlet', 'physical');

-- ==============
-- ORDERS (JAN–FEB 2025)
-- ==============
-- JANUARY ORDERS
INSERT INTO
    ORDERS (
        customer_id,
        store_id,
        order_date,
        total_amount,
        discount_amount
    )
VALUES
    (1, 1, DATE '2025-01-05', 1225.00, 25.00),
    -- Alice (Laptop + Mouse)
    (2, 2, DATE '2025-01-10', 180.00, 0.00),
    -- Bob (Chair)
    (1, 1, DATE '2025-01-15', 150.00, 10.00),
    -- Alice (Headphones)
    (3, 3, DATE '2025-01-20', 15.00, 0.00),
    -- Carol (Coffee)
    (4, 2, DATE '2025-01-28', 40.00, 0.00);

-- David (Desk Lamp)
-- FEBRUARY ORDERS
INSERT INTO
    ORDERS (
        customer_id,
        store_id,
        order_date,
        total_amount,
        discount_amount
    )
VALUES
    (2, 1, DATE '2025-02-03', 125.00, 0.00),
    -- Bob (Mouse + Coffee)
    (1, 2, DATE '2025-02-07', 1380.00, 20.00),
    -- Alice (Laptop + Chair)
    (3, 3, DATE '2025-02-18', 150.00, 0.00),
    -- Carol (Headphones)
    (4, 1, DATE '2025-02-19', 65.00, 5.00);

-- David (Lamp + Coffee)
-- ==============
-- ORDER LINES
-- ==============
-- For January
-- Order 1 (Alice - 2025-01-05)
INSERT INTO
    ORDER_LINES (order_id, product_id, quantity, line_price)
VALUES
    (1, 1, 1, 1200.00),
    -- Laptop
    (1, 2, 1, 25.00);

-- Mouse
-- Order 2 (Bob - 2025-01-10)
INSERT INTO
    ORDER_LINES (order_id, product_id, quantity, line_price)
VALUES
    (2, 3, 1, 180.00);

-- Chair
-- Order 3 (Alice - 2025-01-15)
INSERT INTO
    ORDER_LINES (order_id, product_id, quantity, line_price)
VALUES
    (3, 5, 1, 150.00);

-- Headphones
-- Order 4 (Carol - 2025-01-20)
INSERT INTO
    ORDER_LINES (order_id, product_id, quantity, line_price)
VALUES
    (4, 4, 1, 15.00);

-- Coffee
-- Order 5 (David - 2025-01-28)
INSERT INTO
    ORDER_LINES (order_id, product_id, quantity, line_price)
VALUES
    (5, 6, 1, 40.00);

-- Lamp
-- For February
-- Order 6 (Bob - 2025-02-03)
INSERT INTO
    ORDER_LINES (order_id, product_id, quantity, line_price)
VALUES
    (6, 2, 1, 25.00),
    -- Mouse
    (6, 4, 1, 15.00);

-- Coffee
-- Order 7 (Alice - 2025-02-07)
INSERT INTO
    ORDER_LINES (order_id, product_id, quantity, line_price)
VALUES
    (7, 1, 1, 1200.00),
    -- Laptop
    (7, 3, 1, 180.00);

-- Chair
-- Order 8 (Carol - 2025-02-18)
INSERT INTO
    ORDER_LINES (order_id, product_id, quantity, line_price)
VALUES
    (8, 5, 1, 150.00);

-- Headphones
-- Order 9 (David - 2025-02-19)
INSERT INTO
    ORDER_LINES (order_id, product_id, quantity, line_price)
VALUES
    (9, 6, 1, 40.00),
    -- Lamp
    (9, 4, 1, 15.00);

-- Coffee