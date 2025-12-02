-- Drop the tags index
DROP INDEX IF EXISTS idx_environments_tags;

-- Remove tags column from environments table
ALTER TABLE environments DROP COLUMN IF EXISTS tags;

