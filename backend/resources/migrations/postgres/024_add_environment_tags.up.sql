-- Add tags column to environments table for categorization
ALTER TABLE environments ADD COLUMN IF NOT EXISTS tags JSONB DEFAULT '[]';

-- Create index for efficient tag-based filtering
CREATE INDEX IF NOT EXISTS idx_environments_tags ON environments USING GIN (tags);

