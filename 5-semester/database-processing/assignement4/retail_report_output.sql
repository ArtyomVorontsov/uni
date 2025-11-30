/*******************************************************
 * Author:      Artjoms Voroncovs
 * Date:        29-NOV-2025
 * Description:
 *   This PL/SQL script generates a Monthly Sales Performance Report
 *   using DBMS_OUTPUT.PUT_LINE. The report covers sales activity
 *   for a specified month and includes the following sections:
 *
 *   1. Header Information:
 *      - Company name (placeholder)
 *      - Selected report month
 *      - Timestamp of report generation
 *
 *   2. Overall Summary:
 *      - Total gross sales for the month
 *      - Total discounts given
 *      - Net revenue (sales minus discounts)
 *      - Number of orders and unique customers
 *      - Average order value (AOV)
 *      - Sales growth compared to the previous month (if available)
 *
 *   3. Category Performance:
 *      - Total sales and number of products sold per category
 *      - Average discount percentage per category
 *      - Percentage share of total sales per category
 *
 *   4. Top Products:
 *      - Top 3 products by revenue
 *      - Top 3 products by quantity sold
 *
 *   5. Store Performance:
 *      - Total sales per store
 *      - Average order size by store
 *      - Store share of total revenue (in %)
 *
 *   6. Customer Insights:
 *      - Number of new customers (first purchase in report month)
 *      - Number of repeat customers
 *      - Top 3 customers by spending
 *
 *   7. Data Quality Check:
 *      - Number of orders with no lines or invalid amounts
 *
 *   The script dynamically calculates all values based on the underlying
 *   ORDERS, ORDER_LINES, CUSTOMERS, PRODUCTS, and STORES tables.
 *******************************************************/


SET SERVEROUTPUT ON;

DECLARE
    ----------------------------------------------------------------------
    -- PARAMETERS
    ----------------------------------------------------------------------
    p_year  NUMBER := 2025;
    p_month NUMBER := 1;

    v_prev_year  NUMBER;
    v_prev_month NUMBER;
    v_report_month VARCHAR2(30);

    ----------------------------------------------------------------------
    -- OVERALL SUMMARY VARIABLES
    ----------------------------------------------------------------------
    v_total_sales        NUMBER := 0;
    v_total_discounts    NUMBER := 0;
    v_net_revenue        NUMBER := 0;
    v_num_orders         NUMBER := 0;
    v_unique_customers   NUMBER := 0;
    v_avg_order_value    NUMBER := 0;
    v_prev_net_revenue   NUMBER := 0;
    v_growth_percent     NUMBER := NULL;

    ----------------------------------------------------------------------
    -- DATA QUALITY VARIABLES
    ----------------------------------------------------------------------
    v_invalid_orders NUMBER := 0;

BEGIN
    ----------------------------------------------------------------------
    -- SET PREVIOUS MONTH
    ----------------------------------------------------------------------
    IF p_month = 1 THEN
        v_prev_month := 12;
        v_prev_year  := p_year - 1;
    ELSE
        v_prev_month := p_month - 1;
        v_prev_year  := p_year;
    END IF;

    ----------------------------------------------------------------------
    -- MONTH NAME
    ----------------------------------------------------------------------
    v_report_month :=
        TO_CHAR(TO_DATE(p_year||'-'||p_month||'-01','YYYY-MM-DD'), 'Month YYYY');

    ----------------------------------------------------------------------
    -- OVERALL SUMMARY CALCULATIONS
    ----------------------------------------------------------------------
    SELECT
        NVL(SUM(total_amount),0),
        NVL(SUM(discount_amount),0),
        COUNT(*),
        COUNT(DISTINCT customer_id)
    INTO
        v_total_sales,
        v_total_discounts,
        v_num_orders,
        v_unique_customers
    FROM ORDERS
    WHERE EXTRACT(YEAR FROM order_date)  = p_year
      AND EXTRACT(MONTH FROM order_date) = p_month;

    v_net_revenue := v_total_sales - v_total_discounts;

    IF v_num_orders > 0 THEN
        v_avg_order_value := v_net_revenue / v_num_orders;
    END IF;

    -- Previous month revenue
    SELECT NVL(SUM(total_amount - discount_amount),0)
    INTO v_prev_net_revenue
    FROM ORDERS
    WHERE EXTRACT(YEAR FROM order_date)  = v_prev_year
      AND EXTRACT(MONTH FROM order_date) = v_prev_month;

    IF v_prev_net_revenue > 0 THEN
        v_growth_percent :=
            ROUND( (v_net_revenue - v_prev_net_revenue) / v_prev_net_revenue * 100, 2 );
    END IF;

    ----------------------------------------------------------------------
    -- DATA QUALITY CHECK
    ----------------------------------------------------------------------
    SELECT COUNT(*)
    INTO v_invalid_orders
    FROM ORDERS o
    LEFT JOIN ORDER_LINES l ON o.order_id = l.order_id
    WHERE l.order_id IS NULL
       OR o.total_amount < 0
       OR o.discount_amount < 0;

    ----------------------------------------------------------------------
    -- REPORT HEADER
    ----------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('                 MONTHLY SALES REPORT');
    DBMS_OUTPUT.PUT_LINE('                 COMPANY: Example Retail Inc.');
    DBMS_OUTPUT.PUT_LINE('                 PERIOD: ' || TRIM(v_report_month));
    DBMS_OUTPUT.PUT_LINE('                 GENERATED: ' ||
                         TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('');

    ----------------------------------------------------------------------
    -- OVERALL SUMMARY
    ----------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('--- OVERALL SUMMARY ---------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Sales................: ' || v_total_sales);
    DBMS_OUTPUT.PUT_LINE('Total Discounts............: ' || v_total_discounts);
    DBMS_OUTPUT.PUT_LINE('Net Revenue................: ' || v_net_revenue);
    DBMS_OUTPUT.PUT_LINE('Number of Orders...........: ' || v_num_orders);
    DBMS_OUTPUT.PUT_LINE('Unique Customers...........: ' || v_unique_customers);
    DBMS_OUTPUT.PUT_LINE('Average Order Value (AOV)..: ' || ROUND(v_avg_order_value,2));

    IF v_growth_percent IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Growth vs Previous Month...: ' || v_growth_percent || '%');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Growth vs Previous Month...: Not available');
    END IF;

    DBMS_OUTPUT.PUT_LINE('');

    ----------------------------------------------------------------------
    -- CATEGORY PERFORMANCE
    ----------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('--- CATEGORY PERFORMANCE -----------------------------------');

    FOR r IN (
        SELECT
            p.category,
            SUM(l.quantity * l.line_price) AS revenue,
            SUM(l.quantity) AS units_sold,
            ROUND(AVG(o.discount_amount / NULLIF(o.total_amount,0)) * 100,2) AS avg_disc,
            ROUND(
                SUM(l.quantity * l.line_price)
                / NULLIF(v_total_sales,0) * 100, 2
            ) AS share_pct
        FROM ORDER_LINES l
        JOIN ORDERS o    ON l.order_id = o.order_id
        JOIN PRODUCTS p  ON l.product_id = p.product_id
        WHERE EXTRACT(YEAR FROM o.order_date)  = p_year
          AND EXTRACT(MONTH FROM o.order_date) = p_month
        GROUP BY p.category
        ORDER BY revenue DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Category: ' || r.category ||
            ' | Revenue: ' || r.revenue ||
            ' | Units Sold: ' || r.units_sold ||
            ' | Avg Discount: ' || NVL(r.avg_disc,0) || '%' ||
            ' | Share: ' || NVL(r.share_pct,0) || '%'
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');

    ----------------------------------------------------------------------
    -- TOP PRODUCTS
    ----------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('--- TOP PRODUCTS -------------------------------------------');

    DBMS_OUTPUT.PUT_LINE('Top 3 by Revenue:');
    FOR r IN (
        SELECT p.name AS product_name,
               SUM(l.quantity * l.line_price) AS revenue
        FROM ORDER_LINES l
        JOIN ORDERS o ON l.order_id = o.order_id
        JOIN PRODUCTS p ON l.product_id = p.product_id
        WHERE EXTRACT(YEAR FROM o.order_date)=p_year
          AND EXTRACT(MONTH FROM o.order_date)=p_month
        GROUP BY p.name
        ORDER BY revenue DESC
        FETCH FIRST 3 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  - ' || r.product_name || ': ' || r.revenue);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Top 3 by Quantity Sold:');
    FOR r IN (
        SELECT p.name AS product_name,
               SUM(l.quantity) AS qty
        FROM ORDER_LINES l
        JOIN ORDERS o ON l.order_id = o.order_id
        JOIN PRODUCTS p ON l.product_id = p.product_id
        WHERE EXTRACT(YEAR FROM o.order_date)=p_year
          AND EXTRACT(MONTH FROM o.order_date)=p_month
        GROUP BY p.name
        ORDER BY qty DESC
        FETCH FIRST 3 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  - ' || r.product_name || ': ' || r.qty);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');

    ----------------------------------------------------------------------
    -- STORE PERFORMANCE
    ----------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('--- STORE PERFORMANCE --------------------------------------');

    FOR r IN (
        SELECT
            s.name AS store_name,
            SUM(o.total_amount - o.discount_amount) AS revenue,
            AVG(o.total_amount - o.discount_amount) AS avg_order,
            ROUND(
               SUM(o.total_amount - o.discount_amount)
               / NULLIF(v_net_revenue,0) * 100, 2
            ) AS share_pct
        FROM ORDERS o
        JOIN STORES s ON o.store_id = s.store_id
        WHERE EXTRACT(YEAR FROM o.order_date)=p_year
          AND EXTRACT(MONTH FROM o.order_date)=p_month
        GROUP BY s.name
        ORDER BY revenue DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Store: ' || r.store_name ||
            ' | Revenue: ' || r.revenue ||
            ' | Avg Order Size: ' || ROUND(r.avg_order,2) ||
            ' | Share: ' || r.share_pct || '%'
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');

    ----------------------------------------------------------------------
    -- CUSTOMER INSIGHTS
    ----------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('--- CUSTOMER INSIGHTS --------------------------------------');

    -- New customers (first purchase ever is in this month)
    DBMS_OUTPUT.PUT_LINE('New Customers:');
    FOR r IN (
        SELECT DISTINCT c.name
        FROM CUSTOMERS c
        JOIN ORDERS o ON o.customer_id=c.customer_id
        WHERE EXTRACT(YEAR FROM o.order_date)=p_year
          AND EXTRACT(MONTH FROM o.order_date)=p_month
          AND NOT EXISTS (
            SELECT 1
            FROM ORDERS o2
            WHERE o2.customer_id = c.customer_id
              AND o2.order_date < o.order_date
          )
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  - ' || r.name);
    END LOOP;

     -- Repeat customers
    DBMS_OUTPUT.PUT_LINE('Repeat Customers:');
    FOR r IN (
        SELECT c.name, COUNT(*) AS num_orders
        FROM CUSTOMERS c
        JOIN ORDERS o ON o.customer_id=c.customer_id
        WHERE EXTRACT(YEAR FROM o.order_date)=p_year
          AND EXTRACT(MONTH FROM o.order_date)=p_month
        GROUP BY c.name
        HAVING COUNT(*) > 1
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  - ' || r.name || ' (' || r.num_orders || ' orders)');
    END LOOP;

    -- Top 3 customers
    DBMS_OUTPUT.PUT_LINE('Top 3 Customers by Spending:');
    FOR r IN (
        SELECT c.name,
               SUM(o.total_amount - o.discount_amount) AS spent
        FROM CUSTOMERS c
        JOIN ORDERS o ON o.customer_id=c.customer_id
        WHERE EXTRACT(YEAR FROM o.order_date)=p_year
          AND EXTRACT(MONTH FROM o.order_date)=p_month
        GROUP BY c.name
        ORDER BY spent DESC
        FETCH FIRST 3 ROWS ONLY
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  - ' || r.name || ': ' || r.spent);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');

    ----------------------------------------------------------------------
    -- DATA QUALITY
    ----------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('--- DATA QUALITY CHECK --------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Orders with missing lines or invalid values: ' || v_invalid_orders);

    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('END OF REPORT');
    DBMS_OUTPUT.PUT_LINE('============================================================');

END;
/
