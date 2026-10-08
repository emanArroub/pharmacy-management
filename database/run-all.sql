-- Run from psql:
-- psql "$DATABASE_URL" -f database/run-all.sql

BEGIN;

DROP FUNCTION IF EXISTS get_available_stock(INTEGER);
DROP FUNCTION IF EXISTS dispense_prescription(INTEGER);

DROP TABLE IF EXISTS prescription_items CASCADE;
DROP TABLE IF EXISTS prescriptions CASCADE;
DROP TABLE IF EXISTS Batches CASCADE;
DROP TABLE IF EXISTS medicines CASCADE;
DROP TABLE IF EXISTS patients CASCADE;
DROP TABLE IF EXISTS users CASCADE;

\ir schema.sql
\ir functions.sql
\ir test-data.sql

COMMIT;


