-- ============================================================
-- COMPANY PROFILE AND LOGO BUCKET SETUP
-- Run this SQL in your Supabase SQL Editor
-- ============================================================

-- 1. Create the 'logo' storage bucket if it does not exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('logo', 'logo', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Ensure Row Level Security (RLS) is enabled on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 3. Create Storage Policies for 'logo' bucket
-- Policy: Public View (SELECT)
DROP POLICY IF EXISTS "Public View Logo" ON storage.objects;
CREATE POLICY "Public View Logo" ON storage.objects
    FOR SELECT USING (bucket_id = 'logo');

-- Policy: Authenticated Upload (INSERT)
DROP POLICY IF EXISTS "Authenticated Upload Logo" ON storage.objects;
CREATE POLICY "Authenticated Upload Logo" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'logo');

-- Policy: Authenticated Update (UPDATE)
DROP POLICY IF EXISTS "Authenticated Update Logo" ON storage.objects;
CREATE POLICY "Authenticated Update Logo" ON storage.objects
    FOR UPDATE USING (bucket_id = 'logo')
    WITH CHECK (bucket_id = 'logo');

-- Policy: Authenticated Delete (DELETE)
DROP POLICY IF EXISTS "Authenticated Delete Logo" ON storage.objects;
CREATE POLICY "Authenticated Delete Logo" ON storage.objects
    FOR DELETE USING (bucket_id = 'logo');

-- 4. Seed the initial Company Profile setting in admin_settings table
INSERT INTO admin_settings (setting_key, setting_value)
VALUES ('company_profile', '{"company_name":"Nepo Online Stores","logo_url":"uploads/logo.png","email":"info@nepoonline.com","phone":"033590207","location":"Khaireni, Gulmi, Nepal"}')
ON CONFLICT (setting_key) DO NOTHING;
