-- Create payment_qr_images table with proper schema for base64 storage
-- Run this in Supabase SQL Editor if the table doesn't exist

-- 1. Create the table if it doesn't exist
CREATE TABLE IF NOT EXISTS payment_qr_images (
    id BIGSERIAL PRIMARY KEY,
    payment_method VARCHAR(50) NOT NULL UNIQUE,
    file_path TEXT NOT NULL,  -- Stores base64 encoded image
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_payment_qr_method ON payment_qr_images(payment_method);

-- 3. Enable Row Level Security
ALTER TABLE payment_qr_images ENABLE ROW LEVEL SECURITY;

-- 4. Drop existing policies if they exist (optional, for cleanup)
DROP POLICY IF EXISTS "Enable read access for all users" ON payment_qr_images;
DROP POLICY IF EXISTS "Enable insert for all users" ON payment_qr_images;
DROP POLICY IF EXISTS "Enable update for all users" ON payment_qr_images;
DROP POLICY IF EXISTS "Enable delete for all users" ON payment_qr_images;

-- 5. Create permissive READ policy - anyone can see QR codes
CREATE POLICY "Enable read access for all users" 
    ON payment_qr_images 
    FOR SELECT 
    USING (true);

-- 6. Create permissive INSERT policy - anyone can upload QR codes
CREATE POLICY "Enable insert for all users" 
    ON payment_qr_images 
    FOR INSERT 
    WITH CHECK (true);

-- 7. Create permissive UPDATE policy - anyone can update QR codes
CREATE POLICY "Enable update for all users" 
    ON payment_qr_images 
    FOR UPDATE 
    USING (true);

-- 8. Create permissive DELETE policy - anyone can delete QR codes
CREATE POLICY "Enable delete for all users" 
    ON payment_qr_images 
    FOR DELETE 
    USING (true);

-- 9. Verify table structure (run this to check)
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'payment_qr_images';
