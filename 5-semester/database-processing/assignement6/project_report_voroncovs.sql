-- ==========================================================
-- Project: StreamNova Monthly Performance and Engagement Report
-- File: project_report_vorontsov.sql
-- Author: Artyom Vorontsov
-- ==========================================================
--
-- BUSINESS RULES and CALCULATION RULES
-- ----------------------------------------------------------
-- 1. Month inclusion rules:
--    - Revenue is included if PAYMENT.payment_date is within
--      [month_start, month_end).
--    - Engagement is included if USAGE_SESSION.session_start
--      is within [month_start, month_end).
--
-- 2. Active subscription definition:
--    A subscription is considered ACTIVE for the report month if:
--      start_date < month_end
--      AND (end_date IS NULL OR end_date >= month_start)
--      AND status = 'ACTIVE'
--
-- 3. Churn and retention:
--    - Churned subscriber: subscription with status = 'CANCELLED'
--      and end_date within report month.
--    - Active at month start: active subscriptions at month_start.
--    - Churn Rate = Churned Subscribers / Active Subscribers at Start * 100
--    - Retention Rate = 100 - Churn Rate
--
-- 4. Growth / comparison:
--    - Revenue growth is measured vs previous calendar month
--      using the same revenue inclusion rules.
--
-- 5. Data quality rules:
--    - Invalid payments: amount <= 0 OR discount_amount IS NULL
--    - Bad subscription dates: end_date < start_date
--    - Zero-duration usage: watch_minutes = 0
-- ==========================================================

SET SERVEROUTPUT ON

DECLARE
    /* =========================
       Report parameters
       ========================= */
    p_report_month   DATE := DATE '2025-03-01'; -- first day of report month
    p_region_filter  VARCHAR2(10) := 'ALL';     -- 'ALL' or specific region (e.g. 'EU','US')

    /* =========================
       Derived date ranges
       ========================= */
    v_month_start DATE;
    v_month_end   DATE;
    v_prev_start  DATE;
    v_prev_end    DATE;

    /* =========================
       Revenue variables
       ========================= */
    v_net_revenue        NUMBER := 0;
    v_prev_net_revenue  NUMBER := 0;
    v_total_discounts   NUMBER := 0;
    v_paid_subs          NUMBER := 0;
    v_active_subs        NUMBER := 0;
    v_arpu               NUMBER := 0;

    /* =========================
       Engagement variables
       ========================= */
    v_total_minutes NUMBER := 0;
    v_sessions      NUMBER := 0;

    /* =========================
       Churn and retention
       ========================= */
    v_active_start  NUMBER := 0;
    v_new_subs      NUMBER := 0;
    v_churned       NUMBER := 0;
    v_reactivated   NUMBER := 0;
    v_churn_rate    NUMBER := 0;
    v_retention_rate NUMBER := 0;

BEGIN
    /* =========================
       Date calculations
       ========================= */
    v_month_start := TRUNC(p_report_month, 'MM');
    v_month_end   := ADD_MONTHS(v_month_start, 1);
    v_prev_start  := ADD_MONTHS(v_month_start, -1);
    v_prev_end    := v_month_start;

    /* =========================
       Header
       ========================= */
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE(' StreamNova – Monthly Performance Report');
    DBMS_OUTPUT.PUT_LINE(' Report Month : ' || TO_CHAR(v_month_start,'YYYY-MM'));
    DBMS_OUTPUT.PUT_LINE(' Region       : ' || p_region_filter);
    DBMS_OUTPUT.PUT_LINE(' Generated At : ' || TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('==============================================');

    /* =========================
       Revenue and Subscription Summary
       ========================= */
    BEGIN
        SELECT NVL(SUM(p.amount - p.discount_amount),0),
               NVL(SUM(p.discount_amount),0),
               COUNT(DISTINCT p.subscription_id)
        INTO   v_net_revenue, v_total_discounts, v_paid_subs
        FROM   payments p
        JOIN   subscriptions s ON s.subscription_id = p.subscription_id
        JOIN   users u ON u.user_id = s.user_id
        WHERE  p.payment_date >= v_month_start
        AND    p.payment_date <  v_month_end
        AND    (p_region_filter = 'ALL' OR u.region = p_region_filter);
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL; END;

    BEGIN
        SELECT NVL(SUM(p.amount - p.discount_amount),0)
        INTO   v_prev_net_revenue
        FROM   payments p
        WHERE  p.payment_date >= v_prev_start
        AND    p.payment_date <  v_prev_end;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL; END;

    /* Active subscriptions according to business rule #2 */
    SELECT COUNT(*)
    INTO   v_active_subs
    FROM   subscriptions s
    JOIN   users u ON u.user_id = s.user_id
    WHERE  s.start_date < v_month_end
    AND    (s.end_date IS NULL OR s.end_date >= v_month_start)
    AND    s.status = 'ACTIVE'
    AND    (p_region_filter = 'ALL' OR u.region = p_region_filter);

    IF v_active_subs > 0 THEN
        v_arpu := ROUND(v_net_revenue / v_active_subs, 2);
    END IF;

    dbms_output.put_line('');
    DBMS_OUTPUT.PUT_LINE('[Revenue and Subscription Summary]');
    DBMS_OUTPUT.PUT_LINE(' Net Revenue        : ' || v_net_revenue);
    DBMS_OUTPUT.PUT_LINE(' Previous Month Rev : ' || v_prev_net_revenue);
    DBMS_OUTPUT.PUT_LINE(' Total Discounts    : ' || v_total_discounts);
    DBMS_OUTPUT.PUT_LINE(' Paid Subscriptions : ' || v_paid_subs);
    DBMS_OUTPUT.PUT_LINE(' Active Subscribers : ' || v_active_subs);
    DBMS_OUTPUT.PUT_LINE(' ARPU               : ' || v_arpu);

    /* =========================
       Plan performance
       ========================= */
    dbms_output.put_line('');
    DBMS_OUTPUT.PUT_LINE('[Plan Performance]');
    FOR r IN (
        SELECT pl.plan_name,
               COUNT(DISTINCT s.subscription_id) active_subs,
               NVL(SUM(p.amount - p.discount_amount),0) revenue
        FROM   plans pl
        LEFT JOIN subscriptions s ON s.plan_id = pl.plan_id
        LEFT JOIN payments p ON p.subscription_id = s.subscription_id
            AND p.payment_date >= v_month_start
            AND p.payment_date <  v_month_end
        LEFT JOIN users u ON u.user_id = s.user_id
        WHERE  (p_region_filter = 'ALL' OR u.region = p_region_filter)
        GROUP BY pl.plan_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(' ' || r.plan_name ||
                             ' | Active: ' || r.active_subs ||
                             ' | Revenue: ' || r.revenue);
    END LOOP;

    /* =========================
       Engagement metrics
       ========================= */
    SELECT NVL(SUM(watch_minutes),0), COUNT(*)
    INTO   v_total_minutes, v_sessions
    FROM   usage_sessions us
    JOIN   users u ON u.user_id = us.user_id
    WHERE  us.session_start >= v_month_start
    AND    us.session_start <  v_month_end
    AND    (p_region_filter = 'ALL' OR u.region = p_region_filter);

    dbms_output.put_line('');
    DBMS_OUTPUT.PUT_LINE('[Engagement Metrics]');
    DBMS_OUTPUT.PUT_LINE(' Total Watch Minutes : ' || v_total_minutes);
    DBMS_OUTPUT.PUT_LINE(' Total Sessions      : ' || v_sessions);

    DBMS_OUTPUT.PUT_LINE(' Top 3 Users by Watch Time:');
    FOR r IN (
        SELECT u.full_name, SUM(us.watch_minutes) mins
        FROM   usage_sessions us
        JOIN   users u ON u.user_id = us.user_id
        WHERE  us.session_start >= v_month_start
        AND    us.session_start <  v_month_end
        GROUP BY u.full_name
        ORDER BY mins DESC FETCH FIRST 3 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || r.full_name || ' - ' || r.mins || ' min');
    END LOOP;

    /* =========================
       Churn and retention
       ========================= */
    SELECT COUNT(*) INTO v_active_start
    FROM   subscriptions
    WHERE  start_date < v_month_start
    AND    (end_date IS NULL OR end_date >= v_month_start)
    AND    status = 'ACTIVE';

    SELECT COUNT(*) INTO v_new_subs
    FROM   subscriptions
    WHERE  start_date >= v_month_start
    AND    start_date <  v_month_end;

    SELECT COUNT(*) INTO v_churned
    FROM   subscriptions
    WHERE  status = 'CANCELLED'
    AND    end_date >= v_month_start
    AND    end_date <  v_month_end;

    SELECT COUNT(*) INTO v_reactivated
    FROM   subscription_events
    WHERE  event_type = 'REACTIVATION'
    AND    event_date >= v_month_start
    AND    event_date <  v_month_end;

    IF v_active_start > 0 THEN
        v_churn_rate := ROUND(v_churned / v_active_start * 100, 2);
        v_retention_rate := ROUND(100 - v_churn_rate, 2);
    END IF;

    dbms_output.put_line('');
    DBMS_OUTPUT.PUT_LINE('[Churn and Retention]');
    DBMS_OUTPUT.PUT_LINE(' Active at Start : ' || v_active_start);
    DBMS_OUTPUT.PUT_LINE(' New Subscribers : ' || v_new_subs);
    DBMS_OUTPUT.PUT_LINE(' Churned         : ' || v_churned);
    DBMS_OUTPUT.PUT_LINE(' Reactivated     : ' || v_reactivated);
    DBMS_OUTPUT.PUT_LINE(' Churn Rate (%)  : ' || v_churn_rate);
    DBMS_OUTPUT.PUT_LINE(' Retention (%)   : ' || v_retention_rate);

    /* =========================
       Data quality checks
       ========================= */
    dbms_output.put_line('');
    DBMS_OUTPUT.PUT_LINE('[Data Quality Checks]');

    SELECT COUNT(*) INTO v_sessions
    FROM   payments
    WHERE  amount <= 0 OR discount_amount IS NULL;
    DBMS_OUTPUT.PUT_LINE(' Invalid Payments        : ' || v_sessions);

    SELECT COUNT(*) INTO v_sessions
    FROM   usage_sessions
    WHERE  watch_minutes = 0;
    DBMS_OUTPUT.PUT_LINE(' Zero-duration Usage     : ' || v_sessions);

    SELECT COUNT(*) INTO v_sessions
    FROM   subscriptions
    WHERE  end_date < start_date;
    DBMS_OUTPUT.PUT_LINE(' Bad Subscription Dates  : ' || v_sessions);

    DBMS_OUTPUT.PUT_LINE('==============================================');
END;
/
-- =========================
-- End of report
-- =========================
