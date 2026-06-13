-- ============================================================
-- COMPLETE RESET FOR SLIDING IMAGES
-- ============================================================
-- Run this SQL EXACTLY as shown in Supabase SQL Editor

-- Step 1: Drop table if it exists
DROP TABLE IF EXISTS sliding_images CASCADE;

-- Step 2: Create the table fresh
CREATE TABLE sliding_images (
    id BIGSERIAL PRIMARY KEY,
    image_url TEXT NOT NULL,
    title TEXT,
    description TEXT,
    link_url TEXT,
    display_order SMALLINT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Step 3: Create indexes
CREATE INDEX idx_sliding_images_display_order ON sliding_images(display_order);
CREATE INDEX idx_sliding_images_is_active ON sliding_images(is_active);
CREATE INDEX idx_sliding_images_created_at ON sliding_images(created_at);

-- Step 4: DISABLE ROW LEVEL SECURITY (no policies needed)
ALTER TABLE sliding_images DISABLE ROW LEVEL SECURITY;

-- Step 5: Insert sample data
INSERT INTO sliding_images (image_url, title, description, display_order, is_active) 
VALUES 
    ('https://via.placeholder.com/1920x350?text=Slide+1', 'Discover Premium Fabrics', 'Explore our exclusive collection', 1, true),
    ('https://via.placeholder.com/1920x350?text=Slide+2', 'Latest Collections', 'Browse our new arrivals', 2, true)
ON CONFLICT DO NOTHING;

-- Done! Table is created and RLS is disabled
-- You can now upload images without errors
