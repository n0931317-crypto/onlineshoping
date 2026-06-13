-- ============================================================
-- CREATE ADMIN_SETTINGS TABLE
-- ============================================================

-- Create the admin_settings table
CREATE TABLE IF NOT EXISTS public.admin_settings (
    id BIGSERIAL PRIMARY KEY,
    setting_key VARCHAR(255) UNIQUE NOT NULL,
    setting_value JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_admin_settings_key ON public.admin_settings(setting_key);

-- Enable RLS
ALTER TABLE public.admin_settings ENABLE ROW LEVEL SECURITY;

-- Create RLS policies - Allow authenticated admin users only
CREATE POLICY "Only authenticated users can view admin settings" 
    ON public.admin_settings 
    FOR SELECT 
    USING (auth.role() = 'authenticated');

CREATE POLICY "Only authenticated users can insert admin settings" 
    ON public.admin_settings 
    FOR INSERT 
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Only authenticated users can update admin settings" 
    ON public.admin_settings 
    FOR UPDATE 
    USING (auth.role() = 'authenticated') 
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Only authenticated users can delete admin settings" 
    ON public.admin_settings 
    FOR DELETE 
    USING (auth.role() = 'authenticated');

-- ============================================================
-- INSERT INITIAL SETTINGS
-- ============================================================

INSERT INTO public.admin_settings (setting_key, setting_value) VALUES
('business_hours', '{"opening":"09:00","closing":"19:00"}'),
('contact_info', '{"phone":"033590207","email":"contact@example.com","address":"Khaireni, Gulmi, Nepal"}'),
('admin_settings', '{"businessName":"Nepo Online stores & Cosmetic Center","instagramUrl":"","facebookUrl":""}'),
('payment_methods', '{"esewa":true,"khalti":true,"bank":true}')
ON CONFLICT (setting_key) DO NOTHING;

-- ============================================================
-- VERIFY TABLE CREATION
-- ============================================================

-- Check if table exists and has data
SELECT 
    setting_key,
    setting_value,
    updated_at
FROM public.admin_settings
ORDER BY updated_at DESC;

-- Verify RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'admin_settings';

-- Show policies
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename = 'admin_settings';
