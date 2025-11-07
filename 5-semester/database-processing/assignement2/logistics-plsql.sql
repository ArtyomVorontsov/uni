-- 3. PL/SQL Logic (Procedures and Functions Script)
--     Create at least three procedures and two functions that together implement business operations such as:
--         Registering a new shipment, validating product availability, and reducing warehouse stock.
--         Calculating total shipment cost based on weight, distance, or product type.
--         Updating delivery status once a shipment is completed.
--         Retrieving shipment summaries or driver performance statistics.
--     Each subprogram must include appropriate parameters and return types (e.g., IN, OUT, RETURN).
--     Include exception handling that prints meaningful messages using DBMS_OUTPUT.
--     Each procedure or function must contain clear comments explaining its purpose and logic.
--     The code must not contain commits or rollbacks inside the subprograms.
------------------------------------------------------------------------
-- FUNCTION: calculate_total_shipment_cost
-- PURPOSE: Calculates the total delivery cost for a specific shipment.
-- LOGIC:
--   1. Sum up the total weight of all products in the shipment.
--   2. Multiply the total weight by the shipment distance and a pricing
--      coefficient (0.001) to get the final cost.
--      This coefficient represents the delivery pricing formula.
------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION calculate_total_shipment_cost (shipment_id IN NUMBER) RETURN NUMBER AS -- Variable to store the calculated total delivery price
v_total_delivery_price NUMBER;

-- Variable to store the total weight of all products in this shipment
v_total_weight NUMBER;

BEGIN --------------------------------------------------------------------
-- Step 1: Calculate the total shipment weight
--         Multiply product weight by quantity for each product in
--         the shipment and sum all results.
--------------------------------------------------------------------
SELECT
    SUM(p.weight * sl.quantity) INTO v_total_weight
FROM
    SHIPMENT_LINES sl
    JOIN PRODUCTS p ON p.id = sl.product_id
WHERE
    sl.shipment_id = shipment_id;

--------------------------------------------------------------------
-- Step 2: Compute total delivery cost
--         Formula: (distance * total_weight * 0.001)
--         The 0.001 value acts as a pricing coefficient to model
--         how distance and weight affect delivery cost.
--------------------------------------------------------------------
SELECT
    (s.distance * v_total_weight * 0.001) INTO v_total_delivery_price
FROM
    SHIPMENTS s
WHERE
    s.id = shipment_id;

--------------------------------------------------------------------
-- Step 3: Return the calculated total delivery price
--------------------------------------------------------------------
RETURN v_total_delivery_price;

END;

/ ------------------------------------------------------------------------
-- Example usage: Calculate the total shipment cost for shipment ID = 1
------------------------------------------------------------------------
SELECT
    calculate_total_shipment_cost(1) AS total_cost
FROM
    dual;

------------------------------------------------------------------------
-- FUNCTION: calculate_driver_perfomance_average_score
-- PURPOSE: Calculates the average delivery performance score for a driver.
-- LOGIC:
--   1. Sum all delivery scores for shipments handled by the driver.
--   2. Count how many shipments the driver completed.
--   3. Compute the average score as total_score / total_shipments.
--   4. Return NULL if the driver has no shipments.
------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION calculate_driver_perfomance_average_score (driver_id IN NUMBER) RETURN NUMBER AS -- Variable to store the computed average performance score
v_driver_performance_average_score NUMBER;

-- Variable to store the total number of shipments handled by the driver
v_total_shipment_amount NUMBER;

-- Variable to store the total accumulated delivery scores
v_total_shipment_score_value NUMBER;

BEGIN --------------------------------------------------------------------
-- Step 1: Sum all delivery scores for shipments done by this driver
--------------------------------------------------------------------
SELECT
    SUM(s.delivery_score) INTO v_total_shipment_score_value
FROM
    SHIPMENTS s
WHERE
    s.delivery_responsible_driver_id = driver_id;

--------------------------------------------------------------------
-- Step 2: Count how many shipments this driver completed
--------------------------------------------------------------------
SELECT
    COUNT(*) INTO v_total_shipment_amount
FROM
    SHIPMENTS s
WHERE
    s.delivery_responsible_driver_id = driver_id;

--------------------------------------------------------------------
-- Step 3: Compute average performance score
--         If driver has shipments, divide total score by shipment count.
--         Otherwise, return NULL to indicate no data.
--------------------------------------------------------------------
IF v_total_shipment_amount > 0 THEN v_driver_performance_average_score := v_total_shipment_score_value / v_total_shipment_amount;

ELSE v_driver_performance_average_score := NULL;

END IF;

--------------------------------------------------------------------
-- Step 4: Return the calculated average score
--------------------------------------------------------------------
RETURN v_driver_performance_average_score;

END;

/ ------------------------------------------------------------------------
-- Example usage: Calculate driver average performance score for driver ID = 1
------------------------------------------------------------------------
SELECT
    calculate_driver_perfomance_average_score(1) AS avg_score
FROM
    dual;

------------------------------------------------------------------------
-- PROCEDURE: register_new_shipment
-- PURPOSE:
--     Registers a new shipment, checks if the requested product quantity
--     is available in stock, reduces the product stock accordingly,
--     and records the shipment and shipment line information.
--
-- PARAMETERS:
--     v_shipment_date                - Date when the shipment is created
--     v_distance                     - Distance of delivery (in meters or km)
--     v_delivery_responsible_driver_id - ID of the driver responsible for the delivery
--     v_product_id                   - ID of the product being shipped
--     v_quantity                     - Quantity of the product to ship
--
-- NOTES:
--     - If the requested quantity exceeds available stock, the procedure 
--       raises an application error.
--     - No commits or rollbacks are performed inside this procedure.
------------------------------------------------------------------------
CREATE
OR REPLACE PROCEDURE register_new_shipment (
    v_shipment_date IN DATE,
    v_distance IN NUMBER,
    v_delivery_responsible_driver_id IN NUMBER,
    v_product_id IN NUMBER,
    v_quantity IN NUMBER
) AS v_stock_quantity NUMBER;

-- Current stock quantity of the selected product
v_new_shipment_id NUMBER;

-- Variable to hold the newly created shipment ID
BEGIN --------------------------------------------------------------------
-- 1. Validate product availability
--    Check if enough products are available in the warehouse
--------------------------------------------------------------------
SELECT
    stock_quantity INTO v_stock_quantity
FROM
    PRODUCTS p
WHERE
    p.id = v_product_id;

--------------------------------------------------------------------
-- 2. Compare available quantity with requested quantity
--------------------------------------------------------------------
IF v_stock_quantity >= v_quantity THEN ----------------------------------------------------------------
-- 2.1. Reduce product stock if sufficient quantity exists
----------------------------------------------------------------
UPDATE
    PRODUCTS
SET
    stock_quantity = stock_quantity - v_quantity
WHERE
    id = v_product_id;

ELSE ----------------------------------------------------------------
-- 2.2. Throw an error if there is not enough stock
----------------------------------------------------------------
RAISE_APPLICATION_ERROR(
    -20001,
    'Error: Not enough products left in stock.'
);

END IF;

--------------------------------------------------------------------
-- 3. Register a new shipment
--    Insert a record into SHIPMENTS and retrieve its generated ID
--------------------------------------------------------------------
INSERT INTO
    SHIPMENTS (
        delivery_responsible_driver_id,
        shipment_date,
        distance
    )
VALUES
    (
        v_delivery_responsible_driver_id,
        v_shipment_date,
        v_distance
    ) RETURNING id INTO v_new_shipment_id;

--------------------------------------------------------------------
-- 4. Register a new shipment line
--    Link the product and quantity to the newly created shipment
--------------------------------------------------------------------
INSERT INTO
    SHIPMENT_LINES (shipment_id, product_id, quantity)
VALUES
    (v_new_shipment_id, v_product_id, v_quantity);

--------------------------------------------------------------------
-- 5. Notify success
--------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE(
    'New shipment registered successfully with ID: ' || v_new_shipment_id
);

EXCEPTION --------------------------------------------------------------------
-- 6. Exception handling
--    Handle cases when no product is found or unexpected errors occur
--------------------------------------------------------------------
WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(
    'Error: Product with ID ' || v_product_id || ' not found.'
);

WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);

END;

/ ------------------------------------------------------------------------
-- TEST CALL: Example usage of the register_new_shipment procedure
------------------------------------------------------------------------
BEGIN register_new_shipment(
    v_shipment_date = > SYSDATE,
    v_distance = > 120,
    v_delivery_responsible_driver_id = > 1,
    v_product_id = > 1,
    v_quantity = > 5
);

END;

/ -- ============================================================
-- PROCEDURE: complete_shipment
-- PURPOSE: Updates a shipment's delivery status to 'Delivered'
--          when the shipment is completed, assigns a delivery score,
--          and updates the shipment date to the current system date.
-- PARAMETERS:
--   v_shipment_id     - ID of the shipment to be marked as delivered
--   v_delivery_score  - Delivery quality score given for the shipment
-- ============================================================
CREATE
OR REPLACE PROCEDURE complete_shipment (
    v_shipment_id IN NUMBER,
    -- Input: shipment ID to update
    v_delivery_score IN NUMBER -- Input: delivery performance score
) AS BEGIN -- Update the SHIPMENTS table to mark shipment as delivered
UPDATE
    SHIPMENTS
SET
    delivery_status = 'Delivered',
    -- Set status to 'Delivered'
    delivery_score = v_delivery_score,
    -- Record provided delivery score
    shipment_date = SYSDATE -- Update shipment date to current date/time
WHERE
    id = v_shipment_id;

-- Match the target shipment by ID
-- Display confirmation message in output console
DBMS_OUTPUT.PUT_LINE('Shipment marked as delivered.');

END;

/ -- ============================================================
-- TEST BLOCK
-- Description: Executes the procedure with example values.
-- ============================================================
BEGIN complete_shipment(
    v_shipment_id = > 21,
    -- Example shipment ID
    v_delivery_score = > 8 -- Example delivery score (out of 10)
);

END;

/