-- Add tags column to environments table for categorization
ALTER TABLE environments ADD COLUMN tags TEXT DEFAULT '[]';

