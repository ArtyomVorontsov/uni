/***************************************************************
 * Author:      Artjoms Voroncovs
 * Date:        29-NOV-2025
 * Description: This file contains the complete PL/SQL package
 *              'pkg_loan_lifecycle' for managing the lifecycle
 *              of loans in the system. The package includes:
 *                - Procedures to submit, approve, disburse loans,
 *                  and record payments.
 *                - Functions to calculate monthly payments and
 *                  check customer eligibility.
 *                - Package-level constants and custom exceptions
 *                  for business rules enforcement.
 *                - Logging mechanism to track events in AUDIT_LOG.
 *
 *              Additionally, this file contains anonymous
 *              PL/SQL blocks demonstrating:
 *                1. Submitting and approving a valid loan.
 *                2. Attempting an ineligible loan submission.
 *                3. Disbursing funds and recording payments.
 *                4. Reading and displaying audit log entries.
 *
 *              All blocks include DBMS_OUTPUT summaries and
 *              handle exceptions to show expected success
 *              or failure scenarios.
 ***************************************************************/

CREATE OR REPLACE PACKAGE pkg_loan_lifecycle IS
  /***********************************************************************
   * Package: pkg_loan_lifecycle
   * Purpose: Encapsulate loan lifecycle logic: submit, approve, disburse,
   *          and record payments. Includes helper functions, package
   *          constants and custom exceptions. Writes audit entries to AUDIT_LOG.
   *
   * NOTE: This package does NOT perform any COMMIT/ROLLBACK. Caller is
   *       responsible for transaction control.
   ***********************************************************************/

  -- Package version
  pkg_version CONSTANT VARCHAR2(20) := '1.0';

  -- Default business constants
  default_interest_rate CONSTANT NUMBER := 5;          -- annual percent, used if interest omitted
  approval_amount_limit CONSTANT NUMBER := 10000;     -- example approval limit for auto-approve checks

  /* Custom Exceptions (declared for clarity; raised with messages via RAISE_APPLICATION_ERROR) */
  e_insufficient_credit EXCEPTION;
  e_amount_exceeds_limit EXCEPTION;
  e_loan_not_found EXCEPTION;
  e_invalid_state EXCEPTION;

  -- Error numbers (use RAISE_APPLICATION_ERROR with these)
  c_err_insufficient_credit CONSTANT PLS_INTEGER := -20001;
  c_err_amount_exceeds_limit CONSTANT PLS_INTEGER := -20002;
  c_err_loan_not_found       CONSTANT PLS_INTEGER := -20003;
  c_err_invalid_state        CONSTANT PLS_INTEGER := -20004;

  -----------------------------------------------------------------------
  -- Procedures
  -----------------------------------------------------------------------

  /**
   * Submit a loan application.
   * @param p_customer_id IN customer id
   * @param p_amount IN loan amount
   * @param p_interest_rate IN annual interest percent (if NULL, default_interest_rate used)
   * @param p_payment_period IN number of months
   * @param p_currency IN currency code (e.g. 'EUR')
   * @param p_user_id IN id of user performing action (for audit)
   * @param p_loan_id OUT returned id of created LOAN_APPLICATIONS row
   *
   * Validations performed:
   *  - Customer eligibility via check_eligibility()
   *  - Amount > 0 and not exceeding approval_amount_limit (if business rule applies)
   */
  PROCEDURE submit_loan(
    p_customer_id    IN  NUMBER,
    p_amount         IN  NUMBER,
    p_interest_rate  IN  NUMBER DEFAULT NULL,
    p_payment_period IN  NUMBER,
    p_currency       IN  VARCHAR2,
    p_user_id        IN  NUMBER,
    p_loan_id        OUT NUMBER
  );

  /**
   * Approve a submitted loan.
   * @param p_loan_id IN loan application id
   * @param p_approver_user_id IN id of user approving (for audit)
   *
   * Validations:
   *  - loan must exist and be in 'SUBMITTED' or 'PENDING' state
   */
  PROCEDURE approve_loan(
    p_loan_id         IN NUMBER,
    p_approver_user_id IN NUMBER
  );

  /**
   * Disburse funds for an approved loan (mark as ACTIVE/DISBURSED).
   * @param p_loan_id IN loan id
   * @param p_user_id IN user id performing disbursement (for audit)
   */
  PROCEDURE disburse_funds(
    p_loan_id IN NUMBER,
    p_user_id IN NUMBER
  );

  /**
   * Record a payment against a loan.
   * @param p_loan_id IN loan id
   * @param p_amount IN payment amount
   * @param p_user_id IN user id performing the payment record (for audit)
   *
   * If total payments >= loan_amount, sets loan_status to 'REPAID' (business rule).
   */
  PROCEDURE record_payment(
    p_loan_id IN NUMBER,
    p_amount  IN NUMBER,
    p_user_id IN NUMBER
  );

  -----------------------------------------------------------------------
  -- Functions
  -----------------------------------------------------------------------

  /**
   * Compute monthly payment using amortization formula.
   * @param p_principal IN loan amount
   * @param p_annual_rate_pct IN annual interest rate percent (e.g. 5 = 5%)
   * @param p_months IN number of months
   * @return monthly payment as NUMBER
   *
   * Formula:
   *   r = annual_rate_pct / 12 / 100
   *   payment = P * r / (1 - (1 + r)^(-n))
   */
  FUNCTION calculate_monthly_payment(
    p_principal        IN NUMBER,
    p_annual_rate_pct  IN NUMBER,
    p_months           IN NUMBER
  ) RETURN NUMBER;

  /**
   * Check customer eligibility for a loan.
   * @param p_customer_id IN customer id
   * @param p_amount IN requested amount
   * @return BOOLEAN TRUE if eligible, FALSE otherwise
   *
   * Business logic: fetches CUSTOMERS.credit_profile and applies simple rules:
   *  - 'poor' => ineligible
   *  - if amount > approval_amount_limit => raise e_amount_exceeds_limit
   */
  FUNCTION check_eligibility(
    p_customer_id IN NUMBER,
    p_amount      IN NUMBER
  ) RETURN BOOLEAN;

END pkg_loan_lifecycle;
/



CREATE OR REPLACE PACKAGE BODY pkg_loan_lifecycle IS
  /************************************************************************
   * Implementation of pkg_loan_lifecycle.
   * Contains actual PL/SQL code for the spec procedures and functions.
   ************************************************************************/

  -----------------------------------------------------------------------
  -- Utility: log_event
  -- Inserts a record into AUDIT_LOG for auditing business events.
  -- NOTE: AUDIT_LOG in your schema contains (id, user_id, created_at).
  -----------------------------------------------------------------------
  PROCEDURE log_event(p_user_id IN NUMBER) IS
  BEGIN
    INSERT INTO AUDIT_LOG (user_id, created_at)
    VALUES (p_user_id, SYSDATE);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END log_event;

  -----------------------------------------------------------------------
  -- Function: calculate_monthly_payment
  -----------------------------------------------------------------------
  FUNCTION calculate_monthly_payment(
    p_principal       IN NUMBER,
    p_annual_rate_pct IN NUMBER,
    p_months          IN NUMBER
  ) RETURN NUMBER IS
    v_r NUMBER;
    v_payment NUMBER;
  BEGIN
    IF p_principal IS NULL OR p_principal <= 0 THEN
      RETURN NULL;
    END IF;

    IF p_months IS NULL OR p_months <= 0 THEN
      RETURN NULL;
    END IF;

    IF p_annual_rate_pct IS NULL OR p_annual_rate_pct = 0 THEN
      -- zero interest => straight division
      v_payment := p_principal / p_months;
      RETURN v_payment;
    END IF;

    v_r := p_annual_rate_pct / 12 / 100; -- monthly rate as decimal

    v_payment := p_principal * v_r / (1 - POWER(1 + v_r, -p_months));

    RETURN ROUND(v_payment, 2);
  EXCEPTION
    WHEN OTHERS THEN
      -- bubble up with message for caller
      RAISE;
  END calculate_monthly_payment;

  -----------------------------------------------------------------------
  -- Function: check_eligibility
  -----------------------------------------------------------------------
  FUNCTION check_eligibility(
    p_customer_id IN NUMBER,
    p_amount      IN NUMBER
  ) RETURN BOOLEAN IS
    v_credit_profile VARCHAR2(255);
  BEGIN
    IF p_customer_id IS NULL THEN
      RAISE_APPLICATION_ERROR(c_err_insufficient_credit, 'Customer id is required for eligibility check.');
    END IF;

    SELECT credit_profile
      INTO v_credit_profile
      FROM CUSTOMERS
     WHERE id = p_customer_id;

    -- simple business rules:
    IF LOWER(TRIM(v_credit_profile)) = 'poor' THEN
      -- not eligible
      RAISE_APPLICATION_ERROR(c_err_insufficient_credit, 'Insufficient credit profile: customer cannot be approved.');
      RETURN FALSE; -- unreachable after raise, but kept for clarity
    END IF;

    IF p_amount IS NOT NULL AND p_amount > approval_amount_limit THEN
      RAISE_APPLICATION_ERROR(c_err_amount_exceeds_limit,
                             'Requested amount exceeds approval limit of ' || approval_amount_limit);
    END IF;

    RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(c_err_loan_not_found, 'Customer not found for eligibility check.');
    WHEN OTHERS THEN
      RAISE;
  END check_eligibility;

  -----------------------------------------------------------------------
  -- Procedure: submit_loan
  -----------------------------------------------------------------------
  PROCEDURE submit_loan(
    p_customer_id    IN  NUMBER,
    p_amount         IN  NUMBER,
    p_interest_rate  IN  NUMBER DEFAULT NULL,
    p_payment_period IN  NUMBER,
    p_currency       IN  VARCHAR2,
    p_user_id        IN  NUMBER,
    p_loan_id        OUT NUMBER
  ) IS
    v_interest_rate NUMBER := NVL(p_interest_rate, default_interest_rate);
    v_new_id NUMBER;
  BEGIN
    -- Basic validations
    IF p_customer_id IS NULL THEN
      RAISE_APPLICATION_ERROR(-20010, 'Customer id is required.');
    END IF;
    IF p_amount IS NULL OR p_amount <= 0 THEN
      RAISE_APPLICATION_ERROR(-20011, 'Loan amount must be positive.');
    END IF;
    IF p_payment_period IS NULL OR p_payment_period <= 0 THEN
      RAISE_APPLICATION_ERROR(-20012, 'Payment period (months) must be positive.');
    END IF;
    IF p_currency IS NULL THEN
      RAISE_APPLICATION_ERROR(-20013, 'Currency is required.');
    END IF;

    -- Eligibility check (this may raise application error for 'poor' or over-limit)
    IF NOT check_eligibility(p_customer_id, p_amount) THEN
      -- check_eligibility raises errors on failure; this is a safety net
      RAISE_APPLICATION_ERROR(c_err_insufficient_credit, 'Customer not eligible.');
    END IF;

    -- Insert loan application; using RETURNING to get identity value (Oracle identity supports RETURNING)
    INSERT INTO LOAN_APPLICATIONS (
      customer_id, loan_amount, interest_rate, payment_period,
      loan_status, approval_date, currency, created_at
    ) VALUES (
      p_customer_id, p_amount, v_interest_rate, p_payment_period,
      'SUBMITTED', NULL, p_currency, SYSDATE
    )
    RETURNING id INTO v_new_id;

    p_loan_id := v_new_id;

    -- Log event
    log_event(p_user_id);

  EXCEPTION
    WHEN OTHERS THEN
      -- Re-raise so caller can handle; do not commit/rollback here
      RAISE;
  END submit_loan;

  -----------------------------------------------------------------------
  -- Procedure: approve_loan
  -----------------------------------------------------------------------
  PROCEDURE approve_loan(
    p_loan_id          IN NUMBER,
    p_approver_user_id IN NUMBER
  ) IS
    v_status VARCHAR2(50);
  BEGIN
    IF p_loan_id IS NULL THEN
      RAISE_APPLICATION_ERROR(-20020, 'Loan id is required for approval.');
    END IF;

    SELECT loan_status
      INTO v_status
      FROM LOAN_APPLICATIONS
     WHERE id = p_loan_id
     FOR UPDATE; -- lock row for update

    IF v_status NOT IN ('SUBMITTED', 'PENDING') THEN
      RAISE_APPLICATION_ERROR(c_err_invalid_state, 'Loan is not in a state that can be approved.');
    END IF;

    UPDATE LOAN_APPLICATIONS
       SET loan_status = 'APPROVED',
           approval_date = SYSDATE
     WHERE id = p_loan_id;

    -- Log approval event
    log_event(p_approver_user_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(c_err_loan_not_found, 'Loan not found for approval.');
    WHEN OTHERS THEN
      RAISE;
  END approve_loan;

  -----------------------------------------------------------------------
  -- Procedure: disburse_funds
  -----------------------------------------------------------------------
  PROCEDURE disburse_funds(
    p_loan_id IN NUMBER,
    p_user_id IN NUMBER
  ) IS
    v_status VARCHAR2(50);
  BEGIN
    IF p_loan_id IS NULL THEN
      RAISE_APPLICATION_ERROR(-20030, 'Loan id is required for disbursement.');
    END IF;

    SELECT loan_status
      INTO v_status
      FROM LOAN_APPLICATIONS
     WHERE id = p_loan_id
     FOR UPDATE;

    IF v_status <> 'APPROVED' THEN
      RAISE_APPLICATION_ERROR(c_err_invalid_state, 'Loan must be APPROVED before disbursement.');
    END IF;

    UPDATE LOAN_APPLICATIONS
       SET loan_status = 'ACTIVE'
     WHERE id = p_loan_id;

    -- Log disbursement
    log_event(p_user_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(c_err_loan_not_found, 'Loan not found for disbursement.');
    WHEN OTHERS THEN
      RAISE;
  END disburse_funds;

  -----------------------------------------------------------------------
  -- Procedure: record_payment
  -----------------------------------------------------------------------
  PROCEDURE record_payment(
    p_loan_id IN NUMBER,
    p_amount  IN NUMBER,
    p_user_id IN NUMBER
  ) IS
    v_loan_amount NUMBER;
    v_total_paid NUMBER;
  BEGIN
    IF p_loan_id IS NULL THEN
      RAISE_APPLICATION_ERROR(-20040, 'Loan id is required for recording payment.');
    END IF;
    IF p_amount IS NULL OR p_amount <= 0 THEN
      RAISE_APPLICATION_ERROR(-20041, 'Payment amount must be positive.');
    END IF;

    -- Ensure loan exists and get principal
    SELECT loan_amount
      INTO v_loan_amount
      FROM LOAN_APPLICATIONS
     WHERE id = p_loan_id;

    -- Insert payment
    INSERT INTO LOAN_PAYMENTS (loan_application_id, amount, created_at)
    VALUES (p_loan_id, p_amount, SYSDATE);

    -- compute total paid
    SELECT NVL(SUM(amount), 0)
      INTO v_total_paid
      FROM LOAN_PAYMENTS
     WHERE loan_application_id = p_loan_id;

    -- If fully paid or overpaid, mark loan as REPAID
    IF v_total_paid >= v_loan_amount THEN
      UPDATE LOAN_APPLICATIONS
         SET loan_status = 'REPAID'
       WHERE id = p_loan_id;
    END IF;

    -- Log payment event
    log_event(p_user_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(c_err_loan_not_found, 'Loan not found when recording payment.');
    WHEN OTHERS THEN
      RAISE;
  END record_payment;

END pkg_loan_lifecycle;
/




-- DEMONSTRATION BLOCKS

SET SERVEROUTPUT ON;

---------------------------------------------------------------
-- 1. VALID LOAN: SUBMIT + APPROVE
---------------------------------------------------------------
DECLARE
    v_loan_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===================================================');
    DBMS_OUTPUT.PUT_LINE('1) Valid Loan Submission and Approval');
    DBMS_OUTPUT.PUT_LINE('===================================================');

    pkg_loan_lifecycle.submit_loan(
        p_customer_id    => 1,
        p_amount         => 300,
        p_interest_rate  => NULL,
        p_payment_period => 12,
        p_currency       => 'EUR',
        p_user_id        => 1,
        p_loan_id        => v_loan_id  
    );

    DBMS_OUTPUT.PUT_LINE('Loan submitted successfully. Loan ID = ' || v_loan_id);

    pkg_loan_lifecycle.approve_loan(v_loan_id, 1);

    DBMS_OUTPUT.PUT_LINE('Loan approved successfully.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/
---------------------------------------------------------------
-- 2. INVALID LOAN: TRY TO SUBMIT AND APPROVE AN INELIGIBLE CUSTOMER
---------------------------------------------------------------
DECLARE
    v_loan_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===================================================');
    DBMS_OUTPUT.PUT_LINE('2) Invalid Loan Attempt – Expect Failure');
    DBMS_OUTPUT.PUT_LINE('===================================================');

    pkg_loan_lifecycle.submit_loan(
        p_customer_id    => 3,  -- "poor" credit profile
        p_amount         => 500000,  -- amount too high
        p_interest_rate  => NULL,
        p_payment_period => 12,
        p_currency       => 'USD',
        p_user_id        => 1,
        p_loan_id        => v_loan_id  
    );

    DBMS_OUTPUT.PUT_LINE('Loan submitted unexpectedly. ID = ' || v_loan_id);

    pkg_loan_lifecycle.approve_loan(v_loan_id, 1);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Failure: ' || SQLERRM);
END;
/
---------------------------------------------------------------
-- 3. INVALID LOAN DISBURSE: Loan must be APPROVED before disbursement.)
---------------------------------------------------------------
BEGIN
    DBMS_OUTPUT.PUT_LINE('===================================================');
    DBMS_OUTPUT.PUT_LINE('3) Invalid Loan Disburse Attempt – Expect Failure');
    DBMS_OUTPUT.PUT_LINE('===================================================');

    pkg_loan_lifecycle.disburse_funds(2, 1);
    DBMS_OUTPUT.PUT_LINE('Funds disbursed for loan ID = 2');

    pkg_loan_lifecycle.record_payment(
        p_loan_id => 2,
        p_amount  => 50,
        p_user_id => 1
    );
    DBMS_OUTPUT.PUT_LINE('Payment recorded: 50 EUR');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/
---------------------------------------------------------------
-- 4. PRINT AUDIT LOG
---------------------------------------------------------------
DECLARE
    CURSOR c_logs IS
        SELECT id, user_id, created_at
        FROM audit_log
        ORDER BY created_at;

    v_row c_logs%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===================================================');
    DBMS_OUTPUT.PUT_LINE('4) AUDIT LOG OUTPUT');
    DBMS_OUTPUT.PUT_LINE('===================================================');

    OPEN c_logs;
    LOOP
        FETCH c_logs INTO v_row;
        EXIT WHEN c_logs%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            'ID=' || v_row.id ||
            ' USER=' || NVL(TO_CHAR(v_row.user_id), 'NULL') ||
            ' DATE=' || TO_CHAR(v_row.created_at, 'YYYY-MM-DD HH24:MI:SS')
        );
    END LOOP;
    CLOSE c_logs;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/
