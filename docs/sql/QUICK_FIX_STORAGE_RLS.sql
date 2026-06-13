-- QUICK FIX: Copy and Run in Supabase SQL Editor
-- This fixes: StorageApiError: new row violates row-level security policy

-- Create buckets
INSERT INTO storage.buckets (id, name, public) VALUES ('gallery', 'gallery', true) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('product-images', 'product-images', true) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('videos', 'videos', true) ON CONFLICT (id) DO NOTHING;

-- Drop old policies
DROP POLICY IF EXISTS "Gallery - Public Select" ON storage.objects;
DROP POLICY IF EXISTS "Gallery - Authenticated Insert" ON storage.objects;
DROP POLICY IF EXISTS "Gallery - Authenticated Update" ON storage.objects;
DROP POLICY IF EXISTS "Gallery - Authenticated Delete" ON storage.objects;
DROP POLICY IF EXISTS "Product Images - Public Select" ON storage.objects;
DROP POLICY IF EXISTS "Product Images - Authenticated Insert" ON storage.objects;
DROP POLICY IF EXISTS "Product Images - Authenticated Update" ON storage.objects;
DROP POLICY IF EXISTS "Product Images - Authenticated Delete" ON storage.objects;
DROP POLICY IF EXISTS "Videos - Public Select" ON storage.objects;
DROP POLICY IF EXISTS "Videos - Authenticated Insert" ON storage.objects;
DROP POLICY IF EXISTS "Videos - Authenticated Update" ON storage.objects;
DROP POLICY IF EXISTS "Videos - Authenticated Delete" ON storage.objects;

-- Gallery policies
CREATE POLICY "Gallery - Public Select" ON storage.objects FOR SELECT USING (bucket_id = 'gallery');
CREATE POLICY "Gallery - Authenticated Insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'gallery');
CREATE POLICY "Gallery - Authenticated Update" ON storage.objects FOR UPDATE USING (bucket_id = 'gallery') WITH CHECK (bucket_id = 'gallery');
CREATE POLICY "Gallery - Authenticated Delete" ON storage.objects FOR DELETE USING (bucket_id = 'gallery');

-- Product Images policies
CREATE POLICY "Product Images - Public Select" ON storage.objects FOR SELECT USING (bucket_id = 'product-images');
CREATE POLICY "Product Images - Authenticated Insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'product-images');
CREATE POLICY "Product Images - Authenticated Update" ON storage.objects FOR UPDATE USING (bucket_id = 'product-images') WITH CHECK (bucket_id = 'product-images');
CREATE POLICY "Product Images - Authenticated Delete" ON storage.objects FOR DELETE USING (bucket_id = 'product-images');

-- Videos policies
CREATE POLICY "Videos - Public Select" ON storage.objects FOR SELECT USING (bucket_id = 'videos');
CREATE POLICY "Videos - Authenticated Insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'videos');
CREATE POLICY "Videos - Authenticated Update" ON storage.objects FOR UPDATE USING (bucket_id = 'videos') WITH CHECK (bucket_id = 'videos');
CREATE POLICY "Videos - Authenticated Delete" ON storage.objects FOR DELETE USING (bucket_id = 'videos');

-- Verify buckets
SELECT id, name, public FROM storage.buckets WHERE id IN ('gallery', 'product-images', 'videos');

-- Verify policies
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'objects' AND schemaname = 'storage' ORDER BY policyname;
