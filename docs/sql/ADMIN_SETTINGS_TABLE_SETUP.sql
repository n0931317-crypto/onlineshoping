-- ============================================================
-- ADMIN SETTINGS TABLE SETUP
-- ============================================================

-- Drop existing table to recreate it properly
DROP TABLE IF EXISTS admin_settings CASCADE;

-- Create admin_settings table
CREATE TABLE admin_settings (
    id BIGSERIAL PRIMARY KEY,
    setting_key VARCHAR(255) UNIQUE NOT NULL,
    setting_value TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_admin_settings_key ON admin_settings(setting_key);

-- Enable Row Level Security
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Everyone can view admin settings
CREATE POLICY "anyone_read_settings"
ON admin_settings
FOR SELECT
USING (true);

-- RLS Policy: Anyone can insert settings
CREATE POLICY "anyone_insert_settings"
ON admin_settings
FOR INSERT
WITH CHECK (true);

-- RLS Policy: Anyone can update settings
CREATE POLICY "anyone_update_settings"
ON admin_settings
FOR UPDATE
USING (true)
WITH CHECK (true);

-- RLS Policy: Anyone can delete settings
CREATE POLICY "anyone_delete_settings"
ON admin_settings
FOR DELETE
USING (true);

-- Insert sample settings
INSERT INTO admin_settings (setting_key, setting_value) VALUES
  ('business_hours', '{"opening":"09:00 AM","closing":"07:00 PM"}'),
  ('contact_info', '{"phone":"03359207","address":"Khaireni, Gulmi, Nepal","email":""}'),
  ('admin_settings', '{"business_name":"Nepo Online stores","admin_email":"diwashb32@gmail.com"}');

-- Verify the table
SELECT * FROM admin_settings;
