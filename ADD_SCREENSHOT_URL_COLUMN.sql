-- Add screenshot_url column to orders table
ALTER TABLE orders
ADD COLUMN screenshot_url TEXT;

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_orders_screenshot ON orders(screenshot_url);
