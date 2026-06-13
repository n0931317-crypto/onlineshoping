-- ============================================================
-- FIX LOGO UPLOAD: Create 'logo' storage bucket
-- Run this in Supabase SQL Editor to fix logo upload issues
-- ============================================================

-- Option 1: Create logo bucket via SQL (if your Supabase version supports it)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'logo',
    'logo', 
    true,
    5242880, -- 5MB limit
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml']
)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Also ensure product-images bucket exists (main fallback bucket)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'product-images',
    'product-images',
    true,
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- RLS Policies for 'logo' bucket
-- Allow anyone to read
CREATE POLICY "Public read access for logo" ON storage.objects
    FOR SELECT USING (bucket_id = 'logo');

-- Allow anyone to upload (for admin use - you can restrict this to authenticated users)
CREATE POLICY "Allow upload to logo bucket" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'logo');

-- Allow update
CREATE POLICY "Allow update in logo bucket" ON storage.objects
    FOR UPDATE USING (bucket_id = 'logo');

-- Allow delete
CREATE POLICY "Allow delete from logo bucket" ON storage.objects
    FOR DELETE USING (bucket_id = 'logo');

-- ============================================================
-- VERIFY: Check what's in admin_settings for company_profile
-- ============================================================
SELECT 
    setting_key,
    setting_value,
    updated_at
FROM admin_settings
WHERE setting_key = 'company_profile'
ORDER BY updated_at DESC
LIMIT 5;
