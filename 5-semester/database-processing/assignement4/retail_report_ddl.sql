/*******************************************************
 * Author:      Artjoms Voroncovs
 * Date:        29-NOV-2025
 * Description:  Retail Sales Reporting Database Schema
 *               This script creates a simple schema to
 *               support retail sales reporting. It includes:
 *                 - CUSTOMERS table with loyalty levels
 *                 - PRODUCTS table with categories and prices
 *                 - STORES table distinguishing online and physical stores
 *                 - ORDERS table tracking customer purchases, discounts, and totals
 *                 - ORDER_LINES table for individual order items
 *               Includes DROP TABLE statements to clean up
 *               previous objects and constraints for data integrity.
 *******************************************************/


-- ============================================================
-- CLEANUP: DROP TABLES IN CORRECT ORDER
-- ============================================================

DROP TABLE IF EXISTS ORDER_LINES;
DROP TABLE IF EXISTS ORDERS;
DROP TABLE IF EXISTS STORES;
DROP TABLE IF EXISTS PRODUCTS;
DROP TABLE IF EXISTS CUSTOMERS;

-- ============================================================
-- RETAIL SALES REPORTING DATABASE SCHEMA (DDL)
-- ============================================================

-- ======================
-- 1. CUSTOMERS
-- ======================
CREATE TABLE CUSTOMERS (
    customer_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    region           VARCHAR(50),
    loyalty_level    VARCHAR(20) CHECK (loyalty_level IN ('Bronze', 'Silver', 'Gold', 'Platinum'))
);

-- ======================
-- 2. PRODUCTS
-- ======================
CREATE TABLE PRODUCTS (
    product_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    category         VARCHAR(50),
    price            DECIMAL(10,2) NOT NULL CHECK (price >= 0)
);

-- ======================
-- 3. STORES
-- ======================
CREATE TABLE STORES (
    store_id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    store_type       VARCHAR(10) NOT NULL CHECK (store_type IN ('online', 'physical'))
);

-- ======================
-- 4. ORDERS
-- ======================
CREATE TABLE ORDERS (
    order_id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id      INT NOT NULL,
    store_id         INT NOT NULL,
    order_date       DATE NOT NULL,
    total_amount     DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
    discount_amount  DECIMAL(12,2) DEFAULT 0 CHECK (discount_amount >= 0),

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),

    CONSTRAINT fk_orders_store
        FOREIGN KEY (store_id) REFERENCES STORES(store_id)
);

-- ======================
-- 5. ORDER_LINES
-- ======================
CREATE TABLE ORDER_LINES (
    order_line_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id         INT NOT NULL,
    product_id       INT NOT NULL,
    quantity         INT NOT NULL CHECK (quantity > 0),
    line_price       DECIMAL(12,2) NOT NULL CHECK (line_price >= 0),

    CONSTRAINT fk_ol_order
        FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),

    CONSTRAINT fk_ol_product
        FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id)
);
