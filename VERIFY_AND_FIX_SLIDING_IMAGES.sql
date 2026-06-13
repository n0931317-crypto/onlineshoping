-- ============================================================
-- VERIFY & FIX SLIDING IMAGES TABLE
-- ============================================================
-- Run EACH section separately and check the results

-- SECTION 1: Check if table exists
-- Run this and look at the results
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE tablename = 'sliding_images';

-- Expected result: Shows the table and rowsecurity status
-- If empty: table doesn't exist, need to create it
-- If rowsecurity = true: RLS is ON, need to disable
-- If rowsecurity = false: RLS is OFF, should work

-- SECTION 2: If table doesn't exist OR has RLS issues, run this entire block:

-- Drop the old table completely
DROP TABLE IF EXISTS sliding_images CASCADE;

-- Create fresh table with NO RLS
CREATE TABLE public.sliding_images (
    id BIGSERIAL PRIMARY KEY,
    image_url TEXT NOT NULL,
    title TEXT,
    description TEXT,
    link_url TEXT,
    display_order SMALLINT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Make sure RLS is OFF
ALTER TABLE public.sliding_images DISABLE ROW LEVEL SECURITY;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_sliding_images_display_order ON public.sliding_images(display_order);
CREATE INDEX IF NOT EXISTS idx_sliding_images_is_active ON public.sliding_images(is_active);
CREATE INDEX IF NOT EXISTS idx_sliding_images_created_at ON public.sliding_images(created_at);

-- Add sample data
INSERT INTO public.sliding_images (image_url, title, description, display_order, is_active) 
VALUES 
    ('https://via.placeholder.com/1920x350?text=Slide+1', 'Discover Premium Fabrics', 'Explore our exclusive collection', 1, true),
    ('https://via.placeholder.com/1920x350?text=Slide+2', 'Latest Collections', 'Browse our new arrivals', 2, true);

-- SECTION 3: Verify it worked
-- Run this query to confirm table is ready
SELECT COUNT(*) as total_slides, 
       (SELECT rowsecurity FROM pg_tables WHERE tablename = 'sliding_images') as rls_enabled
FROM public.sliding_images;

-- Expected result: 
-- total_slides = 2
-- rls_enabled = false

-- If you see "rls_enabled = false", RLS is OFF and you can upload images!
