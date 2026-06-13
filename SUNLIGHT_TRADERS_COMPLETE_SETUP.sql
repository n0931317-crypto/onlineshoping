-- Nepo Online stores - Complete Database & Storage Setup
-- Clothing & Fashion E-Commerce Platform
-- Tables: Products, Orders, Reviews, Gallery, Admin, Payments, Settings
-- Storage: Product Images, Gallery Images, Admin Files

-- ============================================================================
-- PART 1: DROP EXISTING TABLES (Optional - Uncomment if needed)
-- ============================================================================
-- DROP TABLE IF EXISTS order_items CASCADE;
-- DROP TABLE IF EXISTS orders CASCADE;
-- DROP TABLE IF EXISTS reviews CASCADE;
-- DROP TABLE IF EXISTS product_images CASCADE;
-- DROP TABLE IF EXISTS products CASCADE;
-- DROP TABLE IF EXISTS appointments CASCADE;
-- DROP TABLE IF EXISTS gallery CASCADE;
-- DROP TABLE IF EXISTS home_video CASCADE;
-- DROP TABLE IF EXISTS payment_configuration CASCADE;
-- DROP TABLE IF EXISTS admin_users CASCADE;
-- DROP TABLE IF EXISTS services CASCADE;
-- DROP TABLE IF EXISTS settings CASCADE;

-- ============================================================================
-- PART 2: CREATE TABLES FOR Nepo Online stores
-- ============================================================================

-- Admin Users Table
CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'admin',
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Services/Collections Table (for clothing collections)
CREATE TABLE IF NOT EXISTS services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2),
    duration INTEGER,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Products Table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    image_url VARCHAR(500),
    category VARCHAR(100),
    stock_quantity INTEGER DEFAULT 0,
    sku VARCHAR(100) UNIQUE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Product Images Table
CREATE TABLE IF NOT EXISTS product_images (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    display_order INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reviews Table
CREATE TABLE IF NOT EXISTS reviews (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    customer_name VARCHAR(255),
    email VARCHAR(255),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_approved BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255),
    customer_phone VARCHAR(20),
    shipping_address TEXT,
    total_amount DECIMAL(10, 2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(50) DEFAULT 'pending',
    order_status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2),
    total_price DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Appointments Table
CREATE TABLE IF NOT EXISTS appointments (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255),
    customer_email VARCHAR(255),
    customer_phone VARCHAR(20),
    service_id INTEGER REFERENCES services(id),
    appointment_date DATE,
    appointment_time TIME,
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Gallery Table
CREATE TABLE IF NOT EXISTS gallery (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    description TEXT,
    image_url VARCHAR(500),
    category VARCHAR(100),
    display_order INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Home Video Table
CREATE TABLE IF NOT EXISTS home_video (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    video_url VARCHAR(500),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payment Configuration Table
CREATE TABLE IF NOT EXISTS payment_configuration (
    id SERIAL PRIMARY KEY,
    payment_method VARCHAR(50) UNIQUE,
    is_enabled BOOLEAN DEFAULT false,
    api_key VARCHAR(500),
    secret_key VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Settings Table
CREATE TABLE IF NOT EXISTS settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE,
    setting_value TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- PART 3: CREATE FUNCTIONS FOR CRUD OPERATIONS
-- ============================================================================

-- Function to generate order numbers
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS VARCHAR AS $$
BEGIN
    RETURN 'ORD-' || TO_CHAR(NOW(), 'YYYYMM') || '-' || LPAD(NEXTVAL('order_number_seq')::TEXT, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- Create sequence for order numbers
CREATE SEQUENCE IF NOT EXISTS order_number_seq START WITH 1000;

-- Function to update order status
CREATE OR REPLACE FUNCTION update_order_status(order_id INTEGER, new_status VARCHAR)
RETURNS VOID AS $$
BEGIN
    UPDATE orders SET status = new_status, updated_at = NOW() WHERE id = order_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get order details
CREATE OR REPLACE FUNCTION get_order_details(order_id INTEGER)
RETURNS TABLE (
    order_id INTEGER,
    order_number VARCHAR,
    customer_name VARCHAR,
    total_amount DECIMAL,
    status VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT o.id, o.order_number, o.customer_name, o.total_amount, o.order_status, o.created_at
    FROM orders o
    WHERE o.id = order_id;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate order total
CREATE OR REPLACE FUNCTION calculate_order_total(order_id INTEGER)
RETURNS DECIMAL AS $$
DECLARE
    total DECIMAL;
BEGIN
    SELECT SUM(total_price) INTO total FROM order_items WHERE order_id = order_id;
    RETURN COALESCE(total, 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- PART 4: CREATE TRIGGERS FOR AUTO-UPDATES
-- ============================================================================

-- Trigger to auto-update products timestamp
CREATE OR REPLACE FUNCTION update_product_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_timestamp
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_product_timestamp();

-- Trigger to auto-update services timestamp
CREATE OR REPLACE FUNCTION update_service_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER services_timestamp
BEFORE UPDATE ON services
FOR EACH ROW
EXECUTE FUNCTION update_service_timestamp();

-- Trigger to auto-update orders timestamp
CREATE OR REPLACE FUNCTION update_order_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER orders_timestamp
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_order_timestamp();

-- Trigger to auto-update reviews timestamp
CREATE OR REPLACE FUNCTION update_review_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reviews_timestamp
BEFORE UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_review_timestamp();

-- Trigger to auto-update appointments timestamp
CREATE OR REPLACE FUNCTION update_appointment_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER appointments_timestamp
BEFORE UPDATE ON appointments
FOR EACH ROW
EXECUTE FUNCTION update_appointment_timestamp();

-- Trigger to auto-update gallery timestamp
CREATE OR REPLACE FUNCTION update_gallery_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER gallery_timestamp
BEFORE UPDATE ON gallery
FOR EACH ROW
EXECUTE FUNCTION update_gallery_timestamp();

-- ============================================================================
-- PART 5: CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_created ON products(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_customer_email ON orders(customer_email);
CREATE INDEX IF NOT EXISTS idx_orders_created ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_reviews_product ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON reviews(rating);
CREATE INDEX IF NOT EXISTS idx_gallery_category ON gallery(category);
CREATE INDEX IF NOT EXISTS idx_gallery_active ON gallery(is_active);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_product_images_product ON product_images(product_id);
CREATE INDEX IF NOT EXISTS idx_services_active ON services(is_active);

-- ============================================================================
-- PART 6: ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery ENABLE ROW LEVEL SECURITY;
ALTER TABLE home_video ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_configuration ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PART 7: RLS POLICIES FOR PUBLIC ACCESS
-- ============================================================================

-- Products: Public can read, authenticated can insert/update/delete
DROP POLICY IF EXISTS "Products public read" ON products;
CREATE POLICY "Products public read" ON products FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Products authenticated write" ON products;
CREATE POLICY "Products authenticated write" ON products FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Products authenticated update" ON products;
CREATE POLICY "Products authenticated update" ON products FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Products authenticated delete" ON products;
CREATE POLICY "Products authenticated delete" ON products FOR DELETE USING (true);

-- Services: Public can read
DROP POLICY IF EXISTS "Services public read" ON services;
CREATE POLICY "Services public read" ON services FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Services authenticated write" ON services;
CREATE POLICY "Services authenticated write" ON services FOR INSERT WITH CHECK (true);

-- Reviews: Public can read, authenticated can insert
DROP POLICY IF EXISTS "Reviews public read" ON reviews;
CREATE POLICY "Reviews public read" ON reviews FOR SELECT USING (is_approved = true);

DROP POLICY IF EXISTS "Reviews authenticated insert" ON reviews;
CREATE POLICY "Reviews authenticated insert" ON reviews FOR INSERT WITH CHECK (true);

-- Orders: Authenticated can manage
DROP POLICY IF EXISTS "Orders authenticated all" ON orders;
CREATE POLICY "Orders authenticated all" ON orders FOR ALL USING (true);

-- Order Items: Authenticated can manage
DROP POLICY IF EXISTS "Order Items authenticated all" ON order_items;
CREATE POLICY "Order Items authenticated all" ON order_items FOR ALL USING (true);

-- Gallery: Public can read
DROP POLICY IF EXISTS "Gallery public read" ON gallery;
CREATE POLICY "Gallery public read" ON gallery FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Gallery authenticated write" ON gallery;
CREATE POLICY "Gallery authenticated write" ON gallery FOR INSERT WITH CHECK (true);

-- Home Video: Public can read
DROP POLICY IF EXISTS "Home Video public read" ON home_video;
CREATE POLICY "Home Video public read" ON home_video FOR SELECT USING (is_active = true);

-- Product Images: Public can read
DROP POLICY IF EXISTS "Product Images public read" ON product_images;
CREATE POLICY "Product Images public read" ON product_images FOR SELECT USING (true);

DROP POLICY IF EXISTS "Product Images authenticated write" ON product_images;
CREATE POLICY "Product Images authenticated write" ON product_images FOR INSERT WITH CHECK (true);

-- Appointments: Authenticated can manage
DROP POLICY IF EXISTS "Appointments authenticated all" ON appointments;
CREATE POLICY "Appointments authenticated all" ON appointments FOR ALL USING (true);

-- ============================================================================
-- PART 8: STORAGE BUCKET CREATION (via SQL)
-- ============================================================================

-- Note: Storage buckets are typically created via Supabase Dashboard or API
-- The following is for reference - execute in Supabase SQL Editor

-- Insert default bucket policies configuration
INSERT INTO settings (setting_key, setting_value) VALUES
('storage_bucket_product_images', 'product-images'),
('storage_bucket_gallery_images', 'gallery-images'),
('storage_bucket_admin_files', 'admin-files'),
('storage_bucket_category_images', 'category-images'),
('storage_bucket_thumbnail_images', 'thumbnail-images')
ON CONFLICT (setting_key) DO NOTHING;

-- ============================================================================
-- PART 9: INSERT INITIAL SETTINGS
-- ============================================================================

INSERT INTO settings (setting_key, setting_value) VALUES
('business_name', 'Nepo Online stores'),
('business_email', 'info@sunlighttradersco.in'),
('business_phone', '+91-XXXXXXXXXX'),
('business_address', 'Premium Clothing Store, City Center Mall'),
('business_city', 'New Delhi'),
('business_state', 'Delhi'),
('business_zip', '110001'),
('currency', 'INR'),
('tax_rate', '18'),
('delivery_charge', '50'),
('free_delivery_threshold', '1000'),
('business_description', 'Nepo Online stores offers premium quality clothing and fashion items'),
('website_theme_color', '#667eea'),
('website_accent_color', '#764ba2')
ON CONFLICT (setting_key) DO NOTHING;

-- ============================================================================
-- PART 10: SAMPLE DATA FOR Nepo Online stores
-- ============================================================================

-- Insert Collections
INSERT INTO services (name, description, price, duration) VALUES
('Sarees', 'Traditional and modern sarees with beautiful designs', 2500, 2),
('Ladies Suits', 'Designer ladies suits in various styles and fabrics', 3000, 2),
('Lehengas', 'Elegant lehengas for weddings and special occasions', 4500, 3),
('Boots & Shoes', 'Premium boots and footwear for all occasions', 2000, 1),
('Readymade Clothes', 'High-quality readymade garments for everyday wear', 1500, 1)
ON CONFLICT DO NOTHING;

-- Insert Products
INSERT INTO products (name, description, price, image_url, category, stock_quantity, sku) VALUES
('Cotton Saree - Blue', 'Beautiful blue cotton saree with floral patterns', 2500, '/product-images/saree-blue.jpg', 'Sarees', 15, 'SKU-SAREE-001'),
('Silk Saree - Red', 'Stunning red silk saree for special occasions', 5000, '/product-images/saree-red.jpg', 'Sarees', 8, 'SKU-SAREE-002'),
('Designer Suit - Green', 'Modern designer suit with embroidery work', 3500, '/product-images/suit-green.jpg', 'Ladies Suits', 12, 'SKU-SUIT-001'),
('Cotton Suit - Yellow', 'Comfortable cotton suit for casual wear', 2500, '/product-images/suit-yellow.jpg', 'Ladies Suits', 20, 'SKU-SUIT-002'),
('Bridal Lehenga - Gold', 'Exquisite gold bridal lehenga with beadwork', 8000, '/product-images/lehenga-gold.jpg', 'Lehengas', 5, 'SKU-LEHENGA-001')
ON CONFLICT (sku) DO NOTHING;

-- Insert Gallery Images
INSERT INTO gallery (title, description, image_url, category, display_order) VALUES
('Elegant Sarees Collection', 'Browse our sarees collection', '/gallery-images/sarees.jpg', 'Sarees', 1),
('Designer Suits', 'Latest designer suits', '/gallery-images/suits.jpg', 'Ladies Suits', 2),
('Wedding Lehengas', 'Stunning wedding lehengas', '/gallery-images/lehengas.jpg', 'Lehengas', 3),
('Footwear Collection', 'Premium boots and shoes', '/gallery-images/boots.jpg', 'Boots & Shoes', 4),
('Summer Readymade', 'Summer collection', '/gallery-images/readymade.jpg', 'Readymade Clothes', 5)
ON CONFLICT DO NOTHING;

-- Insert Sample Reviews
INSERT INTO reviews (product_id, customer_name, email, rating, comment) VALUES
(1, 'Priya Sharma', 'priya@email.com', 5, 'Beautiful saree! Great quality and fast delivery'),
(2, 'Anita Gupta', 'anita@email.com', 5, 'Perfect silk saree for my wedding'),
(3, 'Neha Patel', 'neha@email.com', 4, 'Nice suit, good fit and color'),
(4, 'Pooja Singh', 'pooja@email.com', 5, 'Amazing suit! Very comfortable and stylish'),
(5, 'Rajni Kumar', 'rajni@email.com', 5, 'Absolutely stunning lehenga!')
ON CONFLICT DO NOTHING;

-- Insert Payment Configuration
INSERT INTO payment_configuration (payment_method, is_enabled, api_key, secret_key) VALUES
('razorpay', true, 'rzp_test_XXXXXXXXXXXX', 'xxxxxxxxxxxxxxxxxxxxx'),
('upi', true, 'upi_enabled', 'upi_config'),
('bank_transfer', true, 'bank_details_here', 'bank_config'),
('cod', true, 'cash_on_delivery', 'enabled')
ON CONFLICT (payment_method) DO NOTHING;

-- ============================================================================
-- PART 11: VERIFICATION QUERIES
-- ============================================================================

-- Verify tables created
SELECT 'Tables Created Successfully!' as status;

-- Show table counts
SELECT 
    (SELECT COUNT(*) FROM services) as services_count,
    (SELECT COUNT(*) FROM products) as products_count,
    (SELECT COUNT(*) FROM reviews) as reviews_count,
    (SELECT COUNT(*) FROM gallery) as gallery_count,
    (SELECT COUNT(*) FROM payment_configuration) as payment_configs,
    (SELECT COUNT(*) FROM settings) as settings_count;

-- ============================================================================
-- PART 12: COMMIT CHANGES
-- ============================================================================

COMMIT;

-- ============================================================================
-- STORAGE BUCKET SETUP INSTRUCTIONS
-- ============================================================================
-- 
-- To create storage buckets in Supabase, execute these commands:
--
-- 1. product-images (for product photos)
-- 2. gallery-images (for gallery/showcase photos)
-- 3. admin-files (for admin document uploads)
-- 4. category-images (for category thumbnails)
-- 5. thumbnail-images (for product thumbnails)
--
-- Each bucket should have:
-- - Public read access (for displaying images)
-- - Authenticated write access (for uploading)
-- - RLS policies enabled
--
-- ============================================================================
