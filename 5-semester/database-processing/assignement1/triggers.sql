/* ============================================================
   TRIGGER: trg_validate_ticket_capacity
   PURPOSE: Ensure that the number of sold tickets for each
            ticket type does not exceed its maximum capacity.
   TABLE:   ORDER_LINES
   EVENT:   BEFORE INSERT
   ============================================================ */
CREATE OR REPLACE TRIGGER trg_validate_ticket_capacity
BEFORE INSERT ON ORDER_LINES
FOR EACH ROW
DECLARE
    v_sold_count NUMBER;      -- Number of tickets already sold for this ticket type
    v_max_allowed NUMBER;     -- Maximum number of tickets allowed for this ticket type
BEGIN
    -- Get how many tickets were already sold for this ticket type
    SELECT COUNT(*)
    INTO v_sold_count
    FROM ORDER_LINES
    WHERE ticket_type_id = :NEW.ticket_type_id;

    -- Get the maximum allowed ticket quantity for this ticket type
    SELECT max_amount
    INTO v_max_allowed
    FROM TICKET_TYPES
    WHERE id = :NEW.ticket_type_id;

    -- Check if capacity is reached or exceeded
    IF v_sold_count >= v_max_allowed THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Ticket capacity exceeded: no more tickets available for this ticket type.');
    END IF;
END;
/
---------------------------------------------------------------


/* ============================================================
   TRIGGER: trg_update_order_items_amount
   PURPOSE: Automatically update the number of ticket items
            in an order whenever ORDER_LINES changes.
   TABLE:   ORDER_LINES
   EVENT:   AFTER INSERT, UPDATE, or DELETE
   ============================================================ */
CREATE OR REPLACE TRIGGER trg_update_order_items_amount
AFTER INSERT OR UPDATE OR DELETE ON ORDER_LINES
DECLARE
BEGIN
    -- Update each order's items_amount to reflect current ticket count
    UPDATE ORDERS o
    SET o.items_amount =
        ( SELECT COUNT(*)
          FROM ORDER_LINES ol
          WHERE ol.order_id = o.id );
END;
/
---------------------------------------------------------------


/* ============================================================
   TRIGGER: trg_update_order_total_price
   PURPOSE: Automatically recalculate the total price of an order
            whenever ORDER_LINES changes.
   TABLE:   ORDER_LINES
   EVENT:   AFTER INSERT, UPDATE, or DELETE
   ============================================================ */
CREATE OR REPLACE TRIGGER trg_update_order_total_price
AFTER INSERT OR UPDATE OR DELETE ON ORDER_LINES
DECLARE
BEGIN
    -- Recalculate total price based on all related ORDER_LINES
    UPDATE ORDERS o
    SET o.total_price =
        ( SELECT NVL(SUM(tt.price), 0)
          FROM ORDER_LINES ol
          JOIN TICKET_TYPES tt ON tt.id = ol.ticket_type_id
          WHERE ol.order_id = o.id );
END;
/
---------------------------------------------------------------


/* ============================================================
   SECTION: Updated_at field management
   PURPOSE: Automatically set 'updated_at' to current timestamp
            whenever a record in the respective table is updated.
   ============================================================ */

/* EVENTS table */
CREATE OR REPLACE TRIGGER trg_events_set_updated_at 
BEFORE UPDATE ON EVENTS 
FOR EACH ROW 
DECLARE 
BEGIN 
    :NEW.updated_at := SYSTIMESTAMP;  -- Set updated_at to current system timestamp
END;
/

/* TICKET_TYPES table */
CREATE OR REPLACE TRIGGER trg_ticket_types_set_updated_at 
BEFORE UPDATE ON TICKET_TYPES 
FOR EACH ROW 
DECLARE 
BEGIN 
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

/* CUSTOMERS table */
CREATE OR REPLACE TRIGGER trg_customers_set_updated_at 
BEFORE UPDATE ON CUSTOMERS 
FOR EACH ROW 
DECLARE 
BEGIN 
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

/* ORDERS table */
CREATE OR REPLACE TRIGGER trg_orders_set_updated_at 
BEFORE UPDATE ON ORDERS 
FOR EACH ROW 
DECLARE 
BEGIN 
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

/* ORDER_LINES table */
CREATE OR REPLACE TRIGGER trg_order_lines_set_updated_at 
BEFORE UPDATE ON ORDER_LINES 
FOR EACH ROW 
DECLARE 
BEGIN 
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

/* AUDIT_LOG table */
CREATE OR REPLACE TRIGGER trg_audit_log_set_updated_at 
BEFORE UPDATE ON AUDIT_LOG 
FOR EACH ROW 
DECLARE 
BEGIN 
    :NEW.updated_at := SYSTIMESTAMP;
END;
/
---------------------------------------------------------------


/* ============================================================
   SECTION: AUDIT LOGGING SYSTEM
   PURPOSE: Record all data modifications (INSERT, UPDATE, DELETE)
            into the AUDIT_LOG table for traceability.
   ============================================================ */

/* PROCEDURE: write_audit_log
   Inserts a record into AUDIT_LOG capturing table name, record ID,
   and action type (INSERT/UPDATE/DELETE).
*/
CREATE OR REPLACE PROCEDURE write_audit_log (
    p_table_name VARCHAR2,    -- Name of the affected table
    p_record_id VARCHAR2,     -- ID of the affected record
    p_action_type VARCHAR2    -- Type of action performed
) AS
BEGIN
    INSERT INTO AUDIT_LOG (table_name, record_id, action_type)
    VALUES (p_table_name, p_record_id, p_action_type);
END;
/
---------------------------------------------------------------

/* TRIGGER: audit_events */
CREATE OR REPLACE TRIGGER audit_events
AFTER INSERT OR UPDATE OR DELETE ON EVENTS
FOR EACH ROW
BEGIN
    write_audit_log(
        'EVENTS',
        NVL(:OLD.id, :NEW.id),
        CASE WHEN INSERTING THEN 'INSERT'
             WHEN UPDATING THEN 'UPDATE'
             WHEN DELETING THEN 'DELETE'
        END
    );
END;
/

/* TRIGGER: audit_ticket_types */
CREATE OR REPLACE TRIGGER audit_ticket_types
AFTER INSERT OR UPDATE OR DELETE ON TICKET_TYPES
FOR EACH ROW
BEGIN
    write_audit_log(
        'TICKET_TYPES',
        NVL(:OLD.id, :NEW.id),
        CASE WHEN INSERTING THEN 'INSERT'
             WHEN UPDATING THEN 'UPDATE'
             WHEN DELETING THEN 'DELETE'
        END
    );
END;
/

/* TRIGGER: audit_customers */
CREATE OR REPLACE TRIGGER audit_customers
AFTER INSERT OR UPDATE OR DELETE ON CUSTOMERS
FOR EACH ROW
BEGIN
    write_audit_log(
        'CUSTOMERS',
        NVL(:OLD.id, :NEW.id),
        CASE WHEN INSERTING THEN 'INSERT'
             WHEN UPDATING THEN 'UPDATE'
             WHEN DELETING THEN 'DELETE'
        END
    );
END;
/

/* TRIGGER: audit_orders */
CREATE OR REPLACE TRIGGER audit_orders
AFTER INSERT OR UPDATE OR DELETE ON ORDERS
FOR EACH ROW
BEGIN
    write_audit_log(
        'ORDERS',
        NVL(:OLD.id, :NEW.id),
        CASE WHEN INSERTING THEN 'INSERT'
             WHEN UPDATING THEN 'UPDATE'
             WHEN DELETING THEN 'DELETE'
        END
    );
END;
/

/* TRIGGER: audit_order_lines */
CREATE OR REPLACE TRIGGER audit_order_lines
AFTER INSERT OR UPDATE OR DELETE ON ORDER_LINES
FOR EACH ROW
BEGIN
    write_audit_log(
        'ORDER_LINES',
        NVL(:OLD.id, :NEW.id),
        CASE WHEN INSERTING THEN 'INSERT'
             WHEN UPDATING THEN 'UPDATE'
             WHEN DELETING THEN 'DELETE'
        END
    );
END;
/
---------------------------------------------------------------
