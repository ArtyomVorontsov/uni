CREATE OR REPLACE TRIGGER trg_events_set_updated_at 
BEFORE UPDATE ON EVENTS 
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