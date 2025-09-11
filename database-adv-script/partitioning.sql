-- =====================================================
-- ADVANCED SQL QUERIES - TABLE PARTITIONING
-- =====================================================

-- 1. TABLE SETUP: Drop existing table to create partitioned version
--    This ensures we start with a clean slate for the partitioning demonstration
--    Purpose: Remove any existing bookings table before creating the partitioned version
--    Note: In production, you would migrate data instead of dropping
DROP TABLE IF EXISTS bookings;

-- 2. CREATE PARTITIONED TABLE: Range partitioning by start_date
--    This creates a partitioned table using RANGE partitioning on the start_date column
--    Purpose: Improve query performance for date-based queries and enable partition pruning
--    Note: start_date must be included in PRIMARY KEY for partitioned tables
CREATE TABLE bookings (
    booking_id UUID,
    start_date DATE NOT NULL,
    property_id UUID,
    user_id UUID,
    end_date DATE NOT NULL,
    total_price DECIMAL NOT NULL,
    status booking_status NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (booking_id, start_date)
) PARTITION BY RANGE (start_date);

-- 3. CREATE PARTITIONS: Define yearly partitions for better data management
--    Each partition contains data for a specific year range
--    Purpose: Enable partition pruning and improve maintenance operations
--    Benefits: Faster queries, easier data archiving, and better maintenance
CREATE TABLE bookings_2023 PARTITION OF bookings
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE bookings_2024 PARTITION OF bookings
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE bookings_2025 PARTITION OF bookings
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- 4. ADD CONSTRAINTS: Foreign key constraints after partitioning
--    Foreign keys must be added after creating the partitioned table
--    Purpose: Maintain referential integrity between related tables
--    Note: Constraints are inherited by all partitions automatically
ALTER TABLE bookings 
    ADD CONSTRAINT fk_bookings_property 
    FOREIGN KEY (property_id) 
    REFERENCES properties(property_id);

ALTER TABLE bookings 
    ADD CONSTRAINT fk_bookings_user 
    FOREIGN KEY (user_id) 
    REFERENCES users(user_id);

-- 5. INSERT TEST DATA: Demonstrate automatic partition routing
--    This insert will automatically route to the correct partition based on start_date
--    Purpose: Show how PostgreSQL automatically handles partition routing
--    Note: The system determines the correct partition based on the start_date value
INSERT INTO bookings (
    booking_id, 
    start_date, 
    property_id, 
    user_id, 
    end_date, 
    total_price, 
    status
) VALUES (
    uuid_generate_v4(),
    '2024-07-15',
    (SELECT property_id FROM properties LIMIT 1),
    (SELECT user_id FROM users LIMIT 1),
    '2024-07-20',
    1250.00,
    'confirmed'
);

-- 6. PERFORMANCE TEST: Query with partition pruning
--    This query demonstrates how partition pruning improves performance
--    Purpose: Show that only the relevant partition(s) are scanned
--    Benefits: Faster execution, reduced I/O, and better resource utilization
EXPLAIN ANALYZE
SELECT 
    booking_id,
    start_date,
    end_date,
    total_price,
    status
FROM bookings 
WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31'
ORDER BY start_date;