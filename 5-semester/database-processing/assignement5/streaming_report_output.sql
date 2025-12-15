/*******************************************************
 * Author:      Artjoms Voroncovs
 * Date:        13-DEC-2025
 * Description: Monthly Subscription and Engagement Performance Report
 * 
 * This PL/SQL script generates a comprehensive monthly report
 * for a streaming platform, including the following sections:
 * 
 *  3.1 Header Information
 *      - Company name, report month, region filter, timestamp
 * 
 *  3.2 Overall Subscription and Revenue Summary
 *      - Gross revenue, total discounts, net revenue
 *      - Paid subscriptions billed, active subscribers
 *      - ARPU and net revenue growth vs previous month
 * 
 *  3.3 Plan Performance
 *      - Metrics per subscription plan (Basic, Standard, Premium)
 *      - Net revenue, active subscribers, new and churned subscriptions
 *      - Plan revenue share
 *      - Platform-wide plan events (upgrades, downgrades, trial conversions)
 * 
 *  3.4 Engagement and Usage Metrics
 *      - Total streaming minutes, average minutes per user
 *      - Top 3 users by streaming minutes
 *      - Device breakdown with usage percentage
 *      - Average session length
 * 
 *  3.5 Churn and Retention Insights
 *      - Active subscribers at start of month
 *      - New, churned, and reactivated subscribers
 *      - Monthly churn and retention rates
 * 
 *  3.6 Regional Breakdown
 *      - Net revenue, active subscribers, and streaming minutes per region
 *      - Conditional handling for filtered region reports
 * 
 *  3.7 Data Quality Check
 *      - Identifies issues like negative payments, invalid subscription dates,
 *        invalid streaming sessions, active users without sessions, and missing subscriptions
 * 
 *  3.8 Graceful Handling of Missing Data
 *      - Prevents crashes if no data exists
 *      - Prints friendly messages when data is missing
 * 
 * Business Rules:
 *  - Consistent definitions for active subscriptions, new/churned/reactivated subscribers,
 *    payment and streaming inclusion in report month, ARPU, revenue growth, and churn/retention calculations
 *  - Data quality checks are computed dynamically
 *
 *******************************************************/


SET SERVEROUTPUT ON

DECLARE
    -- =======================
    -- REPORT PARAMETERS
    -- =======================
    v_company_name   CONSTANT VARCHAR2(50) := 'StreamNova Media';

    -- Use FIRST DAY of month
    v_report_month   DATE := DATE '2025-02-01';
    v_region_filter  VARCHAR2(10) := 'ALL';       -- 'ALL', 'EU', 'US', 'APAC'

    -- =======================
    -- DATE CALCULATIONS
    -- =======================
    v_month_start    DATE;
    v_month_end      DATE;
    v_prev_start     DATE;
    v_prev_end       DATE;

    -- =======================
    -- METRICS (CURRENT MONTH)
    -- =======================
    v_gross_revenue      NUMBER := 0;
    v_total_discounts   NUMBER := 0;
    v_net_revenue       NUMBER := 0;
    v_paid_subs          NUMBER := 0;
    v_active_users       NUMBER := 0;
    v_arpu               NUMBER := 0;

    -- =======================
    -- PREVIOUS MONTH
    -- =======================
    v_prev_net_revenue   NUMBER := 0;
    v_growth_percent     NUMBER;

BEGIN
    -- =======================
    -- DATE BOUNDARIES
    -- =======================
    v_month_start := TRUNC(v_report_month, 'MM');
    v_month_end   := LAST_DAY(v_month_start);

    v_prev_start  := ADD_MONTHS(v_month_start, -1);
    v_prev_end    := LAST_DAY(v_prev_start);

    -- =====================================================
    -- 3.1 HEADER INFORMATION
    -- =====================================================
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.PUT_LINE('Company:          ' || v_company_name);
    DBMS_OUTPUT.PUT_LINE('Report Month:     ' || TO_CHAR(v_month_start, 'YYYY-MM'));
    DBMS_OUTPUT.PUT_LINE('Region Filter:    ' || v_region_filter);
    DBMS_OUTPUT.PUT_LINE('Generated At:     ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('==============================================');
    DBMS_OUTPUT.NEW_LINE;

    -- =====================================================
    -- 3.2 OVERALL SUBSCRIPTION and REVENUE SUMMARY
    -- =====================================================

    -- Gross revenue and discounts
    SELECT
        NVL(SUM(p.amount), 0),
        NVL(SUM(p.discount_amount), 0)
    INTO
        v_gross_revenue,
        v_total_discounts
    FROM payments p
    JOIN subscriptions s ON s.subscription_id = p.subscription_id
    JOIN users u ON u.user_id = s.user_id
    WHERE p.payment_date BETWEEN v_month_start AND v_month_end
      AND (v_region_filter = 'ALL' OR u.region = v_region_filter);

    v_net_revenue := v_gross_revenue - v_total_discounts;

    -- Paid subscriptions billed
    SELECT COUNT(DISTINCT p.subscription_id)
    INTO v_paid_subs
    FROM payments p
    JOIN subscriptions s ON s.subscription_id = p.subscription_id
    JOIN users u ON u.user_id = s.user_id
    WHERE p.payment_date BETWEEN v_month_start AND v_month_end
      AND (v_region_filter = 'ALL' OR u.region = v_region_filter);

    -- Active subscribers in month
    SELECT COUNT(DISTINCT s.user_id)
    INTO v_active_users
    FROM subscriptions s
    JOIN users u ON u.user_id = s.user_id
    WHERE s.start_date <= v_month_end
      AND (s.end_date IS NULL OR s.end_date >= v_month_start)
      AND s.status = 'ACTIVE'
      AND (v_region_filter = 'ALL' OR u.region = v_region_filter);

    -- ARPU
    IF v_active_users > 0 THEN
        v_arpu := v_net_revenue / v_active_users;
    END IF;

    -- =======================
    -- PREVIOUS MONTH NET REVENUE
    -- =======================
    SELECT
        NVL(SUM(p.amount - p.discount_amount), 0)
    INTO v_prev_net_revenue
    FROM payments p
    JOIN subscriptions s ON s.subscription_id = p.subscription_id
    JOIN users u ON u.user_id = s.user_id
    WHERE p.payment_date BETWEEN v_prev_start AND v_prev_end
      AND (v_region_filter = 'ALL' OR u.region = v_region_filter);

    -- =====================================================
    -- OUTPUT SUMMARY
    -- =====================================================
    DBMS_OUTPUT.PUT_LINE('Overall Subscription and Revenue Summary');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Gross Revenue:        ' || v_gross_revenue);
    DBMS_OUTPUT.PUT_LINE('Total Discounts Given:      ' || v_total_discounts);
    DBMS_OUTPUT.PUT_LINE('Net Revenue:                ' || v_net_revenue);
    DBMS_OUTPUT.PUT_LINE('Paid Subscriptions Billed:  ' || v_paid_subs);
    DBMS_OUTPUT.PUT_LINE('Active Subscribers:         ' || v_active_users);
    DBMS_OUTPUT.PUT_LINE('ARPU:                       ' || ROUND(v_arpu, 2));

    -- Growth %
    IF v_prev_net_revenue > 0 THEN
        v_growth_percent :=
            (v_net_revenue - v_prev_net_revenue) / v_prev_net_revenue * 100;

        DBMS_OUTPUT.PUT_LINE(
            'Net Revenue Growth vs Prev: '
            || ROUND(v_growth_percent, 2) || '%'
        );
    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'Net Revenue Growth vs Prev: No prior month data – growth not applicable.'
        );
    END IF;


    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('3.3 Plan Performance');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');

    -- =====================================================
    -- PER-PLAN METRICS
    -- =====================================================
    FOR r IN (
        SELECT
            pl.plan_id,
            pl.plan_name,

            -- Net revenue per plan
            NVL(SUM(p.amount - p.discount_amount), 0) AS net_revenue,

            -- Active subscribers per plan during month
            COUNT(
                DISTINCT CASE
                    WHEN s.start_date <= v_month_end
                     AND (s.end_date IS NULL OR s.end_date >= v_month_start)
                     AND s.status = 'ACTIVE'
                    THEN s.user_id
                END
            ) AS active_subscribers,

            -- New subscribers (first subscription in report month)
            COUNT(
                DISTINCT CASE
                    WHEN s.start_date BETWEEN v_month_start AND v_month_end
                     AND s.subscription_id = (
                        SELECT MIN(s2.subscription_id)
                        FROM subscriptions s2
                        WHERE s2.user_id = s.user_id
                     )
                    THEN s.user_id
                END
            ) AS new_subscribers,

            -- Churned subscribers in report month
            COUNT(
                DISTINCT CASE
                    WHEN s.end_date BETWEEN v_month_start AND v_month_end
                     AND s.status = 'CANCELLED'
                    THEN s.subscription_id
                END
            ) AS churned_subscriptions

        FROM plans pl
        LEFT JOIN subscriptions s ON s.plan_id = pl.plan_id
        LEFT JOIN users u ON u.user_id = s.user_id
        LEFT JOIN payments p
               ON p.subscription_id = s.subscription_id
              AND p.payment_date BETWEEN v_month_start AND v_month_end
        WHERE (v_region_filter = 'ALL' OR u.region = v_region_filter)
        GROUP BY pl.plan_id, pl.plan_name
        ORDER BY pl.plan_id
    ) LOOP

        DBMS_OUTPUT.PUT_LINE('Plan: ' || r.plan_name);
        DBMS_OUTPUT.PUT_LINE('  Net Revenue:              ' || r.net_revenue);
        DBMS_OUTPUT.PUT_LINE('  Active Subscribers:       ' || r.active_subscribers);
        DBMS_OUTPUT.PUT_LINE('  New Subscribers:          ' || r.new_subscribers);
        DBMS_OUTPUT.PUT_LINE('  Churned Subscriptions:    ' || r.churned_subscriptions);

        -- Plan share of total net revenue
        IF v_net_revenue > 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                '  Revenue Share (%):        '
                || ROUND((r.net_revenue / v_net_revenue) * 100, 2)
            );
        ELSE
            DBMS_OUTPUT.PUT_LINE(
                '  Revenue Share (%):        N/A'
            );
        END IF;

        DBMS_OUTPUT.NEW_LINE;
    END LOOP;

    -- =====================================================
    -- PLATFORM-WIDE PLAN EVENTS
    -- =====================================================
    DECLARE
        v_upgrades   NUMBER := 0;
        v_downgrades NUMBER := 0;
        v_trials     NUMBER := 0;
    BEGIN
        SELECT
            COUNT(CASE WHEN event_type = 'PLAN_UPGRADE' THEN 1 END),
            COUNT(CASE WHEN event_type = 'PLAN_DOWNGRADE' THEN 1 END),
            COUNT(CASE WHEN event_type = 'TRIAL_CONVERTED' THEN 1 END)
        INTO
            v_upgrades,
            v_downgrades,
            v_trials
        FROM subscription_events e
        JOIN subscriptions s ON s.subscription_id = e.subscription_id
        JOIN users u ON u.user_id = s.user_id
        WHERE e.event_date BETWEEN v_month_start AND v_month_end
          AND (v_region_filter = 'ALL' OR u.region = v_region_filter);

        DBMS_OUTPUT.PUT_LINE('Platform-wide Plan Events');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Plan Upgrades:      ' || v_upgrades);
        DBMS_OUTPUT.PUT_LINE('Plan Downgrades:    ' || v_downgrades);
        DBMS_OUTPUT.PUT_LINE('Trial Conversions:  ' || v_trials);
    END;

    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('3.4 Engagement and Usage Metrics');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');

    DECLARE
        v_total_minutes     NUMBER := 0;
        v_avg_per_user      NUMBER := 0;
        v_avg_session_len   NUMBER := 0;
    BEGIN
        -- =========================================
        -- TOTAL STREAMING MINUTES
        -- =========================================
        SELECT NVL(SUM(ss.total_minutes), 0)
        INTO v_total_minutes
        FROM stream_sessions ss
        JOIN users u ON u.user_id = ss.user_id
        WHERE ss.session_start BETWEEN v_month_start AND v_month_end
          AND (v_region_filter = 'ALL' OR u.region = v_region_filter);

        -- =========================================
        -- AVERAGE MINUTES PER ACTIVE SUBSCRIBER
        -- =========================================
        IF v_active_users > 0 THEN
            v_avg_per_user := v_total_minutes / v_active_users;
        END IF;

        -- =========================================
        -- AVERAGE SESSION LENGTH
        -- =========================================
        SELECT NVL(AVG(ss.total_minutes), 0)
        INTO v_avg_session_len
        FROM stream_sessions ss
        JOIN users u ON u.user_id = ss.user_id
        WHERE ss.session_start BETWEEN v_month_start AND v_month_end
          AND (v_region_filter = 'ALL' OR u.region = v_region_filter);

        DBMS_OUTPUT.PUT_LINE('Total Streaming Minutes:            ' || v_total_minutes);
        DBMS_OUTPUT.PUT_LINE('Avg Minutes per Active Subscriber:  ' || ROUND(v_avg_per_user, 2));
        DBMS_OUTPUT.PUT_LINE('Average Session Length (minutes):   ' || ROUND(v_avg_session_len, 2));
    END;

    -- =========================================
    -- TOP 3 USERS BY STREAMING MINUTES
    -- =========================================
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Top 3 Users by Streaming Minutes');

    FOR r IN (
        SELECT
            u.full_name,
            SUM(ss.total_minutes) AS total_minutes
        FROM stream_sessions ss
        JOIN users u ON u.user_id = ss.user_id
        WHERE ss.session_start BETWEEN v_month_start AND v_month_end
          AND (v_region_filter = 'ALL' OR u.region = v_region_filter)
        GROUP BY u.full_name
        ORDER BY total_minutes DESC
        FETCH FIRST 3 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            '  ' || r.full_name || ' - ' || r.total_minutes || ' minutes'
        );
    END LOOP;

    -- =========================================
    -- DEVICE BREAKDOWN
    -- =========================================
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('Device Usage Breakdown');

    DECLARE
        v_total_minutes     NUMBER := 0;
    BEGIN
        FOR d IN (
            SELECT
                ss.device_type,
                SUM(ss.total_minutes) AS device_minutes
            FROM stream_sessions ss
            JOIN users u ON u.user_id = ss.user_id
            WHERE ss.session_start BETWEEN v_month_start AND v_month_end
              AND (v_region_filter = 'ALL' OR u.region = v_region_filter)
            GROUP BY ss.device_type
            ORDER BY device_minutes DESC
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                '  ' || d.device_type
                || ': ' || d.device_minutes || ' minutes'
                || CASE
                    WHEN v_total_minutes > 0 THEN
                        ' (' || ROUND((d.device_minutes / v_total_minutes) * 100, 2) || '%)'
                    ELSE
                        ''
                  END
            );
        END LOOP;
    END;

    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('3.5 Churn and Retention Insights');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');

    DECLARE
        v_active_start     NUMBER := 0;
        v_new_subs         NUMBER := 0;
        v_churned_subs     NUMBER := 0;
        v_reactivated      NUMBER := 0;
        v_churn_rate       NUMBER := 0;
        v_retention_rate   NUMBER := 0;
    BEGIN
        -- =====================================================
        -- Active subscribers at START of month
        -- =====================================================
        SELECT COUNT(DISTINCT s.user_id)
        INTO v_active_start
        FROM subscriptions s
        JOIN users u ON u.user_id = s.user_id
        WHERE s.start_date <= v_month_start
          AND (s.end_date IS NULL OR s.end_date >= v_month_start)
          AND s.status = 'ACTIVE'
          AND (v_region_filter = 'ALL' OR u.region = v_region_filter);

        -- =====================================================
        -- New subscribers (first-ever subscription in month)
        -- =====================================================
        SELECT COUNT(DISTINCT s.user_id)
        INTO v_new_subs
        FROM subscriptions s
        JOIN users u ON u.user_id = s.user_id
        WHERE s.start_date BETWEEN v_month_start AND v_month_end
          AND s.subscription_id = (
              SELECT MIN(s2.subscription_id)
              FROM subscriptions s2
              WHERE s2.user_id = s.user_id
          )
          AND (v_region_filter = 'ALL' OR u.region = v_region_filter);

        -- =====================================================
        -- Churned subscribers in month
        -- =====================================================
        SELECT COUNT(DISTINCT s.subscription_id)
        INTO v_churned_subs
        FROM subscriptions s
        JOIN users u ON u.user_id = s.user_id
        WHERE s.end_date BETWEEN v_month_start AND v_month_end
          AND s.status = 'CANCELLED'
          AND (v_region_filter = 'ALL' OR u.region = v_region_filter);

        -- =====================================================
        -- Reactivated subscribers
        -- =====================================================
        SELECT COUNT(DISTINCT e.subscription_id)
        INTO v_reactivated
        FROM subscription_events e
        JOIN subscriptions s ON s.subscription_id = e.subscription_id
        JOIN users u ON u.user_id = s.user_id
        WHERE e.event_type = 'REACTIVATED'
          AND e.event_date BETWEEN v_month_start AND v_month_end
          AND (v_region_filter = 'ALL' OR u.region = v_region_filter);

        -- =====================================================
        -- Churn and Retention Rates
        -- =====================================================
        IF v_active_start > 0 THEN
            v_churn_rate := (v_churned_subs / v_active_start) * 100;
            v_retention_rate := 100 - v_churn_rate;
        END IF;

        -- =====================================================
        -- OUTPUT
        -- =====================================================
        DBMS_OUTPUT.PUT_LINE('Active at Start of Month:   ' || v_active_start);
        DBMS_OUTPUT.PUT_LINE('New Subscribers:            ' || v_new_subs);
        DBMS_OUTPUT.PUT_LINE('Churned Subscribers:        ' || v_churned_subs);
        DBMS_OUTPUT.PUT_LINE('Reactivated Subscribers:    ' || v_reactivated);

        IF v_active_start > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Monthly Churn Rate (%):     ' || ROUND(v_churn_rate, 2));
            DBMS_OUTPUT.PUT_LINE('Retention Rate (%):         ' || ROUND(v_retention_rate, 2));
        ELSE
            DBMS_OUTPUT.PUT_LINE('Monthly Churn Rate (%):     N/A (no active users at start)');
            DBMS_OUTPUT.PUT_LINE('Retention Rate (%):         N/A');
        END IF;

    END;

    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('3.6 Regional Breakdown');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');

    IF v_region_filter = 'ALL' THEN

        DBMS_OUTPUT.PUT_LINE('Region | Net Revenue | Active Subscribers | Streaming Minutes');
        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------');

        FOR r IN (
            SELECT
                u.region,

                -- Net revenue per region
                NVL(SUM(p.amount - p.discount_amount), 0) AS net_revenue,

                -- Active subscribers per region
                COUNT(
                    DISTINCT CASE
                        WHEN s.start_date <= v_month_end
                         AND (s.end_date IS NULL OR s.end_date >= v_month_start)
                         AND s.status = 'ACTIVE'
                        THEN s.user_id
                    END
                ) AS active_subscribers,

                -- Total streaming minutes per region
                NVL(SUM(ss.total_minutes), 0) AS streaming_minutes

            FROM users u
            LEFT JOIN subscriptions s ON s.user_id = u.user_id
            LEFT JOIN payments p
                   ON p.subscription_id = s.subscription_id
                  AND p.payment_date BETWEEN v_month_start AND v_month_end
            LEFT JOIN stream_sessions ss
                   ON ss.user_id = u.user_id
                  AND ss.session_start BETWEEN v_month_start AND v_month_end
            GROUP BY u.region
            ORDER BY u.region
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(r.region, 7) || ' | '
                || LPAD(r.net_revenue, 11) || ' | '
                || LPAD(r.active_subscribers, 18) || ' | '
                || LPAD(r.streaming_minutes, 17)
            );
        END LOOP;

    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'Report is filtered by region ('
            || v_region_filter
            || '). Regional breakdown is not applicable.'
        );
    END IF;

    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE('3.7 Data Quality Check');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');

    DECLARE
        -- Generic variable for counts
        v_cnt NUMBER;

        -- Cursors for examples
        CURSOR c_pay_zero IS
            SELECT payment_id FROM payments WHERE amount <= 0 FETCH FIRST 3 ROWS ONLY;
        CURSOR c_sub_invalid_dates IS
            SELECT subscription_id FROM subscriptions WHERE end_date IS NOT NULL AND end_date < start_date FETCH FIRST 3 ROWS ONLY;
        CURSOR c_stream_invalid IS
            SELECT session_id FROM stream_sessions WHERE (session_end IS NOT NULL AND session_end < session_start) OR total_minutes <= 0 FETCH FIRST 3 ROWS ONLY;
        CURSOR c_active_no_stream IS
            SELECT DISTINCT s.user_id
            FROM subscriptions s
            WHERE s.status = 'ACTIVE'
              AND NOT EXISTS (SELECT 1 FROM stream_sessions ss WHERE ss.user_id = s.user_id)
            FETCH FIRST 3 ROWS ONLY;
        CURSOR c_pay_missing_sub IS
            SELECT p.payment_id
            FROM payments p
            LEFT JOIN subscriptions s ON s.subscription_id = p.subscription_id
            WHERE s.subscription_id IS NULL
            FETCH FIRST 3 ROWS ONLY;

        -- Helper variable for iterating example IDs
        v_id NUMBER;
    BEGIN
        -- ========================================
        -- 1. Payments with zero or negative amounts
        -- ========================================
        SELECT COUNT(*) INTO v_cnt FROM payments WHERE amount <= 0;
        DBMS_OUTPUT.PUT_LINE('Issue: Payments with zero or negative amount');
        DBMS_OUTPUT.PUT_LINE('Count: ' || v_cnt);
        DBMS_OUTPUT.PUT('Example IDs: ');
        FOR r IN c_pay_zero LOOP
            DBMS_OUTPUT.PUT(r.payment_id || ' ');
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.NEW_LINE;

        -- ========================================
        -- 2. Subscriptions with invalid date ranges
        -- ========================================
        SELECT COUNT(*) INTO v_cnt FROM subscriptions WHERE end_date IS NOT NULL AND end_date < start_date;
        DBMS_OUTPUT.PUT_LINE('Issue: Subscriptions with end_date < start_date');
        DBMS_OUTPUT.PUT_LINE('Count: ' || v_cnt);
        DBMS_OUTPUT.PUT('Example IDs: ');
        FOR r IN c_sub_invalid_dates LOOP
            DBMS_OUTPUT.PUT(r.subscription_id || ' ');
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.NEW_LINE;

        -- ========================================
        -- 3. Streaming sessions with invalid timing or minutes
        -- ========================================
        SELECT COUNT(*) INTO v_cnt
        FROM stream_sessions
        WHERE (session_end IS NOT NULL AND session_end < session_start) OR total_minutes <= 0;
        DBMS_OUTPUT.PUT_LINE('Issue: Invalid streaming sessions (time or minutes)');
        DBMS_OUTPUT.PUT_LINE('Count: ' || v_cnt);
        DBMS_OUTPUT.PUT('Example IDs: ');
        FOR r IN c_stream_invalid LOOP
            DBMS_OUTPUT.PUT(r.session_id || ' ');
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.NEW_LINE;

        -- ========================================
        -- 4. Active subscribers with no streaming sessions ever
        -- ========================================
        SELECT COUNT(DISTINCT s.user_id) INTO v_cnt
        FROM subscriptions s
        WHERE s.status = 'ACTIVE'
          AND NOT EXISTS (SELECT 1 FROM stream_sessions ss WHERE ss.user_id = s.user_id);
        DBMS_OUTPUT.PUT_LINE('Issue: Active users with no streaming sessions');
        DBMS_OUTPUT.PUT_LINE('Count: ' || v_cnt);
        DBMS_OUTPUT.PUT('Example IDs: ');
        FOR r IN c_active_no_stream LOOP
            DBMS_OUTPUT.PUT(r.user_id || ' ');
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.NEW_LINE;

        -- ========================================
        -- 5. Payments with missing subscription reference
        -- ========================================
        SELECT COUNT(*) INTO v_cnt
        FROM payments p
        LEFT JOIN subscriptions s ON s.subscription_id = p.subscription_id
        WHERE s.subscription_id IS NULL;
        DBMS_OUTPUT.PUT_LINE('Issue: Payments with missing subscription reference');
        DBMS_OUTPUT.PUT_LINE('Count: ' || v_cnt);
        DBMS_OUTPUT.PUT('Example IDs: ');
        FOR r IN c_pay_missing_sub LOOP
            DBMS_OUTPUT.PUT(r.payment_id || ' ');
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
        DBMS_OUTPUT.PUT_LINE('Data Quality Check completed.');

    END;
END;
/
