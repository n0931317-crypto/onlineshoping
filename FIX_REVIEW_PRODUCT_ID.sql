-- Make product_id nullable in reviews table to allow general reviews
-- Run this in Supabase SQL Editor

-- Alter the column to allow NULL values
ALTER TABLE reviews
ALTER COLUMN product_id DROP NOT NULL;

-- Verify the change
-- SELECT column_name, is_nullable, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'reviews' AND column_name = 'product_id';
