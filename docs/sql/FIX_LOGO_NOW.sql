-- ============================================================
-- LOGO FIX: Check and update company_profile logo_url
-- Run this in Supabase SQL Editor if logo isn't changing
-- ============================================================

-- 1. Check current value in database
SELECT 
    setting_key,
    setting_value->>'logo_url' as logo_url,
    setting_value->>'company_name' as company_name,
    updated_at
FROM admin_settings
WHERE setting_key = 'company_profile';

-- 2. If logo_url is 'uploads/logo.png' or null, update it manually:
-- (Replace 'YOUR_LOGO_URL_HERE' with your actual logo image URL)
-- UPDATE admin_settings
-- SET setting_value = jsonb_set(
--     setting_value::jsonb,
--     '{logo_url}',
--     '"YOUR_LOGO_URL_HERE"'::jsonb
-- ),
-- updated_at = NOW()
-- WHERE setting_key = 'company_profile';

-- 3. Create logo storage bucket (for file uploads)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'logo',
    'logo', 
    true,
    5242880,
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml']
)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 4. Set RLS to allow public read and anonymous upload for logo bucket
-- (This allows the admin panel to upload logos without being signed in)
DO $$
BEGIN
    -- Public read policy
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' AND schemaname = 'storage' 
        AND policyname = 'Public read access for logo'
    ) THEN
        EXECUTE 'CREATE POLICY "Public read access for logo" ON storage.objects FOR SELECT USING (bucket_id = ''logo'')';
    END IF;
    
    -- Allow upload
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' AND schemaname = 'storage' 
        AND policyname = 'Allow upload to logo bucket'
    ) THEN
        EXECUTE 'CREATE POLICY "Allow upload to logo bucket" ON storage.objects FOR INSERT WITH CHECK (bucket_id = ''logo'')';
    END IF;
    
    -- Allow update
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' AND schemaname = 'storage' 
        AND policyname = 'Allow update in logo bucket'
    ) THEN
        EXECUTE 'CREATE POLICY "Allow update in logo bucket" ON storage.objects FOR UPDATE USING (bucket_id = ''logo'')';
    END IF;
END $$;

-- 5. Also allow public access for product-images bucket (fallback for logo uploads)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' AND schemaname = 'storage' 
        AND policyname = 'Public read product-images'
    ) THEN
        EXECUTE 'CREATE POLICY "Public read product-images" ON storage.objects FOR SELECT USING (bucket_id = ''product-images'')';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' AND schemaname = 'storage' 
        AND policyname = 'Allow upload product-images'
    ) THEN
        EXECUTE 'CREATE POLICY "Allow upload product-images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = ''product-images'')';
    END IF;
END $$;

-- ============================================================
-- VERIFY EVERYTHING
-- ============================================================
SELECT id, name, public FROM storage.buckets WHERE id IN ('logo', 'product-images', 'gallery-images');
