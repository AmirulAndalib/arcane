-- Drop the tags index
DROP INDEX IF EXISTS idx_environments_tags;

-- Remove tags column from environments table
ALTER TABLE environments DROP COLUMN IF EXISTS tags;

-- Drop environment filters table and indexes
DROP INDEX IF EXISTS idx_environment_filters_user_default;
DROP INDEX IF EXISTS idx_environment_filters_user_id;
DROP TABLE IF EXISTS environment_filters;

