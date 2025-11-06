

/* Handle ticket capacity */

CREATE OR REPLACE TRIGGER trg_validate_ticket_capacity
BEFORE INSERT ON ORDER_LINES
FOR EACH ROW
DECLARE
    v_sold_count NUMBER;
    v_max_allowed NUMBER;
BEGIN
    -- Get how many tickets were already sold for this ticket type
    SELECT COUNT(*)
    INTO v_sold_count
    FROM ORDER_LINES
    WHERE ticket_type_id = :NEW.ticket_type_id;

    -- Get the max allowed for this ticket type
    SELECT max_amount
    INTO v_max_allowed
    FROM TICKET_TYPES
    WHERE id = :NEW.ticket_type_id;

    -- Validation
    IF v_sold_count >= v_max_allowed THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Ticket capacity exceeded: no more tickets available for this ticket type.');
    END IF;
END;
/


/* Handle order number of tickets */

CREATE OR REPLACE TRIGGER trg_update_order_items_amount
AFTER INSERT OR UPDATE OR DELETE ON ORDER_LINES
DECLARE
BEGIN
    UPDATE ORDERS o
    SET o.items_amount =
        ( SELECT COUNT(*)
          FROM ORDER_LINES ol
          WHERE ol.order_id = o.id );
END;
/


/* Handle order total price of tickets */

CREATE OR REPLACE TRIGGER trg_update_order_total_price
AFTER INSERT OR UPDATE OR DELETE ON ORDER_LINES
DECLARE
BEGIN
    UPDATE ORDERS o
    SET o.total_price =
        ( SELECT NVL(SUM(tt.price), 0)
          FROM ORDER_LINES ol
          JOIN TICKET_TYPES tt ON tt.id = ol.ticket_type_id
          WHERE ol.order_id = o.id );
END;
/


/* Handle updated_at field */

CREATE OR REPLACE TRIGGER trg_events_set_updated_at 
BEFORE UPDATE ON EVENTS 
FOR EACH ROW 
DECLARE 
BEGIN 
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_ticket_types_set_updated_at 
BEFORE UPDATE ON TICKET_TYPES 
FOR EACH ROW 
DECLARE 
BEGIN 
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_customers_set_updated_at 
BEFORE UPDATE ON CUSTOMERS 
FOR EACH ROW 
DECLARE 
BEGIN 
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_orders_set_updated_at 
BEFORE UPDATE ON ORDERS 
FOR EACH ROW 
DECLARE 
BEGIN 
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_order_lines_set_updated_at 
BEFORE UPDATE ON ORDER_LINES 
FOR EACH ROW 
DECLARE 
BEGIN 
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_audit_log_set_updated_at 
BEFORE UPDATE ON AUDIT_LOG 
FOR EACH ROW 
DECLARE 
BEGIN 
    :NEW.updated_at := SYSTIMESTAMP;
END;
/


/* Handle audit log table */

CREATE OR REPLACE PROCEDURE write_audit_log (
    p_table_name VARCHAR2,
    p_record_id VARCHAR2,
    p_action_type VARCHAR2
) AS
BEGIN
    INSERT INTO AUDIT_LOG (table_name, record_id, action_type)
    VALUES (p_table_name, p_record_id, p_action_type);
END;
/

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