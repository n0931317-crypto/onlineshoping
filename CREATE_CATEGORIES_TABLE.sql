-- ============================================================
-- CREATE CATEGORIES TABLE
-- ============================================================
-- This SQL script creates the categories table if it doesn't exist
-- Categories are displayed on the home page and can be managed by admin

CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_categories_created_at ON categories(created_at);
CREATE INDEX IF NOT EXISTS idx_categories_is_active ON categories(is_active);
CREATE INDEX IF NOT EXISTS idx_categories_name ON categories(name);

-- Enable Row Level Security
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Allow public read access to active categories
DROP POLICY IF EXISTS "Allow public read active categories" ON categories;
CREATE POLICY "Allow public read active categories"
    ON categories FOR SELECT
    USING (is_active = true);

-- Allow admin to perform all operations
DROP POLICY IF EXISTS "Allow admin full access to categories" ON categories;
CREATE POLICY "Allow admin full access to categories"
    ON categories FOR ALL
    USING (true)
    WITH CHECK (true);

-- Insert sample categories (optional)
INSERT INTO categories (name, description, image_url, is_active) 
VALUES 
    ('Sarees', 'Traditional and modern sarees for every occasion', 'https://via.placeholder.com/400x300?text=Sarees', true),
    ('Suits', 'Elegant suits and dress materials', 'https://via.placeholder.com/400x300?text=Suits', true),
    ('Fabrics', 'Premium quality fabrics for tailoring', 'https://via.placeholder.com/400x300?text=Fabrics', true),
    ('Accessories', 'Jewelry, scarves, and fashion accessories', 'https://via.placeholder.com/400x300?text=Accessories', true)
ON CONFLICT (name) DO NOTHING;
