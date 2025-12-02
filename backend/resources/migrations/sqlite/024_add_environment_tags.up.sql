-- Add tags column to environments table for categorization
ALTER TABLE environments ADD COLUMN tags TEXT DEFAULT '[]';

-- Create saved environment filters table
CREATE TABLE IF NOT EXISTS environment_filters (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    is_default INTEGER DEFAULT 0,
    selected_tags TEXT DEFAULT '[]',
    excluded_tags TEXT DEFAULT '[]',
    tag_mode TEXT DEFAULT 'any',
    status_filter TEXT DEFAULT 'all',
    group_by TEXT DEFAULT 'none',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME
);

-- Create index for efficient user-based queries
CREATE INDEX IF NOT EXISTS idx_environment_filters_user_id ON environment_filters(user_id);

