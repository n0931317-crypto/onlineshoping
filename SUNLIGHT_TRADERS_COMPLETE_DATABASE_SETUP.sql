-- ============================================================================
-- Nepo Online stores - Complete Database & Storage Setup
-- ============================================================================
-- This SQL script sets up the complete database for Nepo Online stores
-- Clothing & Fashion E-commerce Platform
-- ============================================================================

-- ============================================================================
-- 1. CREATE TABLES
-- ============================================================================

-- Admin Users Table
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

-- Collections Table (renamed from services)
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

-- Products Table
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

-- Product Images Table (for carousel)
CREATE TABLE IF NOT EXISTS product_images (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    display_order INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
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

-- Order Items Table
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

-- Reviews Table
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

-- Appointments Table
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

-- Gallery Table
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

-- Home Video Table
CREATE TABLE IF NOT EXISTS home_video (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    video_url VARCHAR(500) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment Configuration Table
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

-- Settings Table
CREATE TABLE IF NOT EXISTS settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(255) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 2. CREATE INDEXES FOR PERFORMANCE
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

-- Function to generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS VARCHAR AS $$
BEGIN
    RETURN 'ORD-' || TO_CHAR(NOW(), 'YYYY-MM-DD-HH24-MI-SS') || '-' || LPAD(NEXTVAL('orders_id_seq')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

-- Function to update order status
CREATE OR REPLACE FUNCTION update_order_status(p_order_id INT, p_status VARCHAR)
RETURNS VOID AS $$
BEGIN
    UPDATE orders SET order_status = p_status, updated_at = NOW() WHERE id = p_order_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get order details with items
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
-- 4. CREATE TRIGGERS FOR AUTO-UPDATE
-- ============================================================================

-- Update products timestamp
CREATE OR REPLACE FUNCTION update_products_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_update_timestamp
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_products_timestamp();

-- Update services timestamp
CREATE OR REPLACE FUNCTION update_services_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER services_update_timestamp
BEFORE UPDATE ON services
FOR EACH ROW
EXECUTE FUNCTION update_services_timestamp();

-- Update orders timestamp
CREATE OR REPLACE FUNCTION update_orders_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER orders_update_timestamp
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_orders_timestamp();

-- Update reviews timestamp
CREATE OR REPLACE FUNCTION update_reviews_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reviews_update_timestamp
BEFORE UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_reviews_timestamp();

-- ============================================================================
-- 5. ENABLE ROW LEVEL SECURITY (RLS)
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

-- Products: Public can read, only authenticated users can create/update
CREATE POLICY "Products - Public Read" ON products
FOR SELECT USING (true);

CREATE POLICY "Products - Authenticated Write" ON products
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Products - Authenticated Update" ON products
FOR UPDATE USING (auth.role() = 'authenticated');

-- Services: Public can read
CREATE POLICY "Services - Public Read" ON services
FOR SELECT USING (is_active = true);

CREATE POLICY "Services - Authenticated Write" ON services
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Product Images: Public can read
CREATE POLICY "Product Images - Public Read" ON product_images
FOR SELECT USING (true);

-- Orders: Users can read their own orders
CREATE POLICY "Orders - User Read" ON orders
FOR SELECT USING (true);

CREATE POLICY "Orders - User Insert" ON orders
FOR INSERT WITH CHECK (true);

-- Order Items: Users can read their items
CREATE POLICY "Order Items - Public Read" ON order_items
FOR SELECT USING (true);

-- Reviews: Public can read
CREATE POLICY "Reviews - Public Read" ON reviews
FOR SELECT USING (true);

CREATE POLICY "Reviews - User Insert" ON reviews
FOR INSERT WITH CHECK (true);

-- Appointments: Public can create
CREATE POLICY "Appointments - Public Insert" ON appointments
FOR INSERT WITH CHECK (true);

CREATE POLICY "Appointments - Authenticated Read" ON appointments
FOR SELECT USING (auth.role() = 'authenticated');

-- Gallery: Public can read
CREATE POLICY "Gallery - Public Read" ON gallery
FOR SELECT USING (true);

-- Home Video: Public can read
CREATE POLICY "Home Video - Public Read" ON home_video
FOR SELECT USING (true);

-- Payment Configuration: Authenticated only
CREATE POLICY "Payment Configuration - Authenticated" ON payment_configuration
FOR SELECT USING (auth.role() = 'authenticated');

-- Settings: Public can read
CREATE POLICY "Settings - Public Read" ON settings
FOR SELECT USING (true);

-- ============================================================================
-- 7. INSERT DEFAULT DATA
-- ============================================================================

-- Insert default admin user (Email: admin@sunlighttradersco.in, Password: admin123)
INSERT INTO admin_users (email, password_hash, name, role, is_active)
VALUES ('admin@sunlighttradersco.in', '$2b$10$7K1SHh.P/UNEXgFiIHMMCOYUpU3pt7rWcWSCH.NU3zzavy2lK2dKm', 'Admin', 'admin', true)
ON CONFLICT (email) DO NOTHING;

-- Insert default settings
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

-- Insert payment methods
INSERT INTO payment_configuration (payment_method, is_enabled, api_key, secret_key) VALUES
('razorpay', true, 'your_razorpay_key_id', 'your_razorpay_secret'),
('upi', true, 'upi_configuration', 'upi_details'),
('bank_transfer', true, 'bank_account_details', 'bank_config'),
('cod', true, 'cash_on_delivery', 'enabled')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 8. COMMIT TRANSACTION
-- ============================================================================

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES (Run these to verify setup is complete)
-- ============================================================================

-- SELECT 'admin_users' as table_name, COUNT(*) as count FROM admin_users
-- UNION ALL
-- SELECT 'services', COUNT(*) FROM services
-- UNION ALL
-- SELECT 'products', COUNT(*) FROM products
-- UNION ALL
-- SELECT 'orders', COUNT(*) FROM orders
-- UNION ALL
-- SELECT 'reviews', COUNT(*) FROM reviews
-- UNION ALL
-- SELECT 'gallery', COUNT(*) FROM gallery;
