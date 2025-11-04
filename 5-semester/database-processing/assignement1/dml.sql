
-- ===============================================
-- INSERT SAMPLE DATA
-- ===============================================

-- --- Events ---
INSERT INTO EVENTS (max_visitors_count, title, start_date, end_date)
VALUES (100, 'Tech Conference 2025', TIMESTAMP '2025-05-01 10:00:00', TIMESTAMP '2025-05-01 20:00:00');

INSERT INTO EVENTS (max_visitors_count, title, start_date, end_date)
VALUES (50, 'Music Festival', TIMESTAMP '2025-06-10 14:00:00', TIMESTAMP '2025-06-10 23:00:00');

-- --- Ticket Types ---
-- Event 1: Tech Conference
INSERT INTO TICKET_TYPES (event_id, name, priority_level, price, max_amount)
VALUES (1, 'Standard', 1, 50.00, 70);

INSERT INTO TICKET_TYPES (event_id, name, priority_level, price, max_amount)
VALUES (1, 'VIP', 5, 120.00, 30);

-- Event 2: Music Festival
INSERT INTO TICKET_TYPES (event_id, name, priority_level, price, max_amount)
VALUES (2, 'General Admission', 1, 30.00, 40);

INSERT INTO TICKET_TYPES (event_id, name, priority_level, price, max_amount)
VALUES (2, 'Backstage Pass', 8, 80.00, 10);

-- --- Customers ---
INSERT INTO CUSTOMERS (first_name, last_name) VALUES ('John', 'Smith');
INSERT INTO CUSTOMERS (first_name, last_name) VALUES ('Anna', 'Kowalski');
INSERT INTO CUSTOMERS (first_name, last_name) VALUES ('Peter', 'Lee');

-- --- Orders ---
-- Order 1: Valid, normal purchase
INSERT INTO ORDERS (customer_id, items_amount, total_price)
VALUES (1, 3, 220.00);

INSERT INTO ORDER_LINES (event_id, ticket_type_id, order_id)
VALUES (1, 1, 1); -- Standard
INSERT INTO ORDER_LINES (event_id, ticket_type_id, order_id)
VALUES (1, 2, 1); -- VIP
INSERT INTO ORDER_LINES (event_id, ticket_type_id, order_id)
VALUES (1, 1, 1); -- Standard

-- Order 2: Boundary, near-capacity (70 Standard tickets for Event 1)
INSERT INTO ORDERS (customer_id, items_amount, total_price)
VALUES (2, 70, 3500.00);

BEGIN
  FOR i IN 1..70 LOOP
    INSERT INTO ORDER_LINES (event_id, ticket_type_id, order_id)
    VALUES (1, 1, 2);
  END LOOP;
END;
/

-- Order 3: Invalid (exceeds capacity, should trigger business rule)
INSERT INTO ORDERS (customer_id, items_amount, total_price)
VALUES (3, 1, 50.00);

INSERT INTO ORDER_LINES (event_id, ticket_type_id, order_id)
VALUES (1, 1, 3); -- This exceeds Standard max_amount (70)
-- Expected: Should fail if trigger/validation applied

-- ===============================================
-- End of Script
-- ===============================================
