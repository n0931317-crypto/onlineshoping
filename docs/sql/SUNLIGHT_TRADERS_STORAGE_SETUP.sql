-- ============================================================================
-- Nepo Online stores - Storage Buckets Setup
-- ============================================================================
-- This script sets up all storage buckets for Nepo Online stores
-- Run this in Supabase SQL Editor after creating the buckets via UI
-- OR use this as reference for creating buckets manually
-- ============================================================================

-- ============================================================================
-- NOTE: Create these buckets via Supabase UI first:
-- ============================================================================
-- 1. product-images (Public)
-- 2. gallery-images (Public)
-- 3. logo (Public)
-- 4. videos (Public)
-- 5. admin-uploads (Private)
-- ============================================================================

-- ============================================================================
-- CREATE STORAGE BUCKETS (Alternative: Use Supabase UI)
-- ============================================================================

-- Insert bucket definitions
INSERT INTO storage.buckets (id, name, public) VALUES
('product-images', 'product-images', true),
('gallery-images', 'gallery-images', true),
('logo', 'logo', true),
('videos', 'videos', true),
('admin-uploads', 'admin-uploads', false)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- CREATE RLS POLICIES FOR STORAGE BUCKETS
-- ============================================================================

-- Product Images Bucket - Public read, Authenticated write
DROP POLICY IF EXISTS "Product Images - Public Read" ON storage.objects;
CREATE POLICY "Product Images - Public Read" ON storage.objects
FOR SELECT USING (bucket_id = 'product-images' AND public = true);

DROP POLICY IF EXISTS "Product Images - Authenticated Write" ON storage.objects;
CREATE POLICY "Product Images - Authenticated Write" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'product-images' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Product Images - Authenticated Delete" ON storage.objects;
CREATE POLICY "Product Images - Authenticated Delete" ON storage.objects
FOR DELETE USING (bucket_id = 'product-images' AND auth.role() = 'authenticated');

-- Gallery Images Bucket - Public read, Authenticated write
DROP POLICY IF EXISTS "Gallery Images - Public Read" ON storage.objects;
CREATE POLICY "Gallery Images - Public Read" ON storage.objects
FOR SELECT USING (bucket_id = 'gallery-images' AND public = true);

DROP POLICY IF EXISTS "Gallery Images - Authenticated Write" ON storage.objects;
CREATE POLICY "Gallery Images - Authenticated Write" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'gallery-images' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Gallery Images - Authenticated Delete" ON storage.objects;
CREATE POLICY "Gallery Images - Authenticated Delete" ON storage.objects
FOR DELETE USING (bucket_id = 'gallery-images' AND auth.role() = 'authenticated');

-- Logo Bucket - Public read
DROP POLICY IF EXISTS "Logo - Public Read" ON storage.objects;
CREATE POLICY "Logo - Public Read" ON storage.objects
FOR SELECT USING (bucket_id = 'logo' AND public = true);

DROP POLICY IF EXISTS "Logo - Authenticated Write" ON storage.objects;
CREATE POLICY "Logo - Authenticated Write" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'logo' AND auth.role() = 'authenticated');

-- Videos Bucket - Public read, Authenticated write
DROP POLICY IF EXISTS "Videos - Public Read" ON storage.objects;
CREATE POLICY "Videos - Public Read" ON storage.objects
FOR SELECT USING (bucket_id = 'videos' AND public = true);

DROP POLICY IF EXISTS "Videos - Authenticated Write" ON storage.objects;
CREATE POLICY "Videos - Authenticated Write" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'videos' AND auth.role() = 'authenticated');

-- Admin Uploads - Private bucket
DROP POLICY IF EXISTS "Admin Uploads - Authenticated Only" ON storage.objects;
CREATE POLICY "Admin Uploads - Authenticated Only" ON storage.objects
FOR SELECT USING (bucket_id = 'admin-uploads' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Admin Uploads - Authenticated Write" ON storage.objects;
CREATE POLICY "Admin Uploads - Authenticated Write" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'admin-uploads' AND auth.role() = 'authenticated');

-- ============================================================================
-- BUCKET STRUCTURE & RECOMMENDATIONS
-- ============================================================================

/*

BUCKET: product-images
├── saree-blue-1.jpg
├── saree-blue-2.jpg
├── saree-red-1.jpg
├── saree-red-2.jpg
├── suit-green-1.jpg
├── suit-green-2.jpg
├── suit-yellow-1.jpg
├── lehenga-gold-1.jpg
├── lehenga-gold-2.jpg
└── (up to 4 images per product)

BUCKET: gallery-images
├── sarees-collection.jpg
├── suits-collection.jpg
├── lehengas-collection.jpg
├── boots-collection.jpg
└── summer-readymade.jpg

BUCKET: logo
└── sunlight-traders-logo.svg

BUCKET: videos
└── fashion-showcase.mp4

BUCKET: admin-uploads
├── invoices/
├── reports/
└── temp-uploads/

*/

-- ============================================================================
-- IMAGE URL FORMAT IN DATABASE
-- ============================================================================

/*
For storing image URLs in the database, use this format:

1. Product Images in database:
   '/product-images/saree-blue-1.jpg'
   '/product-images/saree-blue-2.jpg'

2. Gallery Images in database:
   '/gallery-images/sarees-collection.jpg'

3. Logo in database:
   '/logo/sunlight-traders-logo.svg'

4. Videos in database:
   'https://yourdomain.com/videos/fashion-showcase.mp4'
   OR
   '/videos/fashion-showcase.mp4'

Supabase will automatically prepend the storage URL when you reference these paths.
Full URL will be: https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/product-images/saree-blue-1.jpg

*/

-- ============================================================================
-- STORAGE RECOMMENDATIONS
-- ============================================================================

/*

1. IMAGE OPTIMIZATION:
   - Product Images: Use 1000x1000px for product photos
   - Gallery Images: Use 1200x800px for gallery showcase
   - Logo: Use 400x400px for logo (SVG preferred)
   - Maximum file size: 5MB per image

2. NAMING CONVENTIONS:
   Product: [type]-[color]-[number].jpg
   Example: saree-blue-1.jpg, suit-green-2.jpg
   
   Gallery: [category]-[description].jpg
   Example: sarees-collection.jpg, lehengas-bridal.jpg

3. SUPPORTED FORMATS:
   - Images: JPG, PNG, WebP (WebP for smaller file sizes)
   - Videos: MP4, WebM
   - Documents: PDF

4. BACKUP STRATEGY:
   - Regularly backup product images
   - Keep original files locally
   - Use CDN for faster delivery (optional)

5. STORAGE LIMITS:
   - Supabase free tier: 1GB storage
   - If you exceed, upgrade plan
   - Monitor storage usage regularly

*/

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check all buckets created
-- SELECT id, name, public, created_at FROM storage.buckets;

-- Check bucket sizes
-- SELECT bucket_id, SUM(metadata->>'size')::bigint as total_size 
-- FROM storage.objects 
-- GROUP BY bucket_id;

-- Check object count per bucket
-- SELECT bucket_id, COUNT(*) as object_count 
-- FROM storage.objects 
-- GROUP BY bucket_id;

-- ============================================================================
-- COMMIT
-- ============================================================================

COMMIT;
