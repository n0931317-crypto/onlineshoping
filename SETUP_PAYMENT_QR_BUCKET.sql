-- ============================================================
-- CREATE PAYMENT METHODS BUCKET AND RLS POLICIES
-- ============================================================

-- NOTE: Storage buckets must be created via Supabase UI or SDK
-- This file contains SQL for the metadata table that tracks payment QR images

-- Drop old policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Anyone can view active payment QR images" ON public.payment_qr_images;
DROP POLICY IF EXISTS "Only authenticated users can insert payment QR images" ON public.payment_qr_images;
DROP POLICY IF EXISTS "Only authenticated users can update payment QR images" ON public.payment_qr_images;
DROP POLICY IF EXISTS "Only authenticated users can delete payment QR images" ON public.payment_qr_images;

-- Create metadata table for payment QR images
CREATE TABLE IF NOT EXISTS public.payment_qr_images (
    id BIGSERIAL PRIMARY KEY,
    payment_method VARCHAR(50) NOT NULL, -- 'esewa', 'khalti', 'bank'
    file_path TEXT NOT NULL,
    bucket_name TEXT DEFAULT 'payment-qr-images',
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    UNIQUE(payment_method) -- Only one QR per payment method
);

-- Create index
CREATE INDEX IF NOT EXISTS idx_payment_qr_method ON public.payment_qr_images(payment_method);
CREATE INDEX IF NOT EXISTS idx_payment_qr_active ON public.payment_qr_images(is_active);

-- Enable RLS
ALTER TABLE public.payment_qr_images ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- RLS POLICIES - ALLOW PUBLIC READ, AUTHENTICATED WRITE
-- ============================================================

-- Policy 1: Public can view ONLY active payment QR images
CREATE POLICY "Public can view active QR codes" 
    ON public.payment_qr_images 
    FOR SELECT 
    USING (is_active = true);

-- Policy 2: Authenticated users can select all records (for admin panel)
CREATE POLICY "Authenticated users can select all QR images" 
    ON public.payment_qr_images 
    FOR SELECT 
    USING (auth.role() = 'authenticated');

-- Policy 3: Authenticated users can insert payment QR images
CREATE POLICY "Authenticated users can insert QR images" 
    ON public.payment_qr_images 
    FOR INSERT 
    WITH CHECK (auth.role() = 'authenticated');

-- Policy 4: Authenticated users can update payment QR images
CREATE POLICY "Authenticated users can update QR images" 
    ON public.payment_qr_images 
    FOR UPDATE 
    USING (auth.role() = 'authenticated') 
    WITH CHECK (auth.role() = 'authenticated');

-- Policy 5: Authenticated users can delete payment QR images
CREATE POLICY "Authenticated users can delete QR images" 
    ON public.payment_qr_images 
    FOR DELETE 
    USING (auth.role() = 'authenticated');

-- ============================================================
-- INITIAL DATA
-- ============================================================

-- Create placeholder records if they don't exist
INSERT INTO public.payment_qr_images (payment_method, file_path, description, is_active) 
VALUES
    ('esewa', '', 'eSewa payment QR code', false),
    ('khalti', '', 'Khalti payment QR code', false),
    ('bank', '', 'Bank transfer details QR code', false)
ON CONFLICT (payment_method) DO UPDATE 
SET updated_at = NOW();

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Check table exists and show all records
SELECT 
    id,
    payment_method,
    file_path,
    is_active,
    created_at,
    updated_at
FROM public.payment_qr_images
ORDER BY payment_method;

-- Show RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'payment_qr_images';
