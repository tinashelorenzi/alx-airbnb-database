-- =====================================================
-- ADVANCED SQL QUERIES - SUBQUERIES
-- =====================================================

-- 1. CORRELATED SUBQUERY: Find high-rated properties (average rating > 4.0)
--    This query uses a correlated subquery that references the outer query
--    Purpose: Display properties with excellent ratings and show their average rating
--    Note: The subquery is executed once for each row in the outer query
SELECT 
    p.property_id, 
    p.name, 
    p.description,
    (SELECT AVG(rating) 
     FROM reviews r 
     WHERE r.property_id = p.property_id) AS avg_rating
FROM properties p
WHERE (SELECT AVG(rating) 
       FROM reviews r 
       WHERE r.property_id = p.property_id) > 4.0
ORDER BY avg_rating DESC, p.name;

-- 2. CORRELATED SUBQUERY: Find frequent users (more than 3 bookings)
--    This query identifies users who have made multiple bookings
--    Purpose: Identify loyal customers and show their booking count
--    Note: The subquery references the outer query's user_id
SELECT 
    u.user_id, 
    u.first_name, 
    u.last_name,
    (SELECT COUNT(*) 
     FROM bookings b 
     WHERE b.user_id = u.user_id) AS booking_count
FROM users u
WHERE (SELECT COUNT(*) 
       FROM bookings b 
       WHERE b.user_id = u.user_id) > 3
ORDER BY booking_count DESC, u.last_name, u.first_name;