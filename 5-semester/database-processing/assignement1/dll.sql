
    -- Create tables for managing events, ticket types, customer orders, order lines, and an audit log.
    -- Define appropriate primary keys, foreign keys, data types, and constraints.
    -- Ensure referential integrity between related entities (e.g., orders linked to events and ticket types).
    -- Use meaningful column names and comments to describe the purpose of each table.



DROP TABLE EVENTS CASCADE CONSTRAINTS;
DROP TABLE TICKET_TYPES CASCADE CONSTRAINTS;
DROP TABLE CUSTOMERS CASCADE CONSTRAINTS;
DROP TABLE ORDERS CASCADE CONSTRAINTS;
DROP TABLE ORDER_LINES CASCADE CONSTRAINTS;
DROP TABLE AUDIT_LOG CASCADE CONSTRAINTS;


CREATE TABLE EVENTS (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    max_visitors_count NUMBER NOT NULL,
    title VARCHAR2(255) NOT NULL,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    updated_at TIMESTAMP DEFAULT systimestamp NOT NULL,
    created_at TIMESTAMP DEFAULT systimestamp NOT NULL
); 

CREATE TABLE TICKET_TYPES (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_id NUMBER NOT NULL, 
    name VARCHAR2(255) NOT NULL,
    priority_level NUMBER NOT NULL CHECK (priority_level >= 0 AND priority_level <= 10),
    price NUMBER(10, 2) NOT NULL CHECK (price >= 0),
    max_amount NUMBER NOT NULL,
    updated_at TIMESTAMP DEFAULT systimestamp NOT NULL,
    created_at TIMESTAMP DEFAULT systimestamp NOT NULL,
    CONSTRAINT fk_ticket_types_event_id FOREIGN KEY (event_id) REFERENCES EVENTS(id)
);

CREATE TABLE CUSTOMERS (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR2(255) NOT NULL,
    last_name VARCHAR2(255) NOT NULL,
    updated_at TIMESTAMP DEFAULT systimestamp NOT NULL,
    created_at TIMESTAMP DEFAULT systimestamp NOT NULL
);

CREATE TABLE ORDERS (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    items_amount NUMBER,
    total_price NUMBER,
    updated_at TIMESTAMP DEFAULT systimestamp NOT NULL,
    created_at TIMESTAMP DEFAULT systimestamp NOT NULL,
    CONSTRAINT fk_orders_customer_id FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(id)
);

CREATE TABLE ORDER_LINES (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_id NUMBER,
    ticket_type_id NUMBER,
    order_id NUMBER,
    updated_at TIMESTAMP DEFAULT systimestamp NOT NULL,
    created_at TIMESTAMP DEFAULT systimestamp NOT NULL,
    CONSTRAINT fk_order_lines_event_id FOREIGN KEY (event_id) REFERENCES EVENTS(id),
    CONSTRAINT fk_order_lines_order_id FOREIGN KEY (order_id) REFERENCES ORDERS(id),
    CONSTRAINT fk_order_ticket_type_id FOREIGN KEY (ticket_type_id) REFERENCES TICKET_TYPES(id)
);

CREATE TABLE AUDIT_LOG (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name VARCHAR2(255) NOT NULL,
    record_id VARCHAR2(255) NOT NULL,
    action_type VARCHAR2(20) NOT NULL,
    changed_by VARCHAR2(255) DEFAULT USER,
    changed_at TIMESTAMP DEFAULT systimestamp NOT NULL
);