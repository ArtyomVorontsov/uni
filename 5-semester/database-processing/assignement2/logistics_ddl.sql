/* =============================================================
 CLEANUP: Drop all tables if they already exist
 CASCADE CONSTRAINTS ensures dependent FKs are removed as well
 ============================================================= */
DROP TABLE WAREHOUSES CASCADE CONSTRAINTS;
DROP TABLE PRODUCTS CASCADE CONSTRAINTS;
DROP TABLE DRIVERS CASCADE CONSTRAINTS;
DROP TABLE SHIPMENTS CASCADE CONSTRAINTS;
DROP TABLE SHIPMENT_LINES CASCADE CONSTRAINTS;

-- =========================================
-- TABLE: WAREHOUSES
-- Stores information about physical storage locations.
-- Each warehouse has a capacity (e.g., total weight or quantity it can hold).
-- =========================================
CREATE TABLE WAREHOUSES (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR2(100) NOT NULL,
    capacity NUMBER NOT NULL
);

-- =========================================
-- TABLE: PRODUCTS
-- Represents products stored in warehouses.
-- Each product belongs to a category (could link to a CATEGORY table later)
-- and is stored in a specific warehouse.
-- =========================================
CREATE TABLE PRODUCTS (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title VARCHAR2(100) NOT NULL,
    category_id NUMBER,
    -- optional FK to CATEGORIES if created later
    warehouse_id NUMBER NOT NULL,
    stock_quantity NUMBER,
    cost NUMBER(10, 2),
    weight NUMBER(10, 2),
    CONSTRAINT fk_products_warehouse_id FOREIGN KEY (warehouse_id) REFERENCES WAREHOUSES(id)
);

-- =========================================
-- TABLE: DRIVERS
-- Contains information about truck drivers responsible for deliveries.
-- =========================================
CREATE TABLE DRIVERS (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL
);

-- =========================================
-- TABLE: SHIPMENTS
-- Represents a delivery operation handled by a specific driver.
-- Each shipment has a delivery status (e.g., Pending, In Transit, Delivered).
-- =========================================
CREATE TABLE SHIPMENTS (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    delivery_responsible_driver_id NUMBER NOT NULL,
    delivery_status VARCHAR2(50) DEFAULT 'Pending',
    shipment_date DATE DEFAULT SYSDATE,
    delivery_score NUMBER,
    distance NUMBER,
    CONSTRAINT fk_shipments_driver FOREIGN KEY (delivery_responsible_driver_id) REFERENCES DRIVERS(id)
);

-- =========================================
-- TABLE: SHIPMENT_LINES
-- Line items of each shipment: which products and how many units are sent.
-- =========================================
CREATE TABLE SHIPMENT_LINES (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shipment_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    quantity NUMBER NOT NULL CHECK (quantity > 0),
    CONSTRAINT fk_shipment_lines_shipment_id FOREIGN KEY (shipment_id) REFERENCES SHIPMENTS(id) ON DELETE CASCADE,
    CONSTRAINT fk_shipment_lines_product_id FOREIGN KEY (product_id) REFERENCES PRODUCTS(id)
);