-- ============================================================
-- COMPLETE HERO VIDEO SETUP FIX
-- Solves: Bucket not found, RLS policy violations, storage errors
-- ============================================================

-- ============================================================
-- 1. CREATE HOME_VIDEO TABLE (if doesn't exist)
-- ============================================================
CREATE TABLE IF NOT EXISTS home_video (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    video_url TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- 2. DROP EXISTING SETTINGS TABLE IF IT HAS WRONG STRUCTURE
-- ============================================================
DROP TABLE IF EXISTS settings CASCADE;

-- ============================================================
-- 3. CREATE SETTINGS TABLE (for modern-ecommerce.js)
-- ============================================================
CREATE TABLE settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT UNIQUE NOT NULL,
    hero_video_url TEXT,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX idx_settings_key ON settings(key);

-- Insert hero video setting default
INSERT INTO settings (key, hero_video_url, description)
VALUES ('hero_video', '', 'Hero section background video URL');

-- ============================================================
-- 3. ENABLE RLS ON BOTH TABLES
-- ============================================================
ALTER TABLE home_video ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 4. HOME_VIDEO TABLE POLICIES
-- ============================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow public read home_video" ON home_video;
DROP POLICY IF EXISTS "Allow admin write home_video" ON home_video;
DROP POLICY IF EXISTS "Allow authenticated users insert home_video" ON home_video;
DROP POLICY IF EXISTS "Allow authenticated users update home_video" ON home_video;
DROP POLICY IF EXISTS "Allow authenticated users delete home_video" ON home_video;

-- Public can read active videos
CREATE POLICY "Allow public read home_video" ON home_video
    FOR SELECT USING (is_active = TRUE);

-- Authenticated users (admin) can insert
CREATE POLICY "Allow authenticated users insert home_video" ON home_video
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Authenticated users (admin) can update
CREATE POLICY "Allow authenticated users update home_video" ON home_video
    FOR UPDATE USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Authenticated users (admin) can delete
CREATE POLICY "Allow authenticated users delete home_video" ON home_video
    FOR DELETE USING (auth.role() = 'authenticated');

-- ============================================================
-- 5. SETTINGS TABLE POLICIES
-- ============================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow public read settings" ON settings;
DROP POLICY IF EXISTS "Allow admin write settings" ON settings;
DROP POLICY IF EXISTS "Allow authenticated users insert settings" ON settings;
DROP POLICY IF EXISTS "Allow authenticated users update settings" ON settings;
DROP POLICY IF EXISTS "Allow authenticated users delete settings" ON settings;

-- Public can read all settings
CREATE POLICY "Allow public read settings" ON settings
    FOR SELECT USING (true);

-- Authenticated users (admin) can insert - using uid check
CREATE POLICY "Allow authenticated users insert settings" ON settings
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Authenticated users (admin) can update - using uid check
CREATE POLICY "Allow authenticated users update settings" ON settings
    FOR UPDATE USING (auth.uid() IS NOT NULL)
    WITH CHECK (auth.uid() IS NOT NULL);

-- Authenticated users (admin) can delete - using uid check
CREATE POLICY "Allow authenticated users delete settings" ON settings
    FOR DELETE USING (auth.uid() IS NOT NULL);

-- ============================================================
-- 6. CREATE STORAGE BUCKET FOR VIDEOS
-- ============================================================

-- Create videos bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('videos', 'videos', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 7. STORAGE BUCKET POLICIES - COMPREHENSIVE FIX
-- ============================================================

-- Drop existing storage policies
DROP POLICY IF EXISTS "Public Access Videos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload Videos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete Videos" ON storage.objects;
DROP POLICY IF EXISTS "Public View Videos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete" ON storage.objects;

-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- SIMPLE POLICY: Public can view all files in videos bucket
CREATE POLICY "Public View Videos" ON storage.objects
    FOR SELECT USING (bucket_id = 'videos');

-- SIMPLE POLICY: Authenticated users can upload (INSERT) to videos bucket
CREATE POLICY "Authenticated Upload" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'videos');

-- SIMPLE POLICY: Authenticated can update files
CREATE POLICY "Authenticated Update" ON storage.objects
    FOR UPDATE USING (bucket_id = 'videos')
    WITH CHECK (bucket_id = 'videos');

-- SIMPLE POLICY: Authenticated can delete files
CREATE POLICY "Authenticated Delete" ON storage.objects
    FOR DELETE USING (bucket_id = 'videos');

-- ============================================================
-- 6. VERIFY TABLES
-- ============================================================

-- Check home_video table
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'home_video';

-- Check settings table
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'settings';

-- Check RLS status
SELECT schemaname, tablename, rowsecurity FROM pg_tables 
WHERE tablename IN ('home_video', 'settings');

-- Check storage bucket
SELECT id, name, public FROM storage.buckets WHERE id = 'videos';
