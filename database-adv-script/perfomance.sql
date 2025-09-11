-- =====================================================
-- ADVANCED SQL QUERIES - PERFORMANCE OPTIMIZATION
-- =====================================================

-- 1. INITIAL COMPLEX QUERY: Retrieves all bookings with user, property, and payment details
--    This query demonstrates a complex multi-table join with multiple WHERE conditions
--    Purpose: Retrieve complete booking information with filtering conditions
--    Note: This query may have performance issues due to complex joins and WHERE clauses
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    u.first_name AS user_first_name,
    u.last_name AS user_last_name,
    u.email AS user_email,
    p.name AS property_name,
    p.description AS property_description,
    p.price_per_night,
    pay.amount AS payment_amount,
    pay.payment_method,
    pay.payment_status
FROM bookings b
JOIN users u 
    ON b.user_id = u.user_id
JOIN properties p 
    ON b.property_id = p.property_id
LEFT JOIN payments pay 
    ON b.booking_id = pay.booking_id
WHERE b.start_date >= '2024-01-01' 
    AND b.end_date <= '2024-12-31'
    AND p.price_per_night > 100
    AND u.email IS NOT NULL
ORDER BY b.start_date DESC;

-- 2. OPTIMIZED QUERY: Refactored for better performance
--    This query uses CTE and applies filtering earlier to reduce data processing
--    Purpose: Same result as above but with improved performance through optimization
--    Benefits: Early filtering reduces join operations and improves execution time
WITH FilteredBookings AS (
    SELECT 
        b.booking_id,
        b.user_id,
        b.property_id,
        b.start_date,
        b.end_date,
        b.total_price
    FROM bookings b
    WHERE b.start_date >= '2024-01-01' 
        AND b.end_date <= '2024-12-31'
),
FilteredProperties AS (
    SELECT 
        p.property_id,
        p.name,
        p.description,
        p.price_per_night
    FROM properties p
    WHERE p.price_per_night > 100
)
SELECT 
    fb.booking_id,
    fb.start_date,
    fb.end_date,
    fb.total_price,
    u.first_name AS user_first_name,
    u.last_name AS user_last_name,
    u.email AS user_email,
    fp.name AS property_name,
    fp.description AS property_description,
    fp.price_per_night,
    pay.amount AS payment_amount,
    pay.payment_method,
    pay.payment_status
FROM FilteredBookings fb
JOIN users u 
    ON fb.user_id = u.user_id
    AND u.email IS NOT NULL
JOIN FilteredProperties fp 
    ON fb.property_id = fp.property_id
LEFT JOIN payments pay 
    ON fb.booking_id = pay.booking_id
ORDER BY fb.start_date DESC;

-- 3. PERFORMANCE ANALYSIS: Query execution plan analysis
--    Use EXPLAIN ANALYZE to compare query performance between the two approaches
--    Purpose: Measure and compare execution time, cost, and resource usage
--    Note: Run this before and after creating indexes for comparison

-- Analyze the initial complex query performance
EXPLAIN ANALYZE 
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    u.first_name AS user_first_name,
    u.last_name AS user_last_name,
    u.email AS user_email,
    p.name AS property_name,
    p.description AS property_description,
    p.price_per_night,
    pay.amount AS payment_amount,
    pay.payment_method,
    pay.payment_status
FROM bookings b
JOIN users u 
    ON b.user_id = u.user_id
JOIN properties p 
    ON b.property_id = p.property_id
LEFT JOIN payments pay 
    ON b.booking_id = pay.booking_id
WHERE b.start_date >= '2024-01-01' 
    AND b.end_date <= '2024-12-31'
    AND p.price_per_night > 100
    AND u.email IS NOT NULL;

-- Analyze the optimized query performance
EXPLAIN ANALYZE
WITH FilteredBookings AS (
    SELECT 
        b.booking_id,
        b.user_id,
        b.property_id,
        b.start_date,
        b.end_date,
        b.total_price
    FROM bookings b
    WHERE b.start_date >= '2024-01-01' 
        AND b.end_date <= '2024-12-31'
),
FilteredProperties AS (
    SELECT 
        p.property_id,
        p.name,
        p.description,
        p.price_per_night
    FROM properties p
    WHERE p.price_per_night > 100
)
SELECT 
    fb.booking_id,
    fb.start_date,
    fb.end_date,
    fb.total_price,
    u.first_name AS user_first_name,
    u.last_name AS user_last_name,
    u.email AS user_email,
    fp.name AS property_name,
    fp.description AS property_description,
    fp.price_per_night,
    pay.amount AS payment_amount,
    pay.payment_method,
    pay.payment_status
FROM FilteredBookings fb
JOIN users u 
    ON fb.user_id = u.user_id
    AND u.email IS NOT NULL
JOIN FilteredProperties fp 
    ON fb.property_id = fp.property_id
LEFT JOIN payments pay 
    ON fb.booking_id = pay.booking_id;