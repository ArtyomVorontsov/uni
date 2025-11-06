/* ============================================================
   DATA INSERT SCRIPT: SAMPLE INITIAL DATA FOR TESTING
   Includes:
   - Events
   - Ticket types
   - Customers
   - Orders & Order lines (with capacity boundary cases)
   ============================================================ */

-- ============================================================
-- Insert sample Events
-- max_visitors_count = max total visitors the event can handle
-- title               = event name
-- start_date/end_date = event timeframe
-- ============================================================

-- Event #1
INSERT INTO EVENTS (max_visitors_count, title, start_date, end_date)
VALUES (100, 'Tech Conference 2025',
        TIMESTAMP '2025-05-01 10:00:00',
        TIMESTAMP '2025-05-01 20:00:00');

-- Event #2
INSERT INTO EVENTS (max_visitors_count, title, start_date, end_date)
VALUES (50, 'Music Festival',
        TIMESTAMP '2025-06-10 14:00:00',
        TIMESTAMP '2025-06-10 23:00:00');


-- ============================================================
-- Insert Ticket Types for each event
-- name          = ticket category
-- priority_level= higher means more exclusive
-- price         = ticket cost
-- max_amount    = allowed number of tickets of this type
-- ============================================================

-- Ticket types for Event #1 (Tech Conference)
INSERT INTO TICKET_TYPES (event_id, name, priority_level, price, max_amount)
VALUES (1, 'Standard', 1, 50.00, 70);   -- 70 standard tickets available

INSERT INTO TICKET_TYPES (event_id, name, priority_level, price, max_amount)
VALUES (1, 'VIP', 5, 120.00, 30);      -- 30 VIP tickets available

-- Ticket types for Event #2 (Music Festival)
INSERT INTO TICKET_TYPES (event_id, name, priority_level, price, max_amount)
VALUES (2, 'General Admission', 1, 30.00, 40); -- General tickets: 40 available

INSERT INTO TICKET_TYPES (event_id, name, priority_level, price, max_amount)
VALUES (2, 'Backstage Pass', 8, 80.00, 10);    -- Backstage passes: 10 available


-- ============================================================
-- Insert Customers
-- These users will place orders later
-- ============================================================

INSERT INTO CUSTOMERS (first_name, last_name) VALUES ('John', 'Smith');
INSERT INTO CUSTOMERS (first_name, last_name) VALUES ('Anna', 'Kowalski');
INSERT INTO CUSTOMERS (first_name, last_name) VALUES ('Peter', 'Lee');


-- ============================================================
-- Insert Orders and Order Lines
-- Orders represent customer purchases
-- ORDER_LINES represent individual tickets purchased in an order
-- ============================================================

-- ------------------------------------------------------------
-- Order 1: Normal purchase (John Smith)
-- Contains a mixture of Standard and VIP tickets
-- ------------------------------------------------------------
INSERT INTO ORDERS (customer_id)
VALUES (1); -- John Smith

-- Order lines linked to Order #1 (order_id = 1)
INSERT INTO ORDER_LINES (event_id, ticket_type_id, order_id)
VALUES (1, 1, 1); -- Standard ticket for Tech Conference

INSERT INTO ORDER_LINES (event_id, ticket_type_id, order_id)
VALUES (1, 2, 1); -- VIP ticket

INSERT INTO ORDER_LINES (event_id, ticket_type_id, order_id)
VALUES (1, 1, 1); -- Another Standard ticket


-- ------------------------------------------------------------
-- Order 2: Boundary test for capacity
-- 68 Standard tickets are purchased - near the max capacity (70)
-- Expected: should succeed, trigger should allow this
-- ------------------------------------------------------------
INSERT INTO ORDERS (customer_id)
VALUES (2); -- Anna Kowalski

BEGIN
  -- Loop inserts 68 STANDARD tickets into this order (ticket_type_id = 1)
  FOR i IN 1..68 LOOP
    INSERT INTO ORDER_LINES (event_id, ticket_type_id, order_id)
    VALUES (1, 1, 2);
  END LOOP;
END;
/
-- Order 2 total Standard tickets purchased so far = 68


-- ------------------------------------------------------------
-- Order 3: Invalid case - should exceed ticket capacity
-- After previous orders, Standard tickets sold:
-- Order 1: 2 tickets
-- Order 2: 68 tickets
-- Total:   70 (which equals max_amount)
--
-- This next insert tries to add the 71st Standard ticket
-- Trigger trg_validate_ticket_capacity should block this insert
-- ------------------------------------------------------------
INSERT INTO ORDERS (customer_id)
VALUES (3); -- Peter Lee

INSERT INTO ORDER_LINES (event_id, ticket_type_id, order_id)
VALUES (1, 1, 3);  -- Attempt to exceed Standard ticket capacity
-- Expected result: INSERT FAILS due to trigger enforcement
