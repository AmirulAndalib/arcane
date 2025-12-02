-- Add tags column to environments table for categorization
ALTER TABLE environments ADD COLUMN IF NOT EXISTS tags JSONB DEFAULT '[]';

-- Create index for efficient tag-based filtering
CREATE INDEX IF NOT EXISTS idx_environments_tags ON environments USING GIN (tags);

-- Create saved environment filters table
CREATE TABLE IF NOT EXISTS environment_filters (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    selected_tags JSONB DEFAULT '[]',
    excluded_tags JSONB DEFAULT '[]',
    tag_mode TEXT DEFAULT 'any' CHECK (tag_mode IN ('any', 'all')),
    status_filter TEXT DEFAULT 'all' CHECK (status_filter IN ('all', 'online', 'offline')),
    group_by TEXT DEFAULT 'none' CHECK (group_by IN ('none', 'status', 'tags')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Create index for efficient user-based queries
CREATE INDEX IF NOT EXISTS idx_environment_filters_user_id ON environment_filters(user_id);

-- Ensure only one default filter per user
CREATE UNIQUE INDEX IF NOT EXISTS idx_environment_filters_user_default 
ON environment_filters(user_id) WHERE is_default = TRUE;

