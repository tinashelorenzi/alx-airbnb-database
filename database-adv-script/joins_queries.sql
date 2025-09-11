-- =====================================================
-- ADVANCED SQL QUERIES - JOIN OPERATIONS
-- =====================================================

-- 1. INNER JOIN: Get all bookings with their corresponding user information
--    This query returns only bookings that have an associated user
--    Purpose: Display booking details along with customer information
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    u.first_name,
    u.last_name,
    u.email
FROM bookings b
INNER JOIN users u 
    ON b.user_id = u.user_id
ORDER BY b.start_date DESC;

-- 2. LEFT JOIN: Get all properties and their reviews (if any)
--    This query returns all properties, even those without reviews
--    Purpose: Show property listings with review information when available
SELECT 
    p.property_id,
    p.name,
    p.description,
    r.review_id,
    r.rating,
    r.comment
FROM properties p
LEFT JOIN reviews r 
    ON p.property_id = r.property_id
ORDER BY p.name, r.rating DESC;

-- 3. FULL OUTER JOIN: Get all users and all bookings
--    Note: MySQL doesn't support FULL OUTER JOIN directly
--    This emulates it using UNION of LEFT and RIGHT joins
--    Purpose: Show complete relationship between users and bookings
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.end_date
FROM users u
LEFT JOIN bookings b 
    ON u.user_id = b.user_id

UNION

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.end_date
FROM users u
RIGHT JOIN bookings b 
    ON u.user_id = b.user_id
WHERE u.user_id IS NULL

ORDER BY user_id, start_date;