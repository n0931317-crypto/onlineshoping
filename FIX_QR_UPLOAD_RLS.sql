-- Complete Fix for QR Code Upload - All RLS Policies
-- This script allows ANYONE to upload QR codes without authentication

-- ==========================================
-- 1. PAYMENT_QR_IMAGES TABLE
-- ==========================================

-- Create table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.payment_qr_images (
    id BIGSERIAL PRIMARY KEY,
    payment_method VARCHAR(50) UNIQUE NOT NULL,
    file_path TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS
ALTER TABLE public.payment_qr_images ENABLE ROW LEVEL SECURITY;

-- Drop old policies
DROP POLICY IF EXISTS "Allow public read qr images" ON public.payment_qr_images;
DROP POLICY IF EXISTS "Allow public insert qr images" ON public.payment_qr_images;
DROP POLICY IF EXISTS "Allow public update qr images" ON public.payment_qr_images;
DROP POLICY IF EXISTS "Allow public delete qr images" ON public.payment_qr_images;

-- Create new permissive policies (ALLOW ALL)
CREATE POLICY "Allow all read qr"
ON public.payment_qr_images
FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow all insert qr"
ON public.payment_qr_images
FOR INSERT
TO public
WITH CHECK (true);

CREATE POLICY "Allow all update qr"
ON public.payment_qr_images
FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow all delete qr"
ON public.payment_qr_images
FOR DELETE
TO public
USING (true);

-- ==========================================
-- 2. ADMIN_SETTINGS TABLE
-- ==========================================

-- Create table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.admin_settings (
    id BIGSERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS
ALTER TABLE public.admin_settings ENABLE ROW LEVEL SECURITY;

-- Drop old policies
DROP POLICY IF EXISTS "Allow public read settings" ON public.admin_settings;
DROP POLICY IF EXISTS "Allow public insert settings" ON public.admin_settings;
DROP POLICY IF EXISTS "Allow public update settings" ON public.admin_settings;
DROP POLICY IF EXISTS "Allow public delete settings" ON public.admin_settings;

-- Create new permissive policies (ALLOW ALL)
CREATE POLICY "Allow all read settings"
ON public.admin_settings
FOR SELECT
TO public
USING (true);

CREATE POLICY "Allow all insert settings"
ON public.admin_settings
FOR INSERT
TO public
WITH CHECK (true);

CREATE POLICY "Allow all update settings"
ON public.admin_settings
FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow all delete settings"
ON public.admin_settings
FOR DELETE
TO public
USING (true);

-- ==========================================
-- 3. STORAGE BUCKET POLICIES
-- ==========================================
-- NOTE: Storage bucket RLS is managed differently in Supabase
-- You must configure these in the Supabase Dashboard:
-- 1. Go to Storage → payment-qr-images
-- 2. Click "Policies" tab
-- 3. Add these policies via SQL

-- For Storage Bucket - Run this separately in Storage SQL Editor:
/*
CREATE POLICY "Allow public upload to payment-qr-images"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (
  bucket_id = 'payment-qr-images'
);

CREATE POLICY "Allow public read from payment-qr-images"
ON storage.objects
FOR SELECT
TO public
USING (
  bucket_id = 'payment-qr-images'
);

CREATE POLICY "Allow public delete from payment-qr-images"
ON storage.objects
FOR DELETE
TO public
USING (
  bucket_id = 'payment-qr-images'
);

CREATE POLICY "Allow public update payment-qr-images"
ON storage.objects
FOR UPDATE
TO public
USING (
  bucket_id = 'payment-qr-images'
)
WITH CHECK (
  bucket_id = 'payment-qr-images'
);
*/

-- ==========================================
-- 4. VERIFICATION QUERIES
-- ==========================================

-- Verify payment_qr_images table exists and has data
-- SELECT * FROM public.payment_qr_images;

-- Verify admin_settings table exists
-- SELECT * FROM public.admin_settings;

-- Check RLS is enabled
-- SELECT schemaname, tablename, rowsecurity FROM pg_tables 
-- WHERE tablename IN ('payment_qr_images', 'admin_settings');

-- ==========================================
-- SUMMARY
-- ==========================================
-- This script allows ANYONE to:
-- ✅ READ QR codes
-- ✅ INSERT (upload) QR codes
-- ✅ UPDATE QR codes
-- ✅ DELETE QR codes
-- ✅ No authentication required
-- ✅ No login needed
-- ==========================================
