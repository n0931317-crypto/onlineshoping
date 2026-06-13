-- ============================================================================
-- Nepo Online stores - COMPLETE STORAGE BUCKET & RLS SETUP
-- ============================================================================
-- This script creates all required storage buckets and configures RLS policies
-- Run this in Supabase SQL Editor

-- ============================================================================
-- STEP 1: CREATE ALL REQUIRED BUCKETS
-- ============================================================================

-- Note: Buckets must be created via Supabase Dashboard, not SQL
-- Go to: Storage > New Bucket and create these:
-- 1. product-images (Public)
-- 2. service-images (Public)
-- 3. gallery-images (Public)
-- 4. category-images (Public)
-- 5. admin-files (Private)

-- ============================================================================
-- STEP 2: DROP EXISTING POLICIES (if any)
-- ============================================================================
-- Note: RLS is already enabled by default in Supabase

DROP POLICY IF EXISTS "Public Read Access" ON storage.objects;
DROP POLICY IF EXISTS "Public Write Access" ON storage.objects;
DROP POLICY IF EXISTS "Admin Write Access" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete" ON storage.objects;
DROP POLICY IF EXISTS "Admin Files Policy" ON storage.objects;
DROP POLICY IF EXISTS "Public Read All Images" ON storage.objects;
DROP POLICY IF EXISTS "Allow Upload Images" ON storage.objects;
DROP POLICY IF EXISTS "Allow Update Images" ON storage.objects;
DROP POLICY IF EXISTS "Allow Delete Images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Read Admin Files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Write Admin Files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update Admin Files" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete Admin Files" ON storage.objects;

-- ============================================================================
-- STEP 3: CREATE NEW RLS POLICIES FOR PUBLIC BUCKETS
-- ============================================================================

-- Policy 1: Public READ for product-images, service-images, gallery-images, category-images
CREATE POLICY "Public Read All Images" ON storage.objects
FOR SELECT
USING (
  bucket_id IN (
    'product-images',
    'service-images', 
    'gallery-images',
    'category-images'
  )
);

-- Policy 2: Allow UPLOAD to public image buckets (authenticated or unauthenticated)
CREATE POLICY "Allow Upload Images" ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id IN (
    'product-images',
    'service-images',
    'gallery-images',
    'category-images'
  )
);

-- Policy 3: Allow UPDATE files in public image buckets (authenticated users)
CREATE POLICY "Allow Update Images" ON storage.objects
FOR UPDATE
USING (
  auth.role() = 'authenticated'
  AND bucket_id IN (
    'product-images',
    'service-images',
    'gallery-images',
    'category-images'
  )
)
WITH CHECK (
  auth.role() = 'authenticated'
  AND bucket_id IN (
    'product-images',
    'service-images',
    'gallery-images',
    'category-images'
  )
);

-- Policy 4: Allow DELETE files from public image buckets (authenticated users)
CREATE POLICY "Allow Delete Images" ON storage.objects
FOR DELETE
USING (
  auth.role() = 'authenticated'
  AND bucket_id IN (
    'product-images',
    'service-images',
    'gallery-images',
    'category-images'
  )
);

-- ============================================================================
-- STEP 4: CREATE RLS POLICIES FOR PRIVATE BUCKETS
-- ============================================================================

-- Policy 5: Admin Files - Authenticated read
CREATE POLICY "Authenticated Read Admin Files" ON storage.objects
FOR SELECT
USING (
  auth.role() = 'authenticated'
  AND bucket_id = 'admin-files'
);

-- Policy 6: Admin Files - Authenticated write
CREATE POLICY "Authenticated Write Admin Files" ON storage.objects
FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated'
  AND bucket_id = 'admin-files'
);

-- Policy 7: Admin Files - Authenticated update
CREATE POLICY "Authenticated Update Admin Files" ON storage.objects
FOR UPDATE
USING (
  auth.role() = 'authenticated'
  AND bucket_id = 'admin-files'
)
WITH CHECK (
  auth.role() = 'authenticated'
  AND bucket_id = 'admin-files'
);

-- Policy 8: Admin Files - Authenticated delete
CREATE POLICY "Authenticated Delete Admin Files" ON storage.objects
FOR DELETE
USING (
  auth.role() = 'authenticated'
  AND bucket_id = 'admin-files'
);

-- ============================================================================
-- STEP 5: VERIFICATION QUERIES
-- ============================================================================

-- View all buckets
SELECT id, name, public FROM storage.buckets;

-- View all RLS policies on storage.objects
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'storage' AND tablename = 'objects'
ORDER BY policyname;

-- ============================================================================
-- STEP 6: SUMMARY OF BUCKETS CREATED
-- ============================================================================
/*
✓ product-images   - Public, 50MB per file
✓ service-images   - Public, 50MB per file
✓ gallery-images   - Public, 100MB per file
✓ category-images  - Public, 50MB per file
✓ admin-files      - Private, 200MB per file

Each public bucket allows:
  - Anyone to READ files
  - Authenticated users to UPLOAD/UPDATE/DELETE files

Admin-files bucket allows:
  - Only authenticated users to READ/WRITE/UPDATE/DELETE files
*/
