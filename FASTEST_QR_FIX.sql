-- FASTEST FIX: Disable Storage RLS Completely
-- This allows anyone to upload QR codes without RLS blocking

-- ==========================================
-- OPTION 1: Disable RLS on storage.objects (FASTEST)
-- ==========================================

-- Disable RLS on storage.objects table entirely
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- This allows:
-- ✅ Anyone to upload files
-- ✅ Anyone to read files
-- ✅ Anyone to delete files
-- ✅ No RLS blocking

-- ==========================================
-- OPTION 2: If Option 1 doesn't work, use this
-- ==========================================

-- Make bucket completely public by setting it to allow all
UPDATE storage.buckets 
SET public = true
WHERE name = 'payment-qr-images';

-- ==========================================
-- OPTION 3: Create permissive storage policies
-- ==========================================

-- Drop any existing restrictive policies
DROP POLICY IF EXISTS "Allow upload to payment-qr-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow read payment-qr-images" ON storage.objects;

-- Create completely permissive policies
CREATE POLICY "Allow all storage operations"
ON storage.objects
FOR ALL
TO public
USING (true)
WITH CHECK (true);

-- ==========================================
-- If none of the above work, do this:
-- ==========================================

-- Check bucket existence
-- SELECT id, name, public FROM storage.buckets WHERE name = 'payment-qr-images';

-- Check RLS status
-- SELECT schemaname, tablename, rowsecurity FROM pg_tables WHERE tablename = 'objects';

-- Check policies
-- SELECT * FROM pg_policies WHERE tablename = 'objects';

-- ==========================================
-- SUMMARY
-- ==========================================
-- This script disables RLS entirely on storage
-- Allows ANYONE to upload/delete/modify files
-- No authentication required
-- ==========================================
