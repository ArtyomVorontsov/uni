-- =========================================
-- WAREHOUSES
-- =========================================
INSERT INTO
    WAREHOUSES (title, capacity)
VALUES
    ('Riga Central Warehouse', 10000);

INSERT INTO
    WAREHOUSES (title, capacity)
VALUES
    ('Liepaja Coastal Warehouse', 7000);

INSERT INTO
    WAREHOUSES (title, capacity)
VALUES
    ('Daugavpils Regional Warehouse', 5000);

-- =========================================
-- DRIVERS
-- =========================================
INSERT INTO
    DRIVERS (first_name, last_name)
VALUES
    ('Janis', 'Ozols');

INSERT INTO
    DRIVERS (first_name, last_name)
VALUES
    ('Marta', 'Liepa');

INSERT INTO
    DRIVERS (first_name, last_name)
VALUES
    ('Arturs', 'Kalnins');

-- =========================================
-- PRODUCTS
-- =========================================
INSERT INTO
    PRODUCTS (title, category_id, warehouse_id, cost, weight, stock_quantity)
VALUES
    ('Laptop', 1, 1, 850.00, 2.5, 10);

INSERT INTO
    PRODUCTS (title, category_id, warehouse_id, cost, weight, stock_quantity)
VALUES
    ('Smartphone', 1, 1, 600.00, 0.4, 10);

INSERT INTO
    PRODUCTS (title, category_id, warehouse_id, cost, weight, stock_quantity)
VALUES
    ('Tablet', 1, 2, 450.00, 0.8, 10);

INSERT INTO
    PRODUCTS (title, category_id, warehouse_id, cost, weight, stock_quantity)
VALUES
    ('Desktop PC', 1, 2, 1200.00, 8.0, 10);

INSERT INTO
    PRODUCTS (title, category_id, warehouse_id, cost, weight, stock_quantity)
VALUES
    ('Monitor', 2, 3, 250.00, 4.0, 10);

INSERT INTO
    PRODUCTS (title, category_id, warehouse_id, cost, weight, stock_quantity)
VALUES
    ('Keyboard', 2, 3, 60.00, 0.7, 10);

-- =========================================
-- SHIPMENTS
-- (Both delivered and pending examples)
-- =========================================
INSERT INTO
    SHIPMENTS (
        delivery_responsible_driver_id,
        delivery_status,
        shipment_date,
        distance,
        delivery_score
    )
VALUES
    (
        1,
        'Delivered',
        TO_DATE('2025-11-01', 'YYYY-MM-DD'),
        2000,
        7
    );

INSERT INTO
    SHIPMENTS (
        delivery_responsible_driver_id,
        delivery_status,
        shipment_date,
        distance,
        delivery_score
    )
VALUES
    (
        2,
        'Pending',
        TO_DATE('2025-11-06', 'YYYY-MM-DD'),
        1000,
        3
    );

INSERT INTO
    SHIPMENTS (
        delivery_responsible_driver_id,
        delivery_status,
        shipment_date,
        distance,
        delivery_score
    )
VALUES
    (
        3,
        'Delivered',
        TO_DATE('2025-10-28', 'YYYY-MM-DD'),
        3000,
        8
    );

-- =========================================
-- SHIPMENT LINES
-- (Each shipment delivers certain products)
-- =========================================
-- Shipment 1 (Delivered)
INSERT INTO
    SHIPMENT_LINES (shipment_id, product_id, quantity)
VALUES
    (1, 1, 3);

-- 3 Laptops
INSERT INTO
    SHIPMENT_LINES (shipment_id, product_id, quantity)
VALUES
    (1, 2, 5);

-- 5 Smartphones
-- Shipment 2 (Pending)
INSERT INTO
    SHIPMENT_LINES (shipment_id, product_id, quantity)
VALUES
    (2, 3, 2);

-- 2 Tablets
INSERT INTO
    SHIPMENT_LINES (shipment_id, product_id, quantity)
VALUES
    (2, 4, 1);

-- 1 Desktop PC
-- Shipment 3 (Delivered)
INSERT INTO
    SHIPMENT_LINES (shipment_id, product_id, quantity)
VALUES
    (3, 5, 4);

-- 4 Monitors
INSERT INTO
    SHIPMENT_LINES (shipment_id, product_id, quantity)
VALUES
    (3, 6, 6);

-- 6 Keyboards
-- =========================================
-- INVALID CASE: Shipment exceeding available stock
-- (Example: trying to ship 999 units of a product not available in that quantity)
-- =========================================
INSERT INTO
    SHIPMENTS (
        delivery_responsible_driver_id,
        delivery_status,
        shipment_date,
        distance,
        delivery_score
    )
VALUES
    (
        1,
        'Pending',
        TO_DATE('2025-11-06', 'YYYY-MM-DD'),
        500,
        7
    );

INSERT INTO
    SHIPMENT_LINES (shipment_id, product_id, quantity)
VALUES
    (4, 1, 999);

-- Exceeds available stock (should fail)