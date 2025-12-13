/*******************************************************
 * Author:      Artjoms Voroncovs
 * Date:        13-DEC-2025
 * Description: Sample data (DML) for subscription
 *              streaming platform. The dataset spans
 *              three consecutive months and demonstrates
 *              active, new, churned, reactivated, and
 *              trial-to-paid subscription behavior, mixed
 *              payment scenarios, and varied streaming
 *              usage patterns for analytical reporting.
 *******************************************************/

-- =====================================================
-- SAMPLE DATA (DML)
-- Timeframe: JAN–MAR 2025
-- =====================================================
-- =======================
-- PLANS
-- =======================
INSERT INTO
    plans (plan_name, monthly_price, is_active)
VALUES
    ('Basic', 10, 'Y');

INSERT INTO
    plans (plan_name, monthly_price, is_active)
VALUES
    ('Standard', 20, 'Y');

INSERT INTO
    plans (plan_name, monthly_price, is_active)
VALUES
    ('Premium', 30, 'Y');

-- =======================
-- USERS
-- =======================
INSERT INTO
    users (full_name, email, region, signup_date)
VALUES
    (
        'Alice Schmidt',
        'alice@eu.com',
        'EU',
        DATE '2025-01-05'
    );

INSERT INTO
    users (full_name, email, region, signup_date)
VALUES
    (
        'Bob Miller',
        'bob@us.com',
        'US',
        DATE '2024-12-10'
    );

INSERT INTO
    users (full_name, email, region, signup_date)
VALUES
    (
        'Carlos Ruiz',
        'carlos@eu.com',
        'EU',
        DATE '2025-02-02'
    );

INSERT INTO
    users (full_name, email, region, signup_date)
VALUES
    (
        'Diana White',
        'diana@us.com',
        'US',
        DATE '2025-01-20'
    );

INSERT INTO
    users (full_name, email, region, signup_date)
VALUES
    (
        'Eva Novak',
        'eva@eu.com',
        'EU',
        DATE '2024-11-15'
    );

-- =======================
-- SUBSCRIPTIONS
-- =======================
-- Alice: Trial -> Paid (Standard)
INSERT INTO
    subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES
    (
        1,
        1,
        DATE '2025-01-05',
        DATE '2025-01-31',
        'TRIAL'
    );

INSERT INTO
    subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES
    (1, 2, DATE '2025-02-01', NULL, 'ACTIVE');

-- Bob: Long-term active (Premium)
INSERT INTO
    subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES
    (2, 3, DATE '2024-12-10', NULL, 'ACTIVE');

-- Carlos: New subscriber in report month (March)
INSERT INTO
    subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES
    (3, 1, DATE '2025-03-05', NULL, 'ACTIVE');

-- Diana: Churns in February
INSERT INTO
    subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES
    (
        4,
        2,
        DATE '2025-01-20',
        DATE '2025-02-15',
        'CANCELLED'
    );

-- Eva: Churned then reactivated
INSERT INTO
    subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES
    (
        5,
        1,
        DATE '2024-11-15',
        DATE '2025-01-10',
        'CANCELLED'
    );

INSERT INTO
    subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES
    (5, 3, DATE '2025-02-01', NULL, 'ACTIVE');

-- =======================
-- SUBSCRIPTION EVENTS
-- =======================
INSERT INTO
    subscription_events (
        subscription_id,
        event_date,
        event_type,
        old_plan_id,
        new_plan_id
    )
VALUES
    (1, DATE '2025-02-01', 'TRIAL_CONVERTED', 1, 2);

INSERT INTO
    subscription_events (
        subscription_id,
        event_date,
        event_type,
        old_plan_id,
        new_plan_id
    )
VALUES
    (5, DATE '2025-02-01', 'REACTIVATED', 1, 3);

INSERT INTO
    subscription_events (
        subscription_id,
        event_date,
        event_type,
        old_plan_id,
        new_plan_id
    )
VALUES
    (4, DATE '2025-02-15', 'CANCELLED', 2, NULL);

-- =======================
-- PAYMENTS
-- =======================
-- JAN
INSERT INTO
    payments (
        subscription_id,
        payment_date,
        amount,
        discount_amount,
        currency
    )
VALUES
    (2, DATE '2025-01-01', 30, 0, 'EUR');

INSERT INTO
    payments (
        subscription_id,
        payment_date,
        amount,
        discount_amount,
        currency
    )
VALUES
    (4, DATE '2025-01-20', 20, 5, 'USD');

-- FEB
INSERT INTO
    payments (
        subscription_id,
        payment_date,
        amount,
        discount_amount,
        currency
    )
VALUES
    (2, DATE '2025-02-01', 30, 0, 'EUR');

INSERT INTO
    payments (
        subscription_id,
        payment_date,
        amount,
        discount_amount,
        currency
    )
VALUES
    (6, DATE '2025-02-01', 30, 10, 'EUR');

-- Data quality issue (zero payment)
INSERT INTO
    payments (
        subscription_id,
        payment_date,
        amount,
        discount_amount,
        currency
    )
VALUES
    (4, DATE '2025-02-01', 0, 0, 'USD');

-- MAR
INSERT INTO
    payments (
        subscription_id,
        payment_date,
        amount,
        discount_amount,
        currency
    )
VALUES
    (2, DATE '2025-03-01', 30, 0, 'EUR');

INSERT INTO
    payments (
        subscription_id,
        payment_date,
        amount,
        discount_amount,
        currency
    )
VALUES
    (3, DATE '2025-03-05', 10, 0, 'EUR');

-- Suspicious discount (discount = amount)
INSERT INTO
    payments (
        subscription_id,
        payment_date,
        amount,
        discount_amount,
        currency
    )
VALUES
    (6, DATE '2025-03-01', 30, 30, 'EUR');

-- =======================
-- STREAM SESSIONS
-- =======================
-- Heavy user (Bob)
INSERT INTO
    stream_sessions (
        user_id,
        session_start,
        session_end,
        device_type,
        total_minutes
    )
VALUES
    (
        2,
        DATE '2025-01-10',
        DATE '2025-01-10',
        'TV',
        180
    );

INSERT INTO
    stream_sessions (
        user_id,
        session_start,
        session_end,
        device_type,
        total_minutes
    )
VALUES
    (
        2,
        DATE '2025-02-12',
        DATE '2025-02-12',
        'TV',
        240
    );

INSERT INTO
    stream_sessions (
        user_id,
        session_start,
        session_end,
        device_type,
        total_minutes
    )
VALUES
    (
        2,
        DATE '2025-03-08',
        DATE '2025-03-08',
        'WEB',
        200
    );

-- Light user (Alice)
INSERT INTO
    stream_sessions (
        user_id,
        session_start,
        session_end,
        device_type,
        total_minutes
    )
VALUES
    (
        1,
        DATE '2025-02-05',
        DATE '2025-02-05',
        'MOBILE',
        30
    );

INSERT INTO
    stream_sessions (
        user_id,
        session_start,
        session_end,
        device_type,
        total_minutes
    )
VALUES
    (
        1,
        DATE '2025-03-02',
        DATE '2025-03-02',
        'WEB',
        45
    );

-- Churned user (Diana)
INSERT INTO
    stream_sessions (
        user_id,
        session_start,
        session_end,
        device_type,
        total_minutes
    )
VALUES
    (
        4,
        DATE '2025-01-25',
        DATE '2025-01-25',
        'WEB',
        90
    );

-- Reactivated user (Eva)
INSERT INTO
    stream_sessions (
        user_id,
        session_start,
        session_end,
        device_type,
        total_minutes
    )
VALUES
    (
        5,
        DATE '2025-03-10',
        DATE '2025-03-10',
        'TV',
        150
    );

-- =====================================================
-- END OF SAMPLE DATA
-- =====================================================