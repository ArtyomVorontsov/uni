/*******************************************************
 * Author:      Artjoms Voroncovs
 * Date:        13-DEC-2025
 * Description: Monthly Subscription & Engagement
 *              Performance Report using PL/SQL and
 *              DBMS_OUTPUT.PUT_LINE
 *******************************************************/

SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
    -- ===============================
    -- REPORT PARAMETERS
    -- ===============================
    v_report_month DATE := DATE '2025-03-01';  -- First day of the month
    v_region       VARCHAR2(10) := 'ALL';     -- 'ALL' or 'EU', 'US', etc.
    
    -- ===============================
    -- GENERAL VARIABLES
    -- ===============================
    v_company_name   VARCHAR2(50) := 'StreamNova Media';
    v_timestamp      VARCHAR2(30);
    
    -- Revenue & Subscription metrics
    v_gross_revenue   NUMBER := 0;
    v_total_discounts NUMBER := 0;
    v_net_revenue     NUMBER := 0;
    v_prev_net_rev    NUMBER := 0;
    v_net_rev_growth  VARCHAR2(50) := 'N/A';
    v_paid_subs       NUMBER := 0;
    v_active_subs     NUMBER := 0;
    v_arpu            NUMBER := 0;
    
    -- Engagement
    v_total_stream_minutes NUMBER := 0;
    v_avg_stream_per_user  NUMBER := 0;
    v_avg_session_length   NUMBER := 0;
    
BEGIN
    -- ===============================
    -- HEADER
    -- ===============================
    SELECT TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') INTO v_timestamp FROM dual;
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('Monthly Subscription & Engagement Report');
    DBMS_OUTPUT.PUT_LINE('Company: ' || v_company_name);
    DBMS_OUTPUT.PUT_LINE('Report Month: ' || TO_CHAR(v_report_month, 'YYYY-MM'));
    DBMS_OUTPUT.PUT_LINE('Region Filter: ' || v_region);
    DBMS_OUTPUT.PUT_LINE('Generated At: ' || v_timestamp);
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('');

    -- ===============================
    -- 3.2 Overall Subscription & Revenue Summary
    -- ===============================
    BEGIN
        -- Gross revenue
        SELECT NVL(SUM(amount),0), NVL(SUM(discount_amount),0), COUNT(DISTINCT subscription_id)
        INTO v_gross_revenue, v_total_discounts, v_paid_subs
        FROM payments p
        JOIN subscriptions s ON p.subscription_id = s.subscription_id
        JOIN users u ON s.user_id = u.user_id
        WHERE TRUNC(p.payment_date,'MM') = TRUNC(v_report_month,'MM')
          AND (v_region='ALL' OR u.region=v_region);

        v_net_revenue := v_gross_revenue - v_total_discounts;

        -- Active subscribers in month
        SELECT COUNT(DISTINCT s.user_id)
        INTO v_active_subs
        FROM subscriptions s
        JOIN users u ON s.user_id = u.user_id
        WHERE (v_region='ALL' OR u.region=v_region)
          AND s.start_date <= LAST_DAY(v_report_month)
          AND NVL(s.end_date, DATE '9999-12-31') >= v_report_month;

        -- ARPU
        IF v_active_subs > 0 THEN
            v_arpu := ROUND(v_net_revenue / v_active_subs, 2);
        ELSE
            v_arpu := 0;
        END IF;

        -- Previous month net revenue
        BEGIN
            SELECT NVL(SUM(amount)-SUM(NVL(discount_amount,0)),0)
            INTO v_prev_net_rev
            FROM payments p
            JOIN subscriptions s ON p.subscription_id = s.subscription_id
            JOIN users u ON s.user_id = u.user_id
            WHERE TRUNC(p.payment_date,'MM') = ADD_MONTHS(TRUNC(v_report_month,'MM'),-1)
              AND (v_region='ALL' OR u.region=v_region);

            IF v_prev_net_rev > 0 THEN
                v_net_rev_growth := TO_CHAR(ROUND((v_net_revenue - v_prev_net_rev)/v_prev_net_rev*100,2)) || '%';
            ELSE
                v_net_rev_growth := 'No prior month data – growth not applicable';
            END IF;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_net_rev_growth := 'No prior month data – growth not applicable';
        END;

        -- Print summary
        DBMS_OUTPUT.PUT_LINE('--- Overall Subscription & Revenue Summary ---');
        DBMS_OUTPUT.PUT_LINE('Total Gross Revenue: ' || v_gross_revenue);
        DBMS_OUTPUT.PUT_LINE('Total Discounts: ' || v_total_discounts);
        DBMS_OUTPUT.PUT_LINE('Net Revenue: ' || v_net_revenue);
        DBMS_OUTPUT.PUT_LINE('Paid Subscriptions Billed: ' || v_paid_subs);
        DBMS_OUTPUT.PUT_LINE('Active Subscribers: ' || v_active_subs);
        DBMS_OUTPUT.PUT_LINE('ARPU: ' || v_arpu);
        DBMS_OUTPUT.PUT_LINE('Net Revenue Growth vs Previous Month: ' || v_net_rev_growth);
        DBMS_OUTPUT.PUT_LINE('');

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('No payments found for the selected month/region.');
    END;

    -- ===============================
    -- 3.3 Plan Performance
    -- ===============================
    DBMS_OUTPUT.PUT_LINE('--- Plan Performance ---');

    FOR rec IN (
        SELECT plan_id, plan_name
        FROM plans
    ) LOOP
        DECLARE
            v_plan_net_rev NUMBER := 0;
            v_active_per_plan NUMBER := 0;
            v_new_per_plan NUMBER := 0;
            v_churned_per_plan NUMBER := 0;
            v_plan_share NUMBER := 0;
        BEGIN
            -- Net revenue per plan
            SELECT NVL(SUM(p.amount - NVL(p.discount_amount,0)),0)
            INTO v_plan_net_rev
            FROM payments p
            JOIN subscriptions s ON p.subscription_id = s.subscription_id
            JOIN users u ON s.user_id = u.user_id
            WHERE s.plan_id = rec.plan_id
              AND TRUNC(p.payment_date,'MM') = TRUNC(v_report_month,'MM')
              AND (v_region='ALL' OR u.region=v_region);

            -- Active subscribers
            SELECT COUNT(DISTINCT s.user_id)
            INTO v_active_per_plan
            FROM subscriptions s
            JOIN users u ON s.user_id = u.user_id
            WHERE s.plan_id = rec.plan_id
              AND (v_region='ALL' OR u.region=v_region)
              AND s.start_date <= LAST_DAY(v_report_month)
              AND NVL(s.end_date, DATE '9999-12-31') >= v_report_month;

            -- New subscribers
            SELECT COUNT(DISTINCT s.user_id)
            INTO v_new_per_plan
            FROM subscriptions s
            JOIN users u ON s.user_id = u.user_id
            WHERE s.plan_id = rec.plan_id
              AND (v_region='ALL' OR u.region=v_region)
              AND TRUNC(s.start_date,'MM') = TRUNC(v_report_month,'MM');

            -- Churned
            SELECT COUNT(DISTINCT s.user_id)
            INTO v_churned_per_plan
            FROM subscriptions s
            JOIN users u ON s.user_id = u.user_id
            WHERE s.plan_id = rec.plan_id
              AND (v_region='ALL' OR u.region=v_region)
              AND s.status='CANCELLED'
              AND TRUNC(s.end_date,'MM') = TRUNC(v_report_month,'MM');

            -- Plan share
            IF v_net_revenue>0 THEN
                v_plan_share := ROUND(v_plan_net_rev/v_net_revenue*100,2);
            ELSE
                v_plan_share := 0;
            END IF;

            DBMS_OUTPUT.PUT_LINE('Plan: ' || rec.plan_name);
            DBMS_OUTPUT.PUT_LINE('  Net Revenue: ' || v_plan_net_rev);
            DBMS_OUTPUT.PUT_LINE('  Active Subscribers: ' || v_active_per_plan);
            DBMS_OUTPUT.PUT_LINE('  New Subscribers: ' || v_new_per_plan);
            DBMS_OUTPUT.PUT_LINE('  Churned Subscribers: ' || v_churned_per_plan);
            DBMS_OUTPUT.PUT_LINE('  Plan Share of Net Revenue: ' || v_plan_share || '%');
        END;
    END LOOP;

    -- Platform-wide events
    DECLARE
        v_upgrades NUMBER := 0;
        v_downgrades NUMBER := 0;
        v_trials NUMBER := 0;
    BEGIN
        SELECT COUNT(*) INTO v_upgrades
        FROM subscription_events e
        JOIN subscriptions s ON e.subscription_id=s.subscription_id
        JOIN users u ON s.user_id = u.user_id
        WHERE e.event_type='PLAN_UPGRADE'
          AND TRUNC(e.event_date,'MM') = TRUNC(v_report_month,'MM')
          AND (v_region='ALL' OR u.region=v_region);

        SELECT COUNT(*) INTO v_downgrades
        FROM subscription_events e
        JOIN subscriptions s ON e.subscription_id=s.subscription_id
        JOIN users u ON s.user_id = u.user_id
        WHERE e.event_type='PLAN_DOWNGRADE'
          AND TRUNC(e.event_date,'MM') = TRUNC(v_report_month,'MM')
          AND (v_region='ALL' OR u.region=v_region);

        SELECT COUNT(*) INTO v_trials
        FROM subscription_events e
        JOIN subscriptions s ON e.subscription_id=s.subscription_id
        JOIN users u ON s.user_id = u.user_id
        WHERE e.event_type='TRIAL_CONVERTED'
          AND TRUNC(e.event_date,'MM') = TRUNC(v_report_month,'MM')
          AND (v_region='ALL' OR u.region=v_region);

        DBMS_OUTPUT.PUT_LINE('Platform-wide Events:');
        DBMS_OUTPUT.PUT_LINE('  Plan Upgrades: ' || v_upgrades);
        DBMS_OUTPUT.PUT_LINE('  Plan Downgrades: ' || v_downgrades);
        DBMS_OUTPUT.PUT_LINE('  Trial Conversions: ' || v_trials);
    END;
    DBMS_OUTPUT.PUT_LINE('');

    -- ===============================
    -- 3.4 Engagement & Usage Metrics
    -- ===============================
    BEGIN
        -- Total streaming minutes
        SELECT NVL(SUM(total_minutes),0)
        INTO v_total_stream_minutes
        FROM stream_sessions ss
        JOIN users u ON ss.user_id = u.user_id
        WHERE TRUNC(ss.session_start,'MM') = TRUNC(v_report_month,'MM')
          AND (v_region='ALL' OR u.region=v_region);

        -- Average per active subscriber
        IF v_active_subs>0 THEN
            v_avg_stream_per_user := ROUND(v_total_stream_minutes / v_active_subs,2);
        ELSE
            v_avg_stream_per_user := 0;
        END IF;

        -- Average session length
        SELECT NVL(ROUND(AVG(total_minutes),2),0)
        INTO v_avg_session_length
        FROM stream_sessions ss
        JOIN users u ON ss.user_id = u.user_id
        WHERE TRUNC(ss.session_start,'MM') = TRUNC(v_report_month,'MM')
          AND (v_region='ALL' OR u.region=v_region);

        DBMS_OUTPUT.PUT_LINE('--- Engagement & Usage Metrics ---');
        DBMS_OUTPUT.PUT_LINE('Total Streaming Minutes: ' || v_total_stream_minutes);
        DBMS_OUTPUT.PUT_LINE('Average Streaming Minutes per Active Subscriber: ' || v_avg_stream_per_user);
        DBMS_OUTPUT.PUT_LINE('Average Session Length: ' || v_avg_session_length);
        DBMS_OUTPUT.PUT_LINE('');

        -- Top 3 users by total minutes
        DBMS_OUTPUT.PUT_LINE('Top 3 Users by Total Streaming Minutes:');
        FOR r IN (
            SELECT u.full_name, SUM(ss.total_minutes) AS minutes
            FROM stream_sessions ss
            JOIN users u ON ss.user_id = u.user_id
            WHERE TRUNC(ss.session_start,'MM') = TRUNC(v_report_month,'MM')
              AND (v_region='ALL' OR u.region=v_region)
            GROUP BY u.full_name
            ORDER BY minutes DESC
            FETCH FIRST 3 ROWS ONLY
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  ' || r.full_name || ': ' || r.minutes || ' minutes');
        END LOOP;

        -- Device breakdown
        DBMS_OUTPUT.PUT_LINE('Device Breakdown:');
        FOR r IN (
            SELECT device_type, SUM(total_minutes) AS device_minutes,
                   ROUND(SUM(total_minutes)/NULLIF(v_total_stream_minutes,0)*100,2) AS pct_share
            FROM stream_sessions ss
            JOIN users u ON ss.user_id = u.user_id
            WHERE TRUNC(ss.session_start,'MM') = TRUNC(v_report_month,'MM')
              AND (v_region='ALL' OR u.region=v_region)
            GROUP BY device_type
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  ' || r.device_type || ': ' || r.device_minutes || ' minutes (' || r.pct_share || '%)');
        END LOOP;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No streaming sessions found for the selected month/region.');
    END;
    DBMS_OUTPUT.PUT_LINE('');

    -- ===============================
    -- 3.5 Churn & Retention Insights
    -- ===============================
    DBMS_OUTPUT.PUT_LINE('--- Churn & Retention Insights ---');
    DECLARE
        v_active_start NUMBER := 0;
        v_new_subs     NUMBER := 0;
        v_churned_subs NUMBER := 0;
        v_reactivated  NUMBER := 0;
        v_churn_rate   NUMBER := 0;
        v_retention    NUMBER := 0;
    BEGIN
        -- Active at start
        SELECT COUNT(DISTINCT s.user_id)
        INTO v_active_start
        FROM subscriptions s
        JOIN users u ON s.user_id = u.user_id
        WHERE (v_region='ALL' OR u.region=v_region)
          AND s.start_date <= v_report_month
          AND NVL(s.end_date, DATE '9999-12-31') >= v_report_month;

        -- New subscribers
        SELECT COUNT(DISTINCT s.user_id)
        INTO v_new_subs
        FROM subscriptions s
        JOIN users u ON s.user_id = u.user_id
        WHERE (v_region='ALL' OR u.region=v_region)
          AND TRUNC(s.start_date,'MM') = TRUNC(v_report_month,'MM');

        -- Churned
        SELECT COUNT(DISTINCT s.user_id)
        INTO v_churned_subs
        FROM subscriptions s
        JOIN users u ON s.user_id = u.user_id
        WHERE (v_region='ALL' OR u.region=v_region)
          AND s.status='CANCELLED'
          AND TRUNC(s.end_date,'MM') = TRUNC(v_report_month,'MM');

        -- Reactivated
        SELECT COUNT(DISTINCT s.user_id)
        INTO v_reactivated
        FROM subscription_events e
        JOIN subscriptions s ON e.subscription_id = s.subscription_id
        JOIN users u ON s.user_id = u.user_id
        WHERE (v_region='ALL' OR u.region=v_region)
          AND e.event_type='REACTIVATED'
          AND TRUNC(e.event_date,'MM') = TRUNC(v_report_month,'MM');

        DBMS_OUTPUT.PUT_LINE('Active Subscribers at Start of Month: ' || v_active_start);
        DBMS_OUTPUT.PUT_LINE('New Subscribers in Month: ' || v_new_subs);
        DBMS_OUTPUT.PUT_LINE('Churned Subscribers: ' || v_churned_subs);
        DBMS_OUTPUT.PUT_LINE('Reactivated Subscribers: ' || v_reactivated);

        IF v_active_start>0 THEN
            v_churn_rate := ROUND(v_churned_subs/v_active_start*100,2);
            v_retention := 100 - v_churn_rate;
            DBMS_OUTPUT.PUT_LINE('Monthly Churn Rate: ' || v_churn_rate || '%');
            DBMS_OUTPUT.PUT_LINE('Retention Rate: ' || v_retention || '%');
        ELSE
            DBMS_OUTPUT.PUT_LINE('No active subscribers at start – churn/retention N/A.');
        END IF;
    END;
    DBMS_OUTPUT.PUT_LINE('');

    -- ===============================
    -- 3.6 Regional Breakdown
    -- ===============================
    DBMS_OUTPUT.PUT_LINE('--- Regional Breakdown ---');
    IF v_region='ALL' THEN
        FOR r IN (
            SELECT u.region,
                   NVL(SUM(p.amount-NVL(p.discount_amount,0)),0) AS net_rev,
                   COUNT(DISTINCT s.user_id) AS active_subs,
                   NVL(SUM(ss.total_minutes),0) AS total_minutes
            FROM users u
            LEFT JOIN subscriptions s ON u.user_id=s.user_id
            LEFT JOIN payments p ON s.subscription_id=p.subscription_id AND TRUNC(p.payment_date,'MM') = TRUNC(v_report_month,'MM')
            LEFT JOIN stream_sessions ss ON u.user_id=ss.user_id AND TRUNC(ss.session_start,'MM') = TRUNC(v_report_month,'MM')
            GROUP BY u.region
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Region: ' || r.region || ', Net Revenue: ' || r.net_rev || 
                                 ', Active Subscribers: ' || r.active_subs || 
                                 ', Total Streaming Minutes: ' || r.total_minutes);
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Report filtered to region: ' || v_region);
    END IF;
    DBMS_OUTPUT.PUT_LINE('');

    -- ===============================
    -- 3.7 Data Quality Check
    -- ===============================
    DBMS_OUTPUT.PUT_LINE('--- Data Quality Issues ---');

    -- Payments zero/negative
    DECLARE v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM payments WHERE amount<=0;
        DBMS_OUTPUT.PUT_LINE('Payments with zero/negative amount: ' || v_count);
    END;

    -- Subscriptions end < start
    BEGIN
        SELECT COUNT(*) INTO v_count FROM subscriptions WHERE end_date IS NOT NULL AND end_date < start_date;
        DBMS_OUTPUT.PUT_LINE('Subscriptions with end_date earlier than start_date: ' || v_count);
    END;

    -- Streaming sessions invalid
    BEGIN
        SELECT COUNT(*) INTO v_count FROM stream_sessions
        WHERE (session_end IS NOT NULL AND session_end < session_start) OR total_minutes<=0;
        DBMS_OUTPUT.PUT_LINE('Streaming sessions with invalid times/minutes: ' || v_count);
    END;

    -- Users with active subscriptions but no sessions
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM users u
        WHERE EXISTS (SELECT 1 FROM subscriptions s WHERE s.user_id
