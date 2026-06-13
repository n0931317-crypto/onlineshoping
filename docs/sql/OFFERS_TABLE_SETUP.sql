-- ============================================================
-- OFFERS TABLE SETUP FOR EXCLUSIVE OFFERS BANNER
-- ============================================================

-- Create offers table
CREATE TABLE IF NOT EXISTS offers (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5, 2) NOT NULL,
    discount_amount DECIMAL(10, 2),
    image_url TEXT,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_offers_is_active ON offers(is_active);
CREATE INDEX IF NOT EXISTS idx_offers_start_date ON offers(start_date);
CREATE INDEX IF NOT EXISTS idx_offers_end_date ON offers(end_date);
CREATE INDEX IF NOT EXISTS idx_offers_created_at ON offers(created_at DESC);

-- Enable Row Level Security
ALTER TABLE offers ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "view_active_offers" ON offers;
DROP POLICY IF EXISTS "view_all_offers" ON offers;
DROP POLICY IF EXISTS "anyone_create_offers" ON offers;
DROP POLICY IF EXISTS "admin_update_offers" ON offers;
DROP POLICY IF EXISTS "admin_delete_offers" ON offers;

-- RLS Policy: Everyone can view all offers
CREATE POLICY "view_all_offers"
ON offers
FOR SELECT
USING (true);

-- RLS Policy: Anyone can insert offers
CREATE POLICY "anyone_create_offers"
ON offers
FOR INSERT
WITH CHECK (true);

-- RLS Policy: Anyone can update offers
CREATE POLICY "anyone_update_offers"
ON offers
FOR UPDATE
USING (true)
WITH CHECK (true);

-- RLS Policy: Anyone can delete offers
CREATE POLICY "anyone_delete_offers"
ON offers
FOR DELETE
USING (true);

-- Insert sample offers
INSERT INTO offers (title, description, discount_percentage, image_url, end_date, is_active, created_by)
VALUES 
  ('Spring Sale', 'Get 20% off on all fabrics', 20.00, 'uploads/offer1.jpg', NOW() + INTERVAL '30 days', true, 'admin'),
  ('New Year Special', '15% discount on selected products', 15.00, 'uploads/offer2.jpg', NOW() + INTERVAL '7 days', true, 'admin');

-- Verify the table has data
SELECT * FROM offers LIMIT 5;
