-- =====================================================
-- ADVANCED SQL QUERIES - PERFORMANCE OPTIMIZATION
-- =====================================================

-- 1. BASELINE QUERY: Complex multi-table join without optimization
--    This query demonstrates a typical complex join that may have performance issues
--    Purpose: Retrieve complete booking information with user, property, and payment details
--    Note: This query joins multiple tables without optimization techniques
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    u.first_name AS user_first_name,
    u.last_name AS user_last_name,
    p.name AS property_name,
    p.description AS property_description,
    pay.amount AS payment_amount,
    pay.payment_method
FROM bookings b
JOIN users u 
    ON b.user_id = u.user_id
JOIN properties p 
    ON b.property_id = p.property_id
LEFT JOIN payments pay 
    ON b.booking_id = pay.booking_id
ORDER BY b.start_date DESC;

-- 2. OPTIMIZED QUERY: Using CTE for better performance and readability
--    This query uses a Common Table Expression (CTE) to break down the complex join
--    Purpose: Same result as above but with improved performance and maintainability
--    Benefits: CTE makes the query more readable and can improve execution plan
WITH BookingDetails AS (
    SELECT 
        b.booking_id,
        b.user_id,
        b.property_id,
        b.start_date,
        b.end_date,
        b.total_price
    FROM bookings b
)
SELECT 
    bd.booking_id,
    bd.start_date,
    bd.end_date,
    bd.total_price,
    u.first_name AS user_first_name,
    u.last_name AS user_last_name,
    p.name AS property_name,
    p.description AS property_description,
    pay.amount AS payment_amount,
    pay.payment_method
FROM BookingDetails bd
JOIN users u 
    ON bd.user_id = u.user_id
JOIN properties p 
    ON bd.property_id = p.property_id
LEFT JOIN payments pay 
    ON bd.booking_id = pay.booking_id
ORDER BY bd.start_date DESC;

-- 3. PERFORMANCE ANALYSIS: Query execution plan analysis
--    Use EXPLAIN ANALYZE to compare query performance between the two approaches
--    Purpose: Measure and compare execution time, cost, and resource usage
--    Note: Run this before and after creating indexes for comparison
EXPLAIN ANALYZE 
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    u.first_name,
    u.last_name,
    p.name,
    pay.amount
FROM bookings b
JOIN users u ON b.user_id = u.user_id
JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON b.booking_id = pay.booking_id
WHERE b.start_date >= '2024-01-01';