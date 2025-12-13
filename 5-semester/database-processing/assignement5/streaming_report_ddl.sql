/*******************************************************
 * Author:      Artjoms Voroncovs
 * Date:        13-DEC-2025
 * Description: Subscription streaming platform database
 *              schema with users, plans, subscriptions,
 *              payments, usage sessions, and lifecycle
 *              events. Includes primary keys, foreign
 *              keys, and basic business constraints.
 *******************************************************/

-- =====================================================
-- Subscription Streaming Platform – DDL Script
-- =====================================================

-- =======================
-- DROP TABLES (SAFE ORDER)
-- =======================
DROP TABLE stream_sessions CASCADE CONSTRAINTS;
DROP TABLE payments CASCADE CONSTRAINTS;
DROP TABLE subscription_events CASCADE CONSTRAINTS;
DROP TABLE subscriptions CASCADE CONSTRAINTS;
DROP TABLE plans CASCADE CONSTRAINTS;
DROP TABLE users CASCADE CONSTRAINTS;

-- =======================
-- USERS
-- =======================
CREATE TABLE users (
    user_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name     VARCHAR2(255) NOT NULL,
    email         VARCHAR2(255),
    region        VARCHAR2(10),
    signup_date   DATE,

    CONSTRAINT chk_users_region
        CHECK (region IN ('EU', 'US', 'APAC'))
);

-- =======================
-- PLANS
-- =======================
CREATE TABLE plans (
    plan_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    plan_name      VARCHAR2(50) NOT NULL,
    monthly_price  NUMBER NOT NULL,
    is_active      CHAR(1) NOT NULL,

    CONSTRAINT chk_plans_price
        CHECK (monthly_price > 0),

    CONSTRAINT chk_plans_is_active
        CHECK (is_active IN ('Y', 'N'))
);

-- =======================
-- SUBSCRIPTIONS
-- =======================
CREATE TABLE subscriptions (
    subscription_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id         NUMBER NOT NULL,
    plan_id         NUMBER NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE,
    status          VARCHAR2(20) NOT NULL,

    CONSTRAINT fk_sub_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_sub_plan
        FOREIGN KEY (plan_id)
        REFERENCES plans(plan_id),

    CONSTRAINT chk_sub_status
        CHECK (status IN ('ACTIVE', 'CANCELLED', 'EXPIRED', 'TRIAL')),

    CONSTRAINT chk_sub_dates
        CHECK (end_date IS NULL OR end_date >= start_date)
);

-- =======================
-- SUBSCRIPTION EVENTS
-- =======================
CREATE TABLE subscription_events (
    event_id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    subscription_id  NUMBER NOT NULL,
    event_date       DATE NOT NULL,
    event_type       VARCHAR2(30) NOT NULL,
    old_plan_id      NUMBER,
    new_plan_id      NUMBER,

    CONSTRAINT fk_event_subscription
        FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id),

    CONSTRAINT chk_event_type
        CHECK (event_type IN (
            'PLAN_UPGRADE',
            'PLAN_DOWNGRADE',
            'CANCELLED',
            'REACTIVATED',
            'TRIAL_CONVERTED'
        ))
);

-- =======================
-- PAYMENTS
-- =======================
CREATE TABLE payments (
    payment_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    subscription_id   NUMBER NOT NULL,
    payment_date      DATE NOT NULL,
    amount            NUMBER NOT NULL,
    discount_amount   NUMBER DEFAULT 0 NOT NULL,
    currency          VARCHAR2(3) NOT NULL,

    CONSTRAINT fk_payment_subscription
        FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id),

    CONSTRAINT chk_payment_amount
        CHECK (amount > 0),

    CONSTRAINT chk_payment_discount
        CHECK (discount_amount >= 0)
);

-- =======================
-- STREAM SESSIONS
-- =======================
CREATE TABLE stream_sessions (
    session_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id         NUMBER NOT NULL,
    session_start   DATE NOT NULL,
    session_end     DATE,
    device_type     VARCHAR2(20) NOT NULL,
    total_minutes   NUMBER,

    CONSTRAINT fk_stream_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    CONSTRAINT chk_device_type
        CHECK (device_type IN ('MOBILE', 'TV', 'WEB')),

    CONSTRAINT chk_stream_time
        CHECK (session_end IS NULL OR session_end >= session_start),

    CONSTRAINT chk_total_minutes
        CHECK (total_minutes IS NULL OR total_minutes >= 0)
);

-- =====================================================
-- End of DDL Script
-- =====================================================
