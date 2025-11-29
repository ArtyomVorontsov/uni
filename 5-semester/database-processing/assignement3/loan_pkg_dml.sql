/*******************************************************
 * Author:      Artjoms Voroncovs
 * Date:        29-NOV-2025
 * Description: Sample data insertion script for the 
 *              loan management system. This file:
 *              - Inserts five sample customers with 
 *                varying credit profiles.
 *              - Inserts multiple loan applications in 
 *                different states (submitted, approved, 
 *                pending) for these customers.
 *              - Inserts sample loan payment records for 
 *                approved loans.
 *              - Provides realistic data to demonstrate 
 *                business scenarios such as eligibility, 
 *                approval, and repayment tracking.
 *******************************************************/


-- Insert Customers
INSERT INTO CUSTOMERS (
    full_name,
    credit_profile
) VALUES (
    'John Doe',
    'good'
);

INSERT INTO CUSTOMERS (
    full_name,
    credit_profile
) VALUES (
    'Jane Doeh',
    'average'
);

INSERT INTO CUSTOMERS (
    full_name,
    credit_profile
) VALUES (
    'Max Lol',
    'poor'
);

INSERT INTO CUSTOMERS (
    full_name,
    credit_profile
) VALUES (
    'Alice Bloom',
    'good'
);

INSERT INTO CUSTOMERS (
    full_name,
    credit_profile
) VALUES (
    'Robert Stone',
    'average'
);


-- Insert Loan Applications
INSERT INTO LOAN_APPLICATIONS (
    customer_id,
    loan_amount,
    interest_rate,
    payment_period,
    loan_status,
    approval_date,
    currency
) VALUES (
    1,
    100,
    4,
    30,
    'submitted',
    NULL,
    'EUR'
);

INSERT INTO LOAN_APPLICATIONS (
    customer_id,
    loan_amount,
    interest_rate,
    payment_period,
    loan_status,
    approval_date,
    currency
) VALUES (
    2,
    500,
    10,
    30,
    'approved',
    TO_DATE('2025-11-01', 'YYYY-MM-DD'),
    'EUR'
);

INSERT INTO LOAN_APPLICATIONS (
    customer_id,
    loan_amount,
    interest_rate,
    payment_period,
    loan_status,
    approval_date,
    currency
) VALUES (
    3,
    50,
    7.2,
    5,
    'pending',
    NULL,
    'USD'
);


-- Insert Loan Payments
INSERT INTO LOAN_PAYMENTS (
    loan_application_id,
    amount
) VALUES (
    2,
    100
);
