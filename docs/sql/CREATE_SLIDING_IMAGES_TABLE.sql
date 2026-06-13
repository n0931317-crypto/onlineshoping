-- ============================================================
-- SLIDING IMAGES (HERO SLIDER) TABLE
-- ============================================================
-- This table stores the hero slider images displayed on home page

CREATE TABLE IF NOT EXISTS sliding_images (
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_sliding_images_display_order ON sliding_images(display_order);
CREATE INDEX IF NOT EXISTS idx_sliding_images_is_active ON sliding_images(is_active);
CREATE INDEX IF NOT EXISTS idx_sliding_images_created_at ON sliding_images(created_at);

-- Enable Row Level Security
ALTER TABLE sliding_images ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies first
DROP POLICY IF EXISTS "Allow public read active sliding images" ON sliding_images;
DROP POLICY IF EXISTS "Allow admin full access to sliding images" ON sliding_images;
DROP POLICY IF EXISTS "Allow all insert" ON sliding_images;
DROP POLICY IF EXISTS "Allow all update" ON sliding_images;
DROP POLICY IF EXISTS "Allow all delete" ON sliding_images;
DROP POLICY IF EXISTS "sliding_images_select_policy" ON sliding_images;
DROP POLICY IF EXISTS "sliding_images_insert_policy" ON sliding_images;
DROP POLICY IF EXISTS "sliding_images_update_policy" ON sliding_images;
DROP POLICY IF EXISTS "sliding_images_delete_policy" ON sliding_images;

-- Create completely permissive policies for admin use
CREATE POLICY "Enable all select access"
    ON sliding_images FOR SELECT
    USING (true);

CREATE POLICY "Enable all insert access"
    ON sliding_images FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Enable all update access"
    ON sliding_images FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Enable all delete access"
    ON sliding_images FOR DELETE
    USING (true);

-- Insert sample sliding images (optional)
INSERT INTO sliding_images (image_url, title, description, display_order, is_active) 
VALUES 
    ('https://via.placeholder.com/1920x350?text=Slide+1', 'Discover Premium Fabrics', 'Explore our exclusive collection of traditional and modern styles', 1, true),
    ('https://via.placeholder.com/1920x350?text=Slide+2', 'Latest Collections', 'Browse our new arrivals and trending items', 2, true),
    ('https://via.placeholder.com/1920x350?text=Slide+3', 'Fashion Forward', 'Stay stylish with our premium selection', 3, true),
    ('https://via.placeholder.com/1920x350?text=Slide+4', 'Special Offers', 'Check out our exclusive deals and discounts', 4, true)
ON CONFLICT DO NOTHING;
