# AirBnB Database Normalization Project

This repository contains the normalized database schema for an AirBnB-like booking platform, achieving **Third Normal Form (3NF)** to ensure data integrity, eliminate redundancy, and optimize performance.

## Repository Structure

```
alx-airbnb-database/
├── normalization.md          # Detailed normalization analysis and explanation
├── schema_normalized.sql     # Complete normalized database schema (3NF)
├── migration_script.sql      # Migration script from old to new schema
└── README.md                 # This file
```

## Project Objectives

1. **Analyze** the existing AirBnB database schema for normalization issues
2. **Identify** violations of First, Second, and Third Normal Forms
3. **Redesign** the schema to achieve 3NF
4. **Document** all normalization steps and rationale
5. **Provide** migration scripts for implementation

## Schema Overview

### Core Entities

1. **User** - System users (guests, hosts, admins)
2. **Location** NEW - Normalized location data
3. **Property** - Rental listings with location references
4. **Booking** - Reservation records
5. **Payment** - Transaction records
6. **Review** - Property reviews and ratings
7. **Message** - User communications

## Normalization Issues Identified

### Issue 1: Location Redundancy
**Original Design:**
```sql
Property (
    property_id,
    location VARCHAR  -- "123 Main St, New York, NY, USA"
)
```

**Problems:**
- Multi-valued attribute in single field
- Data duplication across properties
- Inefficient querying by city/country
- Update anomalies

**Solution:**
```sql
Location (
    location_id PK,
    street_address,
    city,
    state_province,
    postal_code,
    country
)

Property (
    property_id PK,
    location_id FK → Location
)
```

### Issue 2: Calculated Total Price
**Original Design:**
```sql
Booking (
    total_price  -- Derived from: nights × pricepernight
)
```

**Analysis:**
- Violates 3NF (transitive dependency)
- Can be calculated from other fields
- Creates update anomalies

**Solution:**
- Keep as **historical snapshot** (business requirement)
- Document as price captured at booking time
- Property prices may change after booking

## Quick Start

### Prerequisites
- MySQL 8.0+ or PostgreSQL 12+
- Database administration access
- Basic SQL knowledge

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/alx-airbnb-database.git
cd alx-airbnb-database
```

2. **Review normalization analysis:**
```bash
cat normalization.md
```

3. **Create the normalized database:**
```bash
mysql -u username -p < schema_normalized.sql
```

4. **Or migrate existing data:**
```bash
mysql -u username -p < migration_script.sql
```

## Documentation

### normalization.md

Comprehensive documentation covering:
- Normal form definitions (1NF, 2NF, 3NF)
- Detailed analysis of each table
- Identified violations and solutions
- Step-by-step normalization process
- Database views for calculated values
- Trade-offs and best practices

### Key Sections:
1. Understanding Normal Forms
2. Initial Schema Analysis
3. Normalization Issues Identified
4. Normalized Schema Design
5. Normalization Steps Summary
6. Database Views for Calculated Values
7. Benefits and Trade-offs

## Database Schema

### Tables

#### Location (New)
```sql
Location (
    location_id CHAR(36) PK,
    street_address VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8)
)
```

#### Property (Updated)
```sql
Property (
    property_id CHAR(36) PK,
    host_id CHAR(36) FK → User,
    location_id CHAR(36) FK → Location,  Updated
    name VARCHAR(255),
    description TEXT,
    pricepernight DECIMAL(10,2)
)
```

#### Other Tables
- **User** - No changes
- **Booking** - total_price documented as snapshot
- **Payment** - No changes
- **Review** - No changes
- **Message** - No changes

### Views

**vw_property_full** - Property with complete location details
```sql
SELECT property_id, name, full_address, city, country, ...
FROM vw_property_full;
```

**vw_booking_details** - Booking with calculated totals
```sql
SELECT booking_id, nights, booked_total, current_calculated_total, ...
FROM vw_booking_details;
```

**vw_property_ratings** - Property with average ratings
```sql
SELECT property_id, name, average_rating, total_reviews, ...
FROM vw_property_ratings;
```

## Migration Guide

### Step 1: Backup Existing Data
```bash
mysqldump -u username -p database_name > backup_$(date +%Y%m%d).sql
```

### Step 2: Run Migration Script
```bash
mysql -u username -p database_name < migration_script.sql
```

### Step 3: Verify Migration
```sql
-- Check record counts
SELECT 'Properties' AS table_name, COUNT(*) FROM Property
UNION ALL
SELECT 'Locations', COUNT(*) FROM Location;

-- Check for orphaned records
SELECT COUNT(*) FROM Property p
LEFT JOIN Location l ON p.location_id = l.location_id
WHERE l.location_id IS NULL;
```

### Step 4: Update Application Code
Update queries to use new schema:
```python
# OLD: Direct location field
property = db.query("SELECT location FROM Property WHERE id = ?")

# NEW: Join with Location table
property = db.query("""
    SELECT p.*, l.city, l.country 
    FROM Property p 
    JOIN Location l ON p.location_id = l.location_id 
    WHERE p.property_id = ?
""")

# OR: Use view
property = db.query("SELECT * FROM vw_property_full WHERE property_id = ?")
```

## Benefits

### Data Integrity
- Eliminates update anomalies
- Ensures referential integrity
- Prevents orphaned data
- Maintains consistency

### Performance
- Efficient indexing on location attributes
- Optimized queries by city/country
- Reduced storage requirements
- Better join performance

### Maintainability
- Single source of truth for locations
- Easier to update city/country data
- Clearer data relationships
- Simplified schema understanding

### Scalability
- Supports location hierarchies (future)
- Easy to add new location attributes
- Better suited for large datasets
- Enables location-based features

## Learning Resources

### Normal Forms
- [Database Normalization Explained](https://www.essentialsql.com/get-ready-to-learn-sql-database-normalization-explained-in-simple-english/)
- [MySQL Normalization Guide](https://dev.mysql.com/doc/refman/8.0/en/normalization.html)

### Best Practices
- [SQL Antipatterns](https://pragprog.com/titles/bksqla/sql-antipatterns/)
- [Database Design Guidelines](https://www.vertabelo.com/blog/database-design-best-practices/)

## Testing

### Test Data Insertion
```sql
-- Insert test location
INSERT INTO Location (street_address, city, country)
VALUES ('123 Test St', 'New York', 'USA');

-- Insert test property
INSERT INTO Property (host_id, location_id, name, pricepernight)
SELECT 
    (SELECT user_id FROM User WHERE role = 'host' LIMIT 1),
    location_id,
    'Test Property',
    100.00
FROM Location WHERE city = 'New York' LIMIT 1;
```

### Validation Queries
```sql
-- Check location distribution
SELECT city, country, COUNT(*) as properties
FROM Location l
JOIN Property p ON l.location_id = p.location_id
GROUP BY city, country;

-- Verify no duplicate locations
SELECT street_address, city, country, COUNT(*)
FROM Location
GROUP BY street_address, city, country
HAVING COUNT(*) > 1;
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add improvement'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Authors

- **Database Architecture Team** - Initial work and normalization analysis

## Acknowledgments

- Database normalization theory by E.F. Codd
- SQL best practices from the developer community
- AirBnB for inspiration on booking platform design

## Support

For questions or issues:
1. Check the [normalization.md](normalization.md) documentation
2. Review SQL comments in schema files
3. Open an issue in the repository
4. Contact the database architecture team

---

**Version:** 1.0  
**Last Updated:** December 2025  
**Status:** Production Ready