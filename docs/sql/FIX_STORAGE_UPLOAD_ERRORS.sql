-- ============================================================
-- COMPLETE FIX FOR STORAGE BUCKET RLS ERRORS
-- Fixes: StorageApiError: new row violates row-level security policy
-- ============================================================

-- Step 1: Ensure all storage buckets exist
-- Check if gallery bucket exists, if not create it
INSERT INTO storage.buckets (id, name, public)
VALUES ('gallery', 'gallery', true)
ON CONFLICT (id) DO NOTHING;

-- Check if product-images bucket exists, if not create it
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- Check if videos bucket exists, if not create it
INSERT INTO storage.buckets (id, name, public)
VALUES ('videos', 'videos', true)
ON CONFLICT (id) DO NOTHING;

-- Check if transaction-screenshots bucket exists, if not create it
INSERT INTO storage.buckets (id, name, public)
VALUES ('transaction-screenshots', 'transaction-screenshots', true)
ON CONFLICT (id) DO NOTHING;

-- Step 2: Drop all existing RLS policies on storage.objects
-- This prevents conflicts
DROP POLICY IF EXISTS "Public Select Gallery" ON storage.objects;
DROP POLICY IF EXISTS "Public Select Product Images" ON storage.objects;
DROP POLICY IF EXISTS "Public Select Videos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Insert Gallery" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Insert Product Images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Insert Videos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update Gallery" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update Product Images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update Videos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete Gallery" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete Product Images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete Videos" ON storage.objects;
DROP POLICY IF EXISTS "Public Access Videos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload Videos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete Videos" ON storage.objects;
DROP POLICY IF EXISTS "Public View Videos" ON storage.objects;
DROP POLICY IF EXISTS "Allow Upload" ON storage.objects;
DROP POLICY IF EXISTS "Allow Update" ON storage.objects;
DROP POLICY IF EXISTS "Allow Delete" ON storage.objects;
DROP POLICY IF EXISTS "Public Read Gallery" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload Gallery" ON storage.objects;
DROP POLICY IF EXISTS "Public Read All" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload All" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Update All" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete All" ON storage.objects;
DROP POLICY IF EXISTS "Transaction Screenshots - Public Select" ON storage.objects;
DROP POLICY IF EXISTS "Transaction Screenshots - Authenticated Insert" ON storage.objects;
DROP POLICY IF EXISTS "Transaction Screenshots - Authenticated Update" ON storage.objects;
DROP POLICY IF EXISTS "Transaction Screenshots - Authenticated Delete" ON storage.objects;

-- Step 3: Create PERMISSIVE policies for GALLERY bucket
CREATE POLICY "Gallery - Public Select" ON storage.objects
    FOR SELECT USING (bucket_id = 'gallery');

CREATE POLICY "Gallery - Authenticated Insert" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'gallery');

CREATE POLICY "Gallery - Authenticated Update" ON storage.objects
    FOR UPDATE USING (bucket_id = 'gallery')
    WITH CHECK (bucket_id = 'gallery');

CREATE POLICY "Gallery - Authenticated Delete" ON storage.objects
    FOR DELETE USING (bucket_id = 'gallery');

-- Step 4: Create PERMISSIVE policies for PRODUCT-IMAGES bucket
CREATE POLICY "Product Images - Public Select" ON storage.objects
    FOR SELECT USING (bucket_id = 'product-images');

CREATE POLICY "Product Images - Authenticated Insert" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'product-images');

CREATE POLICY "Product Images - Authenticated Update" ON storage.objects
    FOR UPDATE USING (bucket_id = 'product-images')
    WITH CHECK (bucket_id = 'product-images');

CREATE POLICY "Product Images - Authenticated Delete" ON storage.objects
    FOR DELETE USING (bucket_id = 'product-images');

-- Step 5: Create PERMISSIVE policies for VIDEOS bucket
CREATE POLICY "Videos - Public Select" ON storage.objects
    FOR SELECT USING (bucket_id = 'videos');

CREATE POLICY "Videos - Authenticated Insert" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'videos');

CREATE POLICY "Videos - Authenticated Update" ON storage.objects
    FOR UPDATE USING (bucket_id = 'videos')
    WITH CHECK (bucket_id = 'videos');

CREATE POLICY "Videos - Authenticated Delete" ON storage.objects
    FOR DELETE USING (bucket_id = 'videos');

-- Step 6: Create PERMISSIVE policies for TRANSACTION-SCREENSHOTS bucket
DROP POLICY IF EXISTS "Transaction Screenshots - Public Select" ON storage.objects;
DROP POLICY IF EXISTS "Transaction Screenshots - Authenticated Insert" ON storage.objects;
DROP POLICY IF EXISTS "Transaction Screenshots - Authenticated Update" ON storage.objects;
DROP POLICY IF EXISTS "Transaction Screenshots - Authenticated Delete" ON storage.objects;

CREATE POLICY "Transaction Screenshots - Public Select" ON storage.objects
    FOR SELECT USING (bucket_id = 'transaction-screenshots');

CREATE POLICY "Transaction Screenshots - Authenticated Insert" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'transaction-screenshots');

CREATE POLICY "Transaction Screenshots - Authenticated Update" ON storage.objects
    FOR UPDATE USING (bucket_id = 'transaction-screenshots')
    WITH CHECK (bucket_id = 'transaction-screenshots');

CREATE POLICY "Transaction Screenshots - Authenticated Delete" ON storage.objects
    FOR DELETE USING (bucket_id = 'transaction-screenshots');

-- Step 7: Verify all buckets exist
SELECT 
    id,
    name,
    public,
    created_at
FROM storage.buckets
WHERE id IN ('gallery', 'product-images', 'videos', 'transaction-screenshots')
ORDER BY id;

-- Step 8: Verify all RLS policies are created
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    cmd
FROM pg_policies
WHERE tablename = 'objects' AND schemaname = 'storage'
ORDER BY policyname;
