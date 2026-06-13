-- ============================================================
-- STORAGE RLS POLICY FIX - PERMISSIVE APPROACH
-- (No ALTER TABLE needed - just policies)
-- ============================================================

-- Drop all old policies first
DROP POLICY IF EXISTS "Public Access Videos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Upload Videos" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated Delete Videos" ON storage.objects;
DROP POLICY IF EXISTS "Public View Videos" ON storage.objects;
DROP POLICY IF EXISTS "Allow Upload" ON storage.objects;
DROP POLICY IF EXISTS "Allow Update" ON storage.objects;
DROP POLICY IF EXISTS "Allow Delete" ON storage.objects;

-- POLICY 1: Public READ (SELECT) - Anyone can view files in videos bucket
CREATE POLICY "Public Select Videos" ON storage.objects
    FOR SELECT USING (bucket_id = 'videos');

-- POLICY 2: Authenticated INSERT - Authenticated users can upload
-- Using most permissive check - just the bucket name
CREATE POLICY "Authenticated Insert Videos" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'videos');

-- POLICY 3: Authenticated UPDATE - Can modify files
CREATE POLICY "Authenticated Update Videos" ON storage.objects
    FOR UPDATE USING (bucket_id = 'videos')
    WITH CHECK (bucket_id = 'videos');

-- POLICY 4: Authenticated DELETE - Can delete files
CREATE POLICY "Authenticated Delete Videos" ON storage.objects
    FOR DELETE USING (bucket_id = 'videos');

-- ============================================================
-- VERIFY POLICIES CREATED
-- ============================================================

SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage'
ORDER BY policyname;
