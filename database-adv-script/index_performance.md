# Index Performance

## Query

```sql
-- Before Indexing
EXPLAIN ANALYZE
SELECT * FROM users
WHERE email = 'peter.ndlovu@example.com';

-- Create Index
CREATE INDEX idx_users_email ON users(email);

-- After Indexing
EXPLAIN ANALYZE
SELECT * FROM users
WHERE email = 'peter.ndlovu@example.com';
```