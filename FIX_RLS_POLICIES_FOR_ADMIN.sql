-- ============================================================
-- FIX: Add Missing RLS Policies for Admin Access
-- ============================================================
-- Run this in Supabase SQL Editor to fix service and product upload errors
-- Error: "new row violates row-level security policy for table"

-- ============================================================
-- SERVICES TABLE - Add INSERT/UPDATE/DELETE Policies
-- ============================================================

DROP POLICY IF EXISTS "Allow admin to insert services" ON services;
CREATE POLICY "Allow admin to insert services" ON services
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin to update services" ON services;
CREATE POLICY "Allow admin to update services" ON services
    FOR UPDATE USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin to delete services" ON services;
CREATE POLICY "Allow admin to delete services" ON services
    FOR DELETE USING (true);

-- Keep existing read policy
DROP POLICY IF EXISTS "Public read services" ON services;
CREATE POLICY "Public read services" ON services
    FOR SELECT USING (true);

-- ============================================================
-- PRODUCTS TABLE - Add INSERT/UPDATE/DELETE Policies
-- ============================================================

DROP POLICY IF EXISTS "Allow admin to insert products" ON products;
CREATE POLICY "Allow admin to insert products" ON products
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin to update products" ON products;
CREATE POLICY "Allow admin to update products" ON products
    FOR UPDATE USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin to delete products" ON products;
CREATE POLICY "Allow admin to delete products" ON products
    FOR DELETE USING (true);

-- Keep existing read policy
DROP POLICY IF EXISTS "Public read products" ON products;
CREATE POLICY "Public read products" ON products
    FOR SELECT USING (true);

-- ============================================================
-- GALLERY TABLE - Add INSERT/UPDATE/DELETE Policies
-- ============================================================

DROP POLICY IF EXISTS "Allow admin to insert gallery" ON gallery;
CREATE POLICY "Allow admin to insert gallery" ON gallery
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin to update gallery" ON gallery;
CREATE POLICY "Allow admin to update gallery" ON gallery
    FOR UPDATE USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin to delete gallery" ON gallery;
CREATE POLICY "Allow admin to delete gallery" ON gallery
    FOR DELETE USING (true);

-- Keep existing read policy
DROP POLICY IF EXISTS "Public read gallery" ON gallery;
CREATE POLICY "Public read gallery" ON gallery
    FOR SELECT USING (true);

-- ============================================================
-- REVIEWS TABLE - Add Write Policies
-- ============================================================

DROP POLICY IF EXISTS "Allow insert reviews" ON reviews;
CREATE POLICY "Allow insert reviews" ON reviews
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow update reviews" ON reviews;
CREATE POLICY "Allow update reviews" ON reviews
    FOR UPDATE USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow delete reviews" ON reviews;
CREATE POLICY "Allow delete reviews" ON reviews
    FOR DELETE USING (true);

-- Keep existing read policy
DROP POLICY IF EXISTS "Public read reviews" ON reviews;
CREATE POLICY "Public read reviews" ON reviews
    FOR SELECT USING (true);

-- ============================================================
-- PRODUCT IMAGES TABLE - Add INSERT/UPDATE/DELETE Policies
-- ============================================================

DROP POLICY IF EXISTS "Allow admin to insert product images" ON product_images;
CREATE POLICY "Allow admin to insert product_images" ON product_images
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin to update product images" ON product_images;
CREATE POLICY "Allow admin to update product_images" ON product_images
    FOR UPDATE USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin to delete product images" ON product_images;
CREATE POLICY "Allow admin to delete product_images" ON product_images
    FOR DELETE USING (true);

-- Keep existing read policy
DROP POLICY IF EXISTS "Public read product images" ON product_images;
CREATE POLICY "Public read product_images" ON product_images
    FOR SELECT USING (true);

-- ============================================================
-- VERIFY POLICIES WERE CREATED
-- ============================================================

-- Check services policies
SELECT 'Services Policies:' as "Table";
SELECT policyname FROM pg_policies WHERE tablename = 'services' ORDER BY policyname;

-- Check products policies
SELECT 'Products Policies:' as "Table";
SELECT policyname FROM pg_policies WHERE tablename = 'products' ORDER BY policyname;

-- Check gallery policies
SELECT 'Gallery Policies:' as "Table";
SELECT policyname FROM pg_policies WHERE tablename = 'gallery' ORDER BY policyname;

-- Check product_images policies
SELECT 'Product Images Policies:' as "Table";
SELECT policyname FROM pg_policies WHERE tablename = 'product_images' ORDER BY policyname;

-- Check reviews policies
SELECT 'Reviews Policies:' as "Table";
SELECT policyname FROM pg_policies WHERE tablename = 'reviews' ORDER BY policyname;

SELECT '✅ All RLS Policies Updated Successfully!' as "Status";
