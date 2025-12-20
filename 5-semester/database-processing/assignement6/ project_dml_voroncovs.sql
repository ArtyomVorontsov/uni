-- ==========================================================
-- Project: StreamNova Monthly Performance and Engagement Report
-- File: project_dml_vorontsov.sql
-- Author: Artyom Vorontsov
-- Purpose: Sample data for Jan–Mar 2025
-- ==========================================================

-- =========================
-- Plans
-- =========================
INSERT INTO plans (plan_name, price, is_active) VALUES ('Basic', 9.99, 'Y');
INSERT INTO plans (plan_name, price, is_active) VALUES ('Standard', 14.99, 'Y');
INSERT INTO plans (plan_name, price, is_active) VALUES ('Premium', 19.99, 'Y');

-- =========================
-- Users (EU / US regions)
-- =========================
INSERT INTO users (full_name, email, region, signup_date) VALUES ('Alice Brown', 'alice@ex.com', 'EU', DATE '2024-12-15');
INSERT INTO users (full_name, email, region, signup_date) VALUES ('Bob Smith', 'bob@ex.com', 'EU', DATE '2025-01-10');
INSERT INTO users (full_name, email, region, signup_date) VALUES ('Charlie Green', 'charlie@ex.com', 'US', DATE '2025-01-05');
INSERT INTO users (full_name, email, region, signup_date) VALUES ('Diana White', 'diana@ex.com', 'US', DATE '2025-02-02');
INSERT INTO users (full_name, email, region, signup_date) VALUES ('Evan Black', 'evan@ex.com', 'EU', DATE '2024-11-20');

-- =========================
-- Subscriptions
-- =========================
-- Alice: active, upgrades
INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES (1, 1, DATE '2024-12-15', DATE '2025-02-14', 'ACTIVE');

INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES (1, 3, DATE '2025-02-15', NULL, 'ACTIVE');

-- Bob: trial -> paid
INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES (2, 1, DATE '2025-01-10', DATE '2025-01-31', 'TRIAL');

INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES (2, 2, DATE '2025-02-01', NULL, 'ACTIVE');

-- Charlie: churns
INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES (3, 2, DATE '2025-01-05', DATE '2025-02-20', 'CANCELLED');

-- Diana: new in March
INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES (4, 1, DATE '2025-03-05', NULL, 'ACTIVE');

-- Evan: cancelled -> reactivated
INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES (5, 3, DATE '2024-11-20', DATE '2025-01-15', 'CANCELLED');

INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES (5, 2, DATE '2025-02-01', NULL, 'ACTIVE');

-- =========================
-- Subscription events
-- =========================
INSERT INTO subscription_events (subscription_id, event_date, event_type, old_plan_id, new_plan_id)
VALUES (1, DATE '2025-02-15', 'UPGRADE', 1, 3);

INSERT INTO subscription_events (subscription_id, event_date, event_type)
VALUES (3, DATE '2025-02-20', 'CANCELLATION');

INSERT INTO subscription_events (subscription_id, event_date, event_type)
VALUES (4, DATE '2025-02-01', 'TRIAL_CONVERSION');

INSERT INTO subscription_events (subscription_id, event_date, event_type)
VALUES (7, DATE '2025-02-01', 'REACTIVATION');

-- =========================
-- Payments (incl. invalid ones)
-- =========================
INSERT INTO payments (subscription_id, payment_date, amount, discount_amount)
VALUES (1, DATE '2025-01-01', 9.99, 0);

INSERT INTO payments (subscription_id, payment_date, amount, discount_amount)
VALUES (1, DATE '2025-02-01', 9.99, 2.00);

INSERT INTO payments (subscription_id, payment_date, amount, discount_amount)
VALUES (2, DATE '2025-03-01', 19.99, 0);

INSERT INTO payments (subscription_id, payment_date, amount, discount_amount)
VALUES (4, DATE '2025-02-01', 14.99, 0);

INSERT INTO payments (subscription_id, payment_date, amount, discount_amount)
VALUES (6, DATE '2025-03-05', 9.99, 1.00);

-- Invalid / suspicious payments
INSERT INTO payments (subscription_id, payment_date, amount, discount_amount)
VALUES (4, DATE '2025-02-15', 0, 0);

INSERT INTO payments (subscription_id, payment_date, amount, discount_amount)
VALUES (5, DATE '2025-01-10', 14.99, NULL);

-- =========================
-- Usage sessions
-- =========================
-- Heavy user: Alice
INSERT INTO usage_sessions (user_id, session_start, session_end, device_type, watch_minutes)
VALUES (1, DATE '2025-01-10', DATE '2025-01-10' + 1/24, 'TV', 60);
INSERT INTO usage_sessions VALUES (DEFAULT,1, DATE '2025-02-10', DATE '2025-02-10' + 2/24, 'Mobile',120);
INSERT INTO usage_sessions VALUES (DEFAULT,1, DATE '2025-03-12', DATE '2025-03-12' + 3/24, 'TV',180);

-- Light user: Bob
INSERT INTO usage_sessions VALUES (DEFAULT,2, DATE '2025-02-05', DATE '2025-02-05' + 30/1440, 'Web',30);

-- Charlie: usage then churn
INSERT INTO usage_sessions VALUES (DEFAULT,3, DATE '2025-01-15', DATE '2025-01-15' + 45/1440, 'Mobile',45);

-- Evan: reactivated heavy
INSERT INTO usage_sessions VALUES (DEFAULT,5, DATE '2025-03-01', DATE '2025-03-01' + 2/24, 'TV',120);
INSERT INTO usage_sessions VALUES (DEFAULT,5, DATE '2025-03-10', DATE '2025-03-10' + 1/24, 'Web',60);

COMMIT;
-- =========================
-- End of DML
-- =========================
