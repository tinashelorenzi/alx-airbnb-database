-- =====================================================
-- ADVANCED SQL QUERIES - AGGREGATIONS & WINDOW FUNCTIONS
-- =====================================================

-- 1. AGGREGATION: Count total bookings per user
--    This query uses GROUP BY with COUNT() to aggregate booking data
--    Purpose: Show how many bookings each user has made (including users with 0 bookings)
--    Note: LEFT JOIN ensures all users are included, even those without bookings
SELECT 
    u.user_id, 
    u.first_name, 
    u.last_name, 
    COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN bookings b 
    ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY total_bookings DESC, u.last_name, u.first_name;

-- 2. WINDOW FUNCTIONS: Rank properties by booking popularity
--    This query uses Common Table Expression (CTE) and window functions
--    Purpose: Create a ranking system for properties based on booking frequency
--    Note: ROW_NUMBER() gives unique sequential numbers, RANK() handles ties
WITH property_bookings AS (
    SELECT 
        p.property_id, 
        p.name, 
        COUNT(b.booking_id) AS booking_count
    FROM properties p
    LEFT JOIN bookings b 
        ON p.property_id = b.property_id
    GROUP BY p.property_id, p.name
)
SELECT 
    property_id, 
    name, 
    booking_count,
    ROW_NUMBER() OVER (ORDER BY booking_count DESC) AS row_num,
    RANK() OVER (ORDER BY booking_count DESC) AS rank
FROM property_bookings
ORDER BY booking_count DESC, name;