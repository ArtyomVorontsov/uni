/* =============================================================
   CLEANUP: Drop all tables if they already exist
   CASCADE CONSTRAINTS ensures dependent FKs are removed as well
   ============================================================= */
DROP TABLE EVENTS CASCADE CONSTRAINTS;
DROP TABLE TICKET_TYPES CASCADE CONSTRAINTS;
DROP TABLE CUSTOMERS CASCADE CONSTRAINTS;
DROP TABLE ORDERS CASCADE CONSTRAINTS;
DROP TABLE ORDER_LINES CASCADE CONSTRAINTS;
DROP TABLE AUDIT_LOG CASCADE CONSTRAINTS;



/* =============================================================
   CREATE TABLE: EVENTS
   Stores event-level data
   - max_visitors_count = total number of visitors allowed
   - title = event name
   - start/end date = time window for the event
   - created_at / updated_at = audit timestamps
   ============================================================= */
CREATE TABLE EVENTS (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Auto-increment PK
    max_visitors_count NUMBER NOT NULL,                -- Max allowed visitors (all ticket types combined)
    title VARCHAR2(255) NOT NULL,                      -- Name of the event
    start_date TIMESTAMP,                              -- Start timestamp
    end_date TIMESTAMP,                                -- End timestamp
    updated_at TIMESTAMP DEFAULT systimestamp NOT NULL,-- Updated timestamp (trigger-maintained)
    created_at TIMESTAMP DEFAULT systimestamp NOT NULL -- Created timestamp
);



/* =============================================================
   CREATE TABLE: TICKET_TYPES
   Ticket types per event (e.g., Standard, VIP)
   - priority_level = UI sorting / importance indicator (0–10 scale)
   - price = ticket price
   - max_amount = ticket capacity limit for this type
   - event_id FK → EVENTS table
   ============================================================= */
CREATE TABLE TICKET_TYPES (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Auto-increment PK
    event_id NUMBER NOT NULL,                           -- FK to EVENTS(id)
    name VARCHAR2(255) NOT NULL,                        -- Ticket name (Standard, VIP, etc.)
    priority_level NUMBER NOT NULL                      -- Priority (0..10, validation below)
        CHECK (priority_level >= 0 AND priority_level <= 10),
    price NUMBER(10, 2) NOT NULL                        -- Ticket price
        CHECK (price >= 0),
    max_amount NUMBER NOT NULL,                         -- Maximum number of tickets of this type allowed
    updated_at TIMESTAMP DEFAULT systimestamp NOT NULL, -- Updated timestamp (trigger-maintained)
    created_at TIMESTAMP DEFAULT systimestamp NOT NULL, -- Created timestamp
    CONSTRAINT fk_ticket_types_event_id
        FOREIGN KEY (event_id) REFERENCES EVENTS(id)    -- Enforce event reference
);



/* =============================================================
   CREATE TABLE: CUSTOMERS
   Stores customer personal information
   ============================================================= */
CREATE TABLE CUSTOMERS (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Auto-increment PK
    first_name VARCHAR2(255) NOT NULL,                  -- Customer first name
    last_name VARCHAR2(255) NOT NULL,                   -- Customer last name
    updated_at TIMESTAMP DEFAULT systimestamp NOT NULL, -- Updated timestamp
    created_at TIMESTAMP DEFAULT systimestamp NOT NULL  -- Created timestamp
);



/* =============================================================
   CREATE TABLE: ORDERS
   Represents a single customer order.
   - customer_id FK → CUSTOMERS table
   - items_amount and total_price are automatically maintained via triggers
   ============================================================= */
CREATE TABLE ORDERS (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Auto-increment PK
    customer_id NUMBER NOT NULL,                        -- FK to CUSTOMERS(id)
    items_amount NUMBER,                                -- Total number of tickets purchased in order
    total_price NUMBER,                                 -- Total cost of tickets (sum)
    updated_at TIMESTAMP DEFAULT systimestamp NOT NULL, -- Updated timestamp
    created_at TIMESTAMP DEFAULT systimestamp NOT NULL, -- Created timestamp
    CONSTRAINT fk_orders_customer_id
        FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(id)
);



/* =============================================================
   CREATE TABLE: ORDER_LINES
   Represents an individual ticket purchase inside an order
   - One ORDER may have multiple ORDER_LINES
   - Connects ticket type and event to the order
   ============================================================= */
CREATE TABLE ORDER_LINES (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Auto-increment PK
    event_id NUMBER,                                    -- FK: what event this ticket belongs to
    ticket_type_id NUMBER,                              -- FK: what ticket type (VIP, Standard, etc.)
    order_id NUMBER,                                    -- FK: order that contains this ticket
    updated_at TIMESTAMP DEFAULT systimestamp NOT NULL, -- Updated timestamp
    created_at TIMESTAMP DEFAULT systimestamp NOT NULL, -- Created timestamp
    CONSTRAINT fk_order_lines_event_id
        FOREIGN KEY (event_id) REFERENCES EVENTS(id),
    CONSTRAINT fk_order_lines_order_id
        FOREIGN KEY (order_id) REFERENCES ORDERS(id),
    CONSTRAINT fk_order_ticket_type_id
        FOREIGN KEY (ticket_type_id) REFERENCES TICKET_TYPES(id)
);



/* =============================================================
   CREATE TABLE: AUDIT_LOG
   Generic audit table storing record of changes (INSERT/UPDATE/DELETE)
   Data is written via triggers
   ============================================================= */
CREATE TABLE AUDIT_LOG (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- Auto-increment PK
    table_name VARCHAR2(255) NOT NULL,                  -- Table where something changed
    record_id VARCHAR2(255) NOT NULL,                   -- PK of changed record
    action_type VARCHAR2(20) NOT NULL,                  -- INSERT, UPDATE, DELETE
    changed_by VARCHAR2(255) DEFAULT USER,              -- Logged Oracle username
    changed_at TIMESTAMP DEFAULT systimestamp NOT NULL  -- Timestamp of change
);
