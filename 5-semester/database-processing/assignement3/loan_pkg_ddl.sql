/*******************************************************
 * Author:      Artjoms Voroncovs
 * Date:        29-NOV-2025
 * Description: Schema creation script for a simple 
 *              loan management system. This file:
 *              - Drops existing tables (AUDIT_LOG, 
 *                LOAN_PAYMENTS, LOAN_APPLICATIONS, CUSTOMERS)
 *              - Creates tables with constraints, including:
 *                CUSTOMERS, LOAN_APPLICATIONS, LOAN_PAYMENTS,
 *                AUDIT_LOG
 *              - Defines primary keys, foreign keys, 
 *                NOT NULL constraints, default values, 
 *                and check constraints for data integrity.
 *******************************************************/

DROP TABLE AUDIT_LOG;
DROP TABLE LOAN_PAYMENTS;
DROP TABLE LOAN_APPLICATIONS;
DROP TABLE CUSTOMERS;

-------------------------------------------------------------
-- CUSTOMERS
-------------------------------------------------------------
CREATE TABLE CUSTOMERS (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR2(255) NOT NULL,
    credit_profile VARCHAR2(255) NOT NULL,
    created_at DATE DEFAULT SYSDATE NOT NULL
);

-------------------------------------------------------------
-- LOAN_APPLICATIONS
-------------------------------------------------------------
CREATE TABLE LOAN_APPLICATIONS (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    loan_amount NUMBER NOT NULL CHECK (loan_amount > 0),
    interest_rate NUMBER NOT NULL CHECK (interest_rate >= 0 AND interest_rate <= 100),
    payment_period NUMBER NOT NULL CHECK (payment_period > 0),

    loan_status VARCHAR2(50) NOT NULL,

    approval_date DATE,
    currency VARCHAR2(10) NOT NULL,
    created_at DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_loan_applications_customer_id 
        FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(id) ON DELETE CASCADE
);

-------------------------------------------------------------
-- LOAN_PAYMENTS
-------------------------------------------------------------
CREATE TABLE LOAN_PAYMENTS (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loan_application_id NUMBER NOT NULL,
    amount NUMBER NOT NULL CHECK (amount > 0),
    created_at DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_loan_payments_loan_application_id 
        FOREIGN KEY (loan_application_id) REFERENCES LOAN_APPLICATIONS(id) ON DELETE CASCADE
);

-------------------------------------------------------------
-- AUDIT_LOG
-------------------------------------------------------------
CREATE TABLE AUDIT_LOG (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id NUMBER NOT NULL,
    created_at DATE DEFAULT SYSDATE NOT NULL
);

