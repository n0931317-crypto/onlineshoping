-- ============================================================================
-- Nepo Online stores - COMPLETE ALL-IN-ONE SETUP SCRIPT
-- ============================================================================
-- Run this complete script in Supabase SQL Editor to set up everything
-- This includes: Tables, Functions, Triggers, RLS, Sample Data, and Storage
-- ============================================================================

-- ============================================================================
-- 1. CREATE ALL TABLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2),
    duration VARCHAR(50),
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    image_url VARCHAR(500),
    category VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product_images (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    display_order INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    shipping_address TEXT NOT NULL,
    shipping_city VARCHAR(100),
    shipping_state VARCHAR(100),
    shipping_zip VARCHAR(20),
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50) DEFAULT 'pending',
    order_status VARCHAR(50) DEFAULT 'pending',
    tracking_number VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reviews (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    customer_name VARCHAR(255) NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS appointments (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    service_id INT REFERENCES services(id),
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    requirements TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS gallery (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(500) NOT NULL,
    category VARCHAR(100),
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS home_video (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    video_url VARCHAR(500) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payment_configuration (
    id SERIAL PRIMARY KEY,
    payment_method VARCHAR(100) NOT NULL,
    is_enabled BOOLEAN DEFAULT true,
    api_key VARCHAR(500),
    secret_key VARCHAR(500),
    config_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(255) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 2. CREATE INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_services_active ON services(is_active);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_email ON orders(customer_email);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_reviews_product ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_gallery_category ON gallery(category);
CREATE INDEX IF NOT EXISTS idx_product_images_product ON product_images(product_id);

-- ============================================================================
-- 3. CREATE FUNCTIONS
-- ============================================================================

CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS VARCHAR AS $$
BEGIN
    RETURN 'ORD-' || TO_CHAR(NOW(), 'YYYY-MM-DD-HH24-MI-SS') || '-' || LPAD(NEXTVAL('orders_id_seq')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_order_status(p_order_id INT, p_status VARCHAR)
RETURNS VOID AS $$
BEGIN
    UPDATE orders SET order_status = p_status, updated_at = NOW() WHERE id = p_order_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_order_details(p_order_id INT)
RETURNS TABLE (
    order_id INT,
    order_number VARCHAR,
    customer_name VARCHAR,
    total_amount DECIMAL,
    order_status VARCHAR,
    item_count INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.id,
        o.order_number,
        o.customer_name,
        o.total_amount,
        o.order_status,
        COUNT(oi.id)::INT
    FROM orders o
    LEFT JOIN order_items oi ON o.id = oi.order_id
    WHERE o.id = p_order_id
    GROUP BY o.id, o.order_number, o.customer_name, o.total_amount, o.order_status;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 4. CREATE TRIGGERS
-- ============================================================================

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS products_update_timestamp ON products;
CREATE TRIGGER products_update_timestamp BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_timestamp();

DROP TRIGGER IF EXISTS services_update_timestamp ON services;
CREATE TRIGGER services_update_timestamp BEFORE UPDATE ON services FOR EACH ROW EXECUTE FUNCTION update_timestamp();

DROP TRIGGER IF EXISTS orders_update_timestamp ON orders;
CREATE TRIGGER orders_update_timestamp BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_timestamp();

DROP TRIGGER IF EXISTS reviews_update_timestamp ON reviews;
CREATE TRIGGER reviews_update_timestamp BEFORE UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- ============================================================================
-- 5. ENABLE RLS
-- ============================================================================

ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery ENABLE ROW LEVEL SECURITY;
ALTER TABLE home_video ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_configuration ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 6. CREATE RLS POLICIES
-- ============================================================================

-- Products Policies
DROP POLICY IF EXISTS "Products - Public Read" ON products;
CREATE POLICY "Products - Public Read" ON products FOR SELECT USING (true);

DROP POLICY IF EXISTS "Products - Authenticated Write" ON products;
CREATE POLICY "Products - Authenticated Write" ON products FOR INSERT WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Products - Authenticated Update" ON products;
CREATE POLICY "Products - Authenticated Update" ON products FOR UPDATE USING (auth.role() = 'authenticated');

-- Services Policies
DROP POLICY IF EXISTS "Services - Public Read" ON services;
CREATE POLICY "Services - Public Read" ON services FOR SELECT USING (is_active = true);

DROP POLICY IF EXISTS "Services - Authenticated Write" ON services;
CREATE POLICY "Services - Authenticated Write" ON services FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Product Images Policies
DROP POLICY IF EXISTS "Product Images - Public Read" ON product_images;
CREATE POLICY "Product Images - Public Read" ON product_images FOR SELECT USING (true);

-- Orders Policies
DROP POLICY IF EXISTS "Orders - User Read" ON orders;
CREATE POLICY "Orders - User Read" ON orders FOR SELECT USING (true);

DROP POLICY IF EXISTS "Orders - User Insert" ON orders;
CREATE POLICY "Orders - User Insert" ON orders FOR INSERT WITH CHECK (true);

-- Order Items Policies
DROP POLICY IF EXISTS "Order Items - Public Read" ON order_items;
CREATE POLICY "Order Items - Public Read" ON order_items FOR SELECT USING (true);

-- Reviews Policies
DROP POLICY IF EXISTS "Reviews - Public Read" ON reviews;
CREATE POLICY "Reviews - Public Read" ON reviews FOR SELECT USING (true);

DROP POLICY IF EXISTS "Reviews - User Insert" ON reviews;
CREATE POLICY "Reviews - User Insert" ON reviews FOR INSERT WITH CHECK (true);

-- Appointments Policies
DROP POLICY IF EXISTS "Appointments - Public Insert" ON appointments;
CREATE POLICY "Appointments - Public Insert" ON appointments FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Appointments - Authenticated Read" ON appointments;
CREATE POLICY "Appointments - Authenticated Read" ON appointments FOR SELECT USING (auth.role() = 'authenticated');

-- Gallery Policies
DROP POLICY IF EXISTS "Gallery - Public Read" ON gallery;
CREATE POLICY "Gallery - Public Read" ON gallery FOR SELECT USING (true);

-- Home Video Policies
DROP POLICY IF EXISTS "Home Video - Public Read" ON home_video;
CREATE POLICY "Home Video - Public Read" ON home_video FOR SELECT USING (true);

-- Payment Configuration Policies
DROP POLICY IF EXISTS "Payment Configuration - Authenticated" ON payment_configuration;
CREATE POLICY "Payment Configuration - Authenticated" ON payment_configuration FOR SELECT USING (auth.role() = 'authenticated');

-- Settings Policies
DROP POLICY IF EXISTS "Settings - Public Read" ON settings;
CREATE POLICY "Settings - Public Read" ON settings FOR SELECT USING (true);

-- ============================================================================
-- 7. INSERT DEFAULT DATA
-- ============================================================================

-- Admin User
INSERT INTO admin_users (email, password_hash, name, role, is_active)
VALUES ('admin@sunlighttradersco.in', '$2b$10$7K1SHh.P/UNEXgFiIHMMCOYUpU3pt7rWcWSCH.NU3zzavy2lK2dKm', 'Admin', 'admin', true)
ON CONFLICT (email) DO NOTHING;

-- Collections
INSERT INTO services (name, description, price, duration) VALUES
('Sarees', 'Traditional and modern sarees with beautiful designs and patterns', 2500, '2'),
('Ladies Suits', 'Designer ladies suits in various styles and fabrics', 3000, '2'),
('Lehengas', 'Elegant lehengas for weddings and special occasions', 4500, '3'),
('Boots & Shoes', 'Premium boots and footwear for all occasions', 2000, '1'),
('Readymade Clothes', 'High-quality readymade garments for everyday wear', 1500, '1')
ON CONFLICT DO NOTHING;

-- Products
INSERT INTO products (name, description, price, image_url, category) VALUES
('Cotton Saree - Blue', 'Beautiful blue cotton saree with floral patterns, perfect for daily wear', 2500, '/product-images/saree-blue.jpg', 'Sarees'),
('Silk Saree - Red', 'Stunning red silk saree ideal for special occasions and celebrations', 5000, '/product-images/saree-red.jpg', 'Sarees'),
('Designer Suit - Green', 'Modern designer suit in green color with embroidery work', 3500, '/product-images/suit-green.jpg', 'Ladies Suits'),
('Cotton Suit - Yellow', 'Comfortable cotton suit in bright yellow shade for casual wear', 2500, '/product-images/suit-yellow.jpg', 'Ladies Suits'),
('Bridal Lehenga - Gold', 'Exquisite gold bridal lehenga with intricate beadwork and sequins', 8000, '/product-images/lehenga-gold.jpg', 'Lehengas')
ON CONFLICT DO NOTHING;

-- Product Images
INSERT INTO product_images (product_id, image_url, display_order) VALUES
(1, '/product-images/saree-blue-1.jpg', 1),
(1, '/product-images/saree-blue-2.jpg', 2),
(2, '/product-images/saree-red-1.jpg', 1),
(3, '/product-images/suit-green-1.jpg', 1),
(4, '/product-images/suit-yellow-1.jpg', 1)
ON CONFLICT DO NOTHING;

-- Gallery
INSERT INTO gallery (title, description, image_url, category) VALUES
('Elegant Sarees Collection', 'Browse our collection of traditional and modern sarees', '/gallery-images/sarees-collection.jpg', 'Sarees'),
('Designer Suits', 'Latest designer suits for modern women', '/gallery-images/suits-collection.jpg', 'Ladies Suits'),
('Wedding Lehengas', 'Stunning bridal and wedding lehengas', '/gallery-images/lehengas-collection.jpg', 'Lehengas'),
('Footwear Collection', 'Premium boots and shoes for all occasions', '/gallery-images/boots-collection.jpg', 'Boots & Shoes'),
('Summer Collection', 'Comfortable readymade clothes for summer season', '/gallery-images/summer-readymade.jpg', 'Readymade Clothes')
ON CONFLICT DO NOTHING;

-- Reviews
INSERT INTO reviews (product_id, customer_name, rating, comment) VALUES
(1, 'Priya Sharma', 5, 'Beautiful saree! Great quality and fast delivery. Highly recommended!'),
(2, 'Anita Gupta', 5, 'Excellent silk saree. Perfect for my wedding. Thank you!'),
(3, 'Neha Patel', 4, 'Nice suit, good fit. Colors are as shown in pictures.'),
(4, 'Pooja Singh', 5, 'Amazing suit! Comfortable and stylish. Love the color!'),
(5, 'Rajni Kumar', 5, 'Absolutely stunning lehenga! Made me feel like a bride!')
ON CONFLICT DO NOTHING;

-- Payment Configuration
INSERT INTO payment_configuration (payment_method, is_enabled, api_key, secret_key) VALUES
('razorpay', true, 'your_razorpay_key_id', 'your_razorpay_secret'),
('upi', true, 'upi_configuration', 'upi_details'),
('bank_transfer', true, 'bank_account_details', 'bank_config'),
('cod', true, 'cash_on_delivery', 'enabled')
ON CONFLICT DO NOTHING;

-- Settings
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
('business_description', 'Nepo Online stores offers premium quality clothing and fashion items including sarees, ladies suits, lehengas, boots, shoes, and readymade clothes.')
ON CONFLICT (setting_key) DO NOTHING;

-- Home Video
INSERT INTO home_video (title, video_url, description) VALUES
('Nepo Online stores Fashion Showcase', 'https://www.youtube.com/embed/VIDEO_ID', 'Discover our latest collection of sarees, suits, and lehengas')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 8. STORAGE BUCKETS (Create these manually in Supabase UI)
-- ============================================================================

/*
CREATE THESE BUCKETS IN SUPABASE STORAGE UI:

1. product-images (PUBLIC)
2. gallery-images (PUBLIC)
3. logo (PUBLIC)
4. videos (PUBLIC)
5. admin-uploads (PRIVATE)
*/

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Uncomment to verify data was inserted:
-- SELECT COUNT(*) as admin_users FROM admin_users;
-- SELECT COUNT(*) as collections FROM services;
-- SELECT COUNT(*) as products FROM products;
-- SELECT COUNT(*) as reviews FROM reviews;
-- SELECT COUNT(*) as gallery FROM gallery;

COMMIT;

-- ============================================================================
-- SETUP COMPLETE!
-- ============================================================================
-- 
-- Your database is now ready. Follow these next steps:
-- 
-- 1. Create 5 Storage Buckets (in Supabase UI):
--    - product-images (Public)
--    - gallery-images (Public)
--    - logo (Public)
--    - videos (Public)
--    - admin-uploads (Private)
--
-- 2. Update your ANON_KEY in supabase-new.js
--
-- 3. Login to admin panel:
--    Email: admin@sunlighttradersco.in
--    Password: admin123
--
-- 4. Upload product images and test!
--
-- ============================================================================
