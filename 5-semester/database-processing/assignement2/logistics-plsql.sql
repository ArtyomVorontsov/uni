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


-- FUNCTION - Calculating total shipment cost based on weight, distance, or product type.
-- PROCEDURE - Registering a new shipment, validating product availability, and reducing warehouse stock.
-- PROCEDURE - Updating delivery status once a shipment is completed.
-- FUNCTION - Retrieving shipment summaries or driver performance statistics.
CREATE
OR REPLACE FUNCTION calculate_total_shipment_cost (shipment_id IN NUMBER) RETURN NUMBER AS v_total_delivery_price NUMBER;

v_distance NUMBER;

v_total_weight NUMBER;

BEGIN

SELECT
    SUM(p.weight * sl.quantity) INTO v_total_weight
FROM
    SHIPMENT_LINES sl
    JOIN PRODUCTS p ON p.id = sl.product_id
WHERE
    sl.shipment_id = shipment_id;

SELECT
    ((s.distance * 0.001) * v_total_weight) into v_total_delivery_price
FROM
    SHIPMENTS s
WHERE
    s.id = shipment_id;
RETURN v_total_delivery_price;

END;

/

SELECT calculate_total_shipment_cost(1) AS total_cost FROM dual;
