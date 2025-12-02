-- SQLite doesn't support DROP COLUMN in older versions
-- For SQLite, we need to recreate the table without the tags column
-- This is a simplified down migration that removes the data
-- The column will remain in the schema but data will be cleared

UPDATE environments SET tags = '[]';

-- Drop environment filters table and indexes
DROP INDEX IF EXISTS idx_environment_filters_user_id;
DROP TABLE IF EXISTS environment_filters;

