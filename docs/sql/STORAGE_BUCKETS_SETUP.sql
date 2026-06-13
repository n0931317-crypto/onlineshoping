-- ============================================================
-- STORAGE BUCKETS SETUP - Detailed Instructions
-- ============================================================
-- Run these commands to set up and manage storage buckets

-- ============================================================
-- 1. LIST EXISTING BUCKETS
-- ============================================================
-- Run this to see all buckets in your Supabase project
SELECT 
    id as bucket_name,
    name as display_name,
    public,
    created_at
FROM storage.buckets
ORDER BY created_at DESC;

-- ============================================================
-- 2. CREATE BUCKETS (Alternative: Use Dashboard for easier setup)
-- ============================================================
-- Note: It's recommended to create buckets via Supabase Dashboard
-- But you can also use these SQL commands if preferred

-- Create product-images bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('product-images', 'product-images', true, 52428800)
ON CONFLICT (id) DO NOTHING;

-- Create product-images-slot-1 bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('product-images-slot-1', 'product-images-slot-1', true, 52428800)
ON CONFLICT (id) DO NOTHING;

-- Create product-images-slot-2 bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('product-images-slot-2', 'product-images-slot-2', true, 52428800)
ON CONFLICT (id) DO NOTHING;

-- Create product-images-slot-3 bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('product-images-slot-3', 'product-images-slot-3', true, 52428800)
ON CONFLICT (id) DO NOTHING;

-- Create product-images-slot-4 bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('product-images-slot-4', 'product-images-slot-4', true, 52428800)
ON CONFLICT (id) DO NOTHING;

-- Create gallery-images bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('gallery-images', 'gallery-images', true, 52428800)
ON CONFLICT (id) DO NOTHING;

-- Create videos bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('videos', 'videos', true, 104857600)
ON CONFLICT (id) DO NOTHING;

-- Create transaction-screenshots bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('transaction-screenshots', 'transaction-screenshots', true, 52428800)
ON CONFLICT (id) DO NOTHING;

-- Create service-images bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('service-images', 'service-images', true, 52428800)
ON CONFLICT (id) DO NOTHING;

-- Create home-images bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('home-images', 'home-images', true, 52428800)
ON CONFLICT (id) DO NOTHING;

-- Create testimonials bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('testimonials', 'testimonials', true, 52428800)
ON CONFLICT (id) DO NOTHING;

-- Create invoices bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('invoices', 'invoices', true, 104857600)
ON CONFLICT (id) DO NOTHING;

-- Create documents bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('documents', 'documents', true, 104857600)
ON CONFLICT (id) DO NOTHING;

-- Create banners bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('banners', 'banners', true, 52428800)
ON CONFLICT (id) DO NOTHING;

-- Create profile-images bucket (PUBLIC)
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('profile-images', 'profile-images', true, 52428800)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 3. VERIFY BUCKETS CREATED
-- ============================================================
-- Run this to verify all buckets are created and public
SELECT 
    id as bucket_name,
    public as is_public,
    file_size_limit as size_limit,
    created_at
FROM storage.buckets
WHERE id IN (
    'product-images',
    'product-images-slot-1',
    'product-images-slot-2',
    'product-images-slot-3',
    'product-images-slot-4',
    'gallery-images',
    'videos',
    'transaction-screenshots',
    'service-images',
    'home-images',
    'testimonials',
    'invoices',
    'documents',
    'banners',
    'profile-images'
)
ORDER BY id;

-- ============================================================
-- 4. SET BUCKET POLICIES - RLS (Row Level Security)
-- ============================================================

-- Allow public to read from all buckets
DROP POLICY IF EXISTS "Public access for product-images" ON storage.objects;
CREATE POLICY "Public access for product-images" ON storage.objects
    FOR SELECT USING (bucket_id = 'product-images');

DROP POLICY IF EXISTS "Public access for product-images-slot-1" ON storage.objects;
CREATE POLICY "Public access for product-images-slot-1" ON storage.objects
    FOR SELECT USING (bucket_id = 'product-images-slot-1');

DROP POLICY IF EXISTS "Public access for product-images-slot-2" ON storage.objects;
CREATE POLICY "Public access for product-images-slot-2" ON storage.objects
    FOR SELECT USING (bucket_id = 'product-images-slot-2');

DROP POLICY IF EXISTS "Public access for product-images-slot-3" ON storage.objects;
CREATE POLICY "Public access for product-images-slot-3" ON storage.objects
    FOR SELECT USING (bucket_id = 'product-images-slot-3');

DROP POLICY IF EXISTS "Public access for product-images-slot-4" ON storage.objects;
CREATE POLICY "Public access for product-images-slot-4" ON storage.objects
    FOR SELECT USING (bucket_id = 'product-images-slot-4');

DROP POLICY IF EXISTS "Public access for gallery-images" ON storage.objects;
CREATE POLICY "Public access for gallery-images" ON storage.objects
    FOR SELECT USING (bucket_id = 'gallery-images');

DROP POLICY IF EXISTS "Public access for videos" ON storage.objects;
CREATE POLICY "Public access for videos" ON storage.objects
    FOR SELECT USING (bucket_id = 'videos');

DROP POLICY IF EXISTS "Public access for transaction-screenshots" ON storage.objects;
CREATE POLICY "Public access for transaction-screenshots" ON storage.objects
    FOR SELECT USING (bucket_id = 'transaction-screenshots');

DROP POLICY IF EXISTS "Public access for service-images" ON storage.objects;
CREATE POLICY "Public access for service-images" ON storage.objects
    FOR SELECT USING (bucket_id = 'service-images');

DROP POLICY IF EXISTS "Public access for home-images" ON storage.objects;
CREATE POLICY "Public access for home-images" ON storage.objects
    FOR SELECT USING (bucket_id = 'home-images');

DROP POLICY IF EXISTS "Public access for testimonials" ON storage.objects;
CREATE POLICY "Public access for testimonials" ON storage.objects
    FOR SELECT USING (bucket_id = 'testimonials');

DROP POLICY IF EXISTS "Public access for invoices" ON storage.objects;
CREATE POLICY "Public access for invoices" ON storage.objects
    FOR SELECT USING (bucket_id = 'invoices');

DROP POLICY IF EXISTS "Public access for documents" ON storage.objects;
CREATE POLICY "Public access for documents" ON storage.objects
    FOR SELECT USING (bucket_id = 'documents');

DROP POLICY IF EXISTS "Public access for banners" ON storage.objects;
CREATE POLICY "Public access for banners" ON storage.objects
    FOR SELECT USING (bucket_id = 'banners');

DROP POLICY IF EXISTS "Public access for profile-images" ON storage.objects;
CREATE POLICY "Public access for profile-images" ON storage.objects
    FOR SELECT USING (bucket_id = 'profile-images');

-- Allow authenticated users to upload to all buckets
DROP POLICY IF EXISTS "Authenticated upload for product-images" ON storage.objects;
CREATE POLICY "Authenticated upload for product-images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'product-images');

DROP POLICY IF EXISTS "Authenticated upload for product-images-slot-1" ON storage.objects;
CREATE POLICY "Authenticated upload for product-images-slot-1" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'product-images-slot-1');

DROP POLICY IF EXISTS "Authenticated upload for product-images-slot-2" ON storage.objects;
CREATE POLICY "Authenticated upload for product-images-slot-2" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'product-images-slot-2');

DROP POLICY IF EXISTS "Authenticated upload for product-images-slot-3" ON storage.objects;
CREATE POLICY "Authenticated upload for product-images-slot-3" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'product-images-slot-3');

DROP POLICY IF EXISTS "Authenticated upload for product-images-slot-4" ON storage.objects;
CREATE POLICY "Authenticated upload for product-images-slot-4" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'product-images-slot-4');

DROP POLICY IF EXISTS "Authenticated upload for gallery-images" ON storage.objects;
CREATE POLICY "Authenticated upload for gallery-images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'gallery-images');

DROP POLICY IF EXISTS "Authenticated upload for videos" ON storage.objects;
CREATE POLICY "Authenticated upload for videos" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'videos');

DROP POLICY IF EXISTS "Authenticated upload for transaction-screenshots" ON storage.objects;
CREATE POLICY "Authenticated upload for transaction-screenshots" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'transaction-screenshots');

DROP POLICY IF EXISTS "Authenticated upload for service-images" ON storage.objects;
CREATE POLICY "Authenticated upload for service-images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'service-images');

DROP POLICY IF EXISTS "Authenticated upload for home-images" ON storage.objects;
CREATE POLICY "Authenticated upload for home-images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'home-images');

DROP POLICY IF EXISTS "Authenticated upload for testimonials" ON storage.objects;
CREATE POLICY "Authenticated upload for testimonials" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'testimonials');

DROP POLICY IF EXISTS "Authenticated upload for invoices" ON storage.objects;
CREATE POLICY "Authenticated upload for invoices" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'invoices');

DROP POLICY IF EXISTS "Authenticated upload for documents" ON storage.objects;
CREATE POLICY "Authenticated upload for documents" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'documents');

DROP POLICY IF EXISTS "Authenticated upload for banners" ON storage.objects;
CREATE POLICY "Authenticated upload for banners" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'banners');

DROP POLICY IF EXISTS "Authenticated upload for profile-images" ON storage.objects;
CREATE POLICY "Authenticated upload for profile-images" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'profile-images');

-- ============================================================
-- 5. UPDATE BUCKET TO PUBLIC (If needed)
-- ============================================================
-- Run this if you need to make a bucket public after creation

UPDATE storage.buckets SET public = true WHERE id = 'product-images';
UPDATE storage.buckets SET public = true WHERE id = 'product-images-slot-1';
UPDATE storage.buckets SET public = true WHERE id = 'product-images-slot-2';
UPDATE storage.buckets SET public = true WHERE id = 'product-images-slot-3';
UPDATE storage.buckets SET public = true WHERE id = 'product-images-slot-4';
UPDATE storage.buckets SET public = true WHERE id = 'gallery-images';
UPDATE storage.buckets SET public = true WHERE id = 'videos';
UPDATE storage.buckets SET public = true WHERE id = 'transaction-screenshots';
UPDATE storage.buckets SET public = true WHERE id = 'service-images';
UPDATE storage.buckets SET public = true WHERE id = 'home-images';
UPDATE storage.buckets SET public = true WHERE id = 'testimonials';
UPDATE storage.buckets SET public = true WHERE id = 'invoices';
UPDATE storage.buckets SET public = true WHERE id = 'documents';
UPDATE storage.buckets SET public = true WHERE id = 'banners';
UPDATE storage.buckets SET public = true WHERE id = 'profile-images';

-- ============================================================
-- 6. GET STORAGE USAGE STATISTICS
-- ============================================================

-- Total storage used by bucket
SELECT 
    bucket_id as bucket_name,
    COUNT(*) as file_count,
    COALESCE(SUM((metadata->>'size')::BIGINT), 0) as total_bytes,
    ROUND(COALESCE(SUM((metadata->>'size')::BIGINT), 0) / 1024.0 / 1024.0, 2) as total_mb
FROM storage.objects
WHERE bucket_id IN (
    'product-images',
    'product-images-slot-1',
    'product-images-slot-2',
    'product-images-slot-3',
    'product-images-slot-4',
    'gallery-images',
    'videos',
    'transaction-screenshots',
    'service-images',
    'home-images',
    'testimonials',
    'invoices',
    'documents',
    'banners',
    'profile-images'
)
GROUP BY bucket_id
ORDER BY total_bytes DESC;

-- List all files in a specific bucket
SELECT 
    name as filename,
    metadata->>'size' as file_size_bytes,
    created_at,
    updated_at
FROM storage.objects
WHERE bucket_id = 'product-images'
ORDER BY created_at DESC;

-- ============================================================
-- 7. DELETE BUCKET (Use with caution!)
-- ============================================================
-- WARNING: This will delete the bucket and ALL files in it!

-- DELETE FROM storage.buckets WHERE id = 'product-images';

-- ============================================================
-- 8. BUCKET-SPECIFIC OPERATIONS
-- ============================================================

-- List files in product-images-slot-1
SELECT name, metadata FROM storage.objects 
WHERE bucket_id = 'product-images-slot-1' 
ORDER BY created_at DESC;

-- Count files in each bucket
SELECT 
    bucket_id,
    COUNT(*) as file_count
FROM storage.objects
GROUP BY bucket_id
ORDER BY file_count DESC;

-- Find largest files
SELECT 
    bucket_id,
    name,
    (metadata->>'size')::BIGINT / 1024 / 1024 as size_mb,
    created_at
FROM storage.objects
ORDER BY (metadata->>'size')::BIGINT DESC
LIMIT 20;

-- ============================================================
-- 9. BUCKET SIZE LIMITS
-- ============================================================
-- Note: File size limits (in bytes)
-- 50 MB = 52,428,800 bytes
-- 100 MB = 104,857,600 bytes
-- 500 MB = 524,288,000 bytes
-- 1 GB = 1,073,741,824 bytes

-- Update bucket file size limit
UPDATE storage.buckets 
SET file_size_limit = 104857600 
WHERE id = 'videos';

-- ============================================================
-- 10. SUPABASE URL & PATH REFERENCES
-- ============================================================
-- Use these patterns to reference files from your application:
--
-- Base URL: https://YOUR_PROJECT_ID.supabase.co/storage/v1/object/public/
--
-- Product Images:
-- https://YOUR_PROJECT_ID.supabase.co/storage/v1/object/public/product-images/filename.jpg
--
-- Gallery Images:
-- https://YOUR_PROJECT_ID.supabase.co/storage/v1/object/public/gallery-images/filename.jpg
--
-- Video:
-- https://YOUR_PROJECT_ID.supabase.co/storage/v1/object/public/videos/filename.mp4
--
-- Transaction Screenshot:
-- https://YOUR_PROJECT_ID.supabase.co/storage/v1/object/public/transaction-screenshots/filename.jpg
--
-- Service Images:
-- https://YOUR_PROJECT_ID.supabase.co/storage/v1/object/public/service-images/filename.jpg

-- ============================================================
-- 11. JAVASCRIPT USAGE EXAMPLES
-- ============================================================
/*

// Upload a file to product-images bucket
const { data, error } = await supabase.storage
  .from('product-images')
  .upload(`product-${Date.now()}.jpg`, file);

// Upload to specific slot
const { data, error } = await supabase.storage
  .from('product-images-slot-1')
  .upload(`product-${productId}-slot1.jpg`, file);

// Get public URL
const { data } = supabase.storage
  .from('product-images')
  .getPublicUrl('product-123.jpg');

const publicUrl = data.publicUrl;

// List all files in bucket
const { data, error } = await supabase.storage
  .from('product-images')
  .list();

// Delete a file
const { data, error } = await supabase.storage
  .from('product-images')
  .remove(['product-123.jpg']);

// Get file metadata
const { data, error } = await supabase.storage
  .from('product-images')
  .info('product-123.jpg');

*/

-- ============================================================
-- DASHBOARD SETUP (Easiest Method)
-- ============================================================
-- Instead of using SQL, you can create buckets via dashboard:
--
-- 1. Go to Supabase Dashboard
-- 2. Click "Storage" in the left sidebar
-- 3. Click "New bucket"
-- 4. Enter bucket name (use names from section 1)
-- 5. Toggle "Public" to ON
-- 6. Click "Create bucket"
-- 7. Repeat for each bucket
--
-- This is the recommended method as it's more visual and error-proof.

-- ============================================================
-- TROUBLESHOOTING
-- ============================================================

-- Check if RLS is enabled on storage.objects
SELECT *
FROM pg_policies
WHERE tablename = 'objects' AND schemaname = 'storage';

-- Check bucket access
SELECT id as bucket_id, public FROM storage.buckets 
WHERE id IN (
    'product-images',
    'product-images-slot-1',
    'product-images-slot-2',
    'product-images-slot-3',
    'product-images-slot-4',
    'gallery-images',
    'videos',
    'transaction-screenshots',
    'service-images',
    'home-images',
    'testimonials',
    'invoices',
    'documents',
    'banners',
    'profile-images'
);

-- Clear all buckets (dangerous - clears all files)
-- DELETE FROM storage.objects WHERE bucket_id IN (
--     'product-images',
--     'product-images-slot-1',
--     'product-images-slot-2',
--     'product-images-slot-3',
--     'product-images-slot-4',
--     'gallery-images',
--     'videos',
--     'transaction-screenshots',
--     'service-images',
--     'home-images',
--     'testimonials',
--     'invoices',
--     'documents',
--     'banners',
--     'profile-images'
-- );

-- ============================================================
-- END OF STORAGE BUCKETS SETUP
-- ============================================================
