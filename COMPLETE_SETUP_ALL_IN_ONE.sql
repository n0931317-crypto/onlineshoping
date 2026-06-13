-- ============================================================
-- MASTER DATABASE & STORAGE SETUP - Nepo Online Stores
-- ============================================================
-- Run this entire script in the Supabase SQL Editor (https://app.supabase.com)
-- It will create all tables, indexes, triggers, functions, and Row Level Security (RLS) policies.

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. ADMIN USERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS admin_users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    name VARCHAR(255),
    role VARCHAR(50) DEFAULT 'admin',
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_admin_users_email ON admin_users(email);
CREATE INDEX IF NOT EXISTS idx_admin_users_is_active ON admin_users(is_active);

-- ============================================================
-- 2. SERVICES (COLLECTIONS) TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS services (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    image_url TEXT,
    duration_hours SMALLINT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_services_created_at ON services(created_at);
CREATE INDEX IF NOT EXISTS idx_services_is_active ON services(is_active);

-- ============================================================
-- 3. PRODUCTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity BIGINT DEFAULT 0,
    image_url TEXT,
    category TEXT,
    is_active BOOLEAN DEFAULT true,
    reviews_count INTEGER DEFAULT 0,
    average_rating DECIMAL(3, 2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_products_created_at ON products(created_at);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);

-- ============================================================
-- 4. PRODUCT IMAGES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS product_images (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    image_order SMALLINT DEFAULT 0,
    bucket_name VARCHAR(100),
    storage_path VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_product_images_product_id ON product_images(product_id);
CREATE INDEX IF NOT EXISTS idx_product_images_image_order ON product_images(image_order);

-- ============================================================
-- 5. REVIEWS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS reviews (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_title VARCHAR(255) NOT NULL,
    review_text TEXT NOT NULL,
    is_verified_purchase BOOLEAN DEFAULT false,
    helpful_count INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at ON reviews(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_status ON reviews(status);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON reviews(rating);

-- ============================================================
-- 6. REVIEW HELPFUL VOTES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS review_helpful_votes (
    id BIGSERIAL PRIMARY KEY,
    review_id BIGINT NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    voter_email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(review_id, voter_email)
);

CREATE INDEX IF NOT EXISTS idx_review_helpful_votes_review_id ON review_helpful_votes(review_id);
CREATE INDEX IF NOT EXISTS idx_review_helpful_votes_voter_email ON review_helpful_votes(voter_email);

-- ============================================================
-- 7. APPOINTMENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS appointments (
    id BIGSERIAL PRIMARY KEY,
    service_id BIGINT REFERENCES services(id),
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    appointment_notes TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_appointments_created_at ON appointments(created_at);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_appointments_service_id ON appointments(service_id);
CREATE INDEX IF NOT EXISTS idx_appointments_customer_email ON appointments(customer_email);

-- ============================================================
-- 8. GALLERY TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS gallery (
    id BIGSERIAL PRIMARY KEY,
    title TEXT,
    image_url TEXT NOT NULL,
    image_type VARCHAR(50) DEFAULT 'image',
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order BIGINT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gallery_created_at ON gallery(created_at);
CREATE INDEX IF NOT EXISTS idx_gallery_is_active ON gallery(is_active);
CREATE INDEX IF NOT EXISTS idx_gallery_display_order ON gallery(display_order);

-- ============================================================
-- 9. HOME VIDEO TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS home_video (
    id BIGSERIAL PRIMARY KEY,
    title TEXT,
    video_url TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_home_video_is_active ON home_video(is_active);

-- ============================================================
-- 10. PAYMENT CONFIGURATION TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS payment_configuration (
    id BIGSERIAL PRIMARY KEY,
    
    -- eSewa Configuration
    esewa_number TEXT,
    esewa_name TEXT,
    esewa_active BOOLEAN DEFAULT false,
    
    -- Khalti Configuration
    khalti_number TEXT,
    khalti_name TEXT,
    khalti_active BOOLEAN DEFAULT false,
    
    -- Bank Transfer Configuration
    bank_name TEXT,
    bank_account TEXT,
    bank_holder TEXT,
    bank_code TEXT,
    bank_active BOOLEAN DEFAULT false,
    
    -- General
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_payment_config_is_active ON payment_configuration(is_active);

-- ============================================================
-- 11. ORDERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    
    -- Customer Information
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    
    -- Delivery Address Information
    street_address TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    delivery_instructions TEXT,
    delivery_address TEXT, -- Combined address field
    delivery_date DATE,
    
    -- Transaction Information
    transaction_code TEXT,
    transaction_screenshot TEXT,
    transaction_notes TEXT,
    payment_method VARCHAR(50),
    
    -- Order Details
    subtotal DECIMAL(10, 2) DEFAULT 0,
    delivery_charge DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    status VARCHAR(30) DEFAULT 'pending_verification',
    order_notes TEXT,
    
    -- Admin Information
    confirmed_by_admin BOOLEAN DEFAULT false,
    admin_notes TEXT,
    confirmed_at TIMESTAMP WITH TIME ZONE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_customer_email ON orders(customer_email);
CREATE INDEX IF NOT EXISTS idx_orders_customer_phone ON orders(customer_phone);
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON orders(order_number);
CREATE INDEX IF NOT EXISTS idx_orders_confirmed_by_admin ON orders(confirmed_by_admin);

-- ============================================================
-- 12. ORDER ITEMS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES products(id),
    product_name TEXT NOT NULL,
    quantity BIGINT NOT NULL DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- ============================================================
-- 13. SETTINGS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS settings (
    id BIGSERIAL PRIMARY KEY,
    setting_key VARCHAR(255) UNIQUE NOT NULL,
    setting_value TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_settings_setting_key ON settings(setting_key);

-- ============================================================
-- 14. SLIDING IMAGES (HERO SLIDER) TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS sliding_images (
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

CREATE INDEX IF NOT EXISTS idx_sliding_images_display_order ON sliding_images(display_order);
CREATE INDEX IF NOT EXISTS idx_sliding_images_is_active ON sliding_images(is_active);

-- ============================================================
-- 15. CATEGORIES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_categories_name ON categories(name);
CREATE INDEX IF NOT EXISTS idx_categories_is_active ON categories(is_active);

-- ============================================================
-- 16. MESSAGES (CONTACT FORM) TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS messages (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    subject VARCHAR(255),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_messages_email ON messages(email);
CREATE INDEX IF NOT EXISTS idx_messages_is_read ON messages(is_read);

-- ============================================================
-- 17. OFFERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS offers (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5, 2) NOT NULL,
    discount_amount DECIMAL(10, 2),
    image_url TEXT,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_offers_is_active ON offers(is_active);
CREATE INDEX IF NOT EXISTS idx_offers_end_date ON offers(end_date);

-- ============================================================
-- 18. ADMIN SETTINGS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS admin_settings (
    id BIGSERIAL PRIMARY KEY,
    setting_key VARCHAR(255) UNIQUE NOT NULL,
    setting_value JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admin_settings_key ON admin_settings(setting_key);

-- ============================================================
-- 19. PAYMENT QR IMAGES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS payment_qr_images (
    id BIGSERIAL PRIMARY KEY,
    payment_method VARCHAR(50) NOT NULL UNIQUE,
    file_path TEXT NOT NULL, -- Stores base64 or public URLs
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payment_qr_method ON payment_qr_images(payment_method);

-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Function: Generate Unique Order Number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
BEGIN
    RETURN 'ORD-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS') || '-' || LPAD(FLOOR(RANDOM() * 9999)::TEXT, 4, '0');
END;
$$ LANGUAGE plpgsql;

-- Function: Update Timestamp Column
CREATE OR REPLACE FUNCTION trigger_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Update Order Status Helper
CREATE OR REPLACE FUNCTION update_order_status(
    p_order_id BIGINT,
    p_new_status VARCHAR,
    p_admin_notes TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE orders
    SET 
        status = p_new_status,
        admin_notes = COALESCE(p_admin_notes, admin_notes),
        confirmed_by_admin = true,
        confirmed_at = COALESCE(confirmed_at, CURRENT_TIMESTAMP),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_order_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Function: Update Product Reviews stats dynamically
CREATE OR REPLACE FUNCTION update_product_reviews_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products 
    SET 
        reviews_count = (
            SELECT COUNT(*) FROM reviews 
            WHERE product_id = NEW.product_id AND status = 'approved'
        ),
        average_rating = COALESCE((
            SELECT AVG(rating)::DECIMAL(3, 2) FROM reviews 
            WHERE product_id = NEW.product_id AND status = 'approved'
        ), 0)
    WHERE id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-set order number on creation
CREATE OR REPLACE FUNCTION trigger_set_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
        NEW.order_number := generate_order_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_set_order_number ON orders;
CREATE TRIGGER trg_set_order_number
BEFORE INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION trigger_set_order_number();

-- Update Timestamps Triggers
CREATE OR REPLACE PROCEDURE create_timestamp_trigger(table_name TEXT) AS $$
BEGIN
    EXECUTE format('DROP TRIGGER IF EXISTS trg_update_%I_timestamp ON %I', table_name, table_name);
    EXECUTE format('CREATE TRIGGER trg_update_%I_timestamp BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION trigger_update_timestamp()', table_name, table_name);
END;
$$ LANGUAGE plpgsql;

CALL create_timestamp_trigger('admin_users');
CALL create_timestamp_trigger('services');
CALL create_timestamp_trigger('products');
CALL create_timestamp_trigger('product_images');
CALL create_timestamp_trigger('reviews');
CALL create_timestamp_trigger('appointments');
CALL create_timestamp_trigger('gallery');
CALL create_timestamp_trigger('home_video');
CALL create_timestamp_trigger('payment_configuration');
CALL create_timestamp_trigger('orders');
CALL create_timestamp_trigger('order_items');
CALL create_timestamp_trigger('settings');
CALL create_timestamp_trigger('sliding_images');
CALL create_timestamp_trigger('categories');
CALL create_timestamp_trigger('offers');

DROP TRIGGER IF EXISTS trigger_update_product_reviews_stats ON reviews;
CREATE TRIGGER trigger_update_product_reviews_stats
    AFTER INSERT OR UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_product_reviews_stats();

-- ============================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_helpful_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery ENABLE ROW LEVEL SECURITY;
ALTER TABLE home_video ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_configuration ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE sliding_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_qr_images ENABLE ROW LEVEL SECURITY;

-- Setup Permissive RLS Policies for All Tables
-- (Ensures read access for website visitors and full CRUD operations for admin panel actions)

-- 1. admin_users
DROP POLICY IF EXISTS "allow_select" ON admin_users;
CREATE POLICY "allow_select" ON admin_users FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON admin_users;
CREATE POLICY "allow_all" ON admin_users FOR ALL USING (true);

-- 2. services
DROP POLICY IF EXISTS "allow_select" ON services;
CREATE POLICY "allow_select" ON services FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON services;
CREATE POLICY "allow_all" ON services FOR ALL USING (true);

-- 3. products
DROP POLICY IF EXISTS "allow_select" ON products;
CREATE POLICY "allow_select" ON products FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON products;
CREATE POLICY "allow_all" ON products FOR ALL USING (true);

-- 4. product_images
DROP POLICY IF EXISTS "allow_select" ON product_images;
CREATE POLICY "allow_select" ON product_images FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON product_images;
CREATE POLICY "allow_all" ON product_images FOR ALL USING (true);

-- 5. reviews
DROP POLICY IF EXISTS "allow_select" ON reviews;
CREATE POLICY "allow_select" ON reviews FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON reviews;
CREATE POLICY "allow_all" ON reviews FOR ALL USING (true);

-- 6. review_helpful_votes
DROP POLICY IF EXISTS "allow_select" ON review_helpful_votes;
CREATE POLICY "allow_select" ON review_helpful_votes FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON review_helpful_votes;
CREATE POLICY "allow_all" ON review_helpful_votes FOR ALL USING (true);

-- 7. appointments
DROP POLICY IF EXISTS "allow_select" ON appointments;
CREATE POLICY "allow_select" ON appointments FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON appointments;
CREATE POLICY "allow_all" ON appointments FOR ALL USING (true);

-- 8. gallery
DROP POLICY IF EXISTS "allow_select" ON gallery;
CREATE POLICY "allow_select" ON gallery FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON gallery;
CREATE POLICY "allow_all" ON gallery FOR ALL USING (true);

-- 9. home_video
DROP POLICY IF EXISTS "allow_select" ON home_video;
CREATE POLICY "allow_select" ON home_video FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON home_video;
CREATE POLICY "allow_all" ON home_video FOR ALL USING (true);

-- 10. payment_configuration
DROP POLICY IF EXISTS "allow_select" ON payment_configuration;
CREATE POLICY "allow_select" ON payment_configuration FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON payment_configuration;
CREATE POLICY "allow_all" ON payment_configuration FOR ALL USING (true);

-- 11. orders
DROP POLICY IF EXISTS "allow_select" ON orders;
CREATE POLICY "allow_select" ON orders FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON orders;
CREATE POLICY "allow_all" ON orders FOR ALL USING (true);

-- 12. order_items
DROP POLICY IF EXISTS "allow_select" ON order_items;
CREATE POLICY "allow_select" ON order_items FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON order_items;
CREATE POLICY "allow_all" ON order_items FOR ALL USING (true);

-- 13. settings
DROP POLICY IF EXISTS "allow_select" ON settings;
CREATE POLICY "allow_select" ON settings FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON settings;
CREATE POLICY "allow_all" ON settings FOR ALL USING (true);

-- 14. sliding_images
DROP POLICY IF EXISTS "allow_select" ON sliding_images;
CREATE POLICY "allow_select" ON sliding_images FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON sliding_images;
CREATE POLICY "allow_all" ON sliding_images FOR ALL USING (true);

-- 15. categories
DROP POLICY IF EXISTS "allow_select" ON categories;
CREATE POLICY "allow_select" ON categories FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON categories;
CREATE POLICY "allow_all" ON categories FOR ALL USING (true);

-- 16. messages
DROP POLICY IF EXISTS "allow_select" ON messages;
CREATE POLICY "allow_select" ON messages FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON messages;
CREATE POLICY "allow_all" ON messages FOR ALL USING (true);

-- 17. offers
DROP POLICY IF EXISTS "allow_select" ON offers;
CREATE POLICY "allow_select" ON offers FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON offers;
CREATE POLICY "allow_all" ON offers FOR ALL USING (true);

-- 18. admin_settings
DROP POLICY IF EXISTS "allow_select" ON admin_settings;
CREATE POLICY "allow_select" ON admin_settings FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON admin_settings;
CREATE POLICY "allow_all" ON admin_settings FOR ALL USING (true);

-- 19. payment_qr_images
DROP POLICY IF EXISTS "allow_select" ON payment_qr_images;
CREATE POLICY "allow_select" ON payment_qr_images FOR SELECT USING (true);
DROP POLICY IF EXISTS "allow_all" ON payment_qr_images;
CREATE POLICY "allow_all" ON payment_qr_images FOR ALL USING (true);

-- ============================================================
-- STORAGE POLICIES (Make Storage uploads accessible)
-- ============================================================
-- NOTE: Disabling storage RLS ensures seamless image/video uploads 
-- from both admin panel and checkout without credential blocks.
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- INSERT INITIAL SEED DATA
-- ============================================================

-- Default Admin User (Password is 'admin123')
INSERT INTO admin_users (email, password_hash, name, role)
VALUES ('admin@nepoonline.com', 'admin123', 'Super Admin', 'admin')
ON CONFLICT (email) DO NOTHING;

-- Initial Settings
INSERT INTO admin_settings (setting_key, setting_value) VALUES
('business_hours', '{"opening":"09:00","closing":"19:00"}'),
('contact_info', '{"phone":"033590207","email":"nepoonline0@gmail.com","address":"Mirchaiya Bazar, Sirha, Nepal"}'),
('admin_settings', '{"businessName":"Nepo Online Stores","instagramUrl":"https://www.instagram.com/nepoonline0/","facebookUrl":"https://www.facebook.com/profile.php?id=61580118031654"}'),
('payment_methods', '{"esewa":true,"khalti":true,"bank":true}')
ON CONFLICT (setting_key) DO NOTHING;

-- Sample Categories
INSERT INTO categories (name, description, image_url, is_active) VALUES 
('Sarees', 'Traditional and modern sarees for every occasion', 'https://via.placeholder.com/400x300?text=Sarees', true),
('Suits', 'Elegant suits and dress materials', 'https://via.placeholder.com/400x300?text=Suits', true),
('Fabrics', 'Premium quality fabrics for tailoring', 'https://via.placeholder.com/400x300?text=Fabrics', true),
('Accessories', 'Jewelry, scarves, and fashion accessories', 'https://via.placeholder.com/400x300?text=Accessories', true)
ON CONFLICT (name) DO NOTHING;

-- Sample Offers
INSERT INTO offers (title, description, discount_percentage, image_url, end_date, is_active, created_by) VALUES 
('Spring Sale', 'Get 20% off on all fabrics', 20.00, 'https://via.placeholder.com/400x300?text=Spring+Sale', NOW() + INTERVAL '30 days', true, 'admin'),
('New Year Special', '15% discount on selected products', 15.00, 'https://via.placeholder.com/400x300?text=New+Year+Special', NOW() + INTERVAL '7 days', true, 'admin')
ON CONFLICT DO NOTHING;

-- Sample Sliding Images
INSERT INTO sliding_images (image_url, title, description, display_order, is_active) VALUES 
('https://via.placeholder.com/1920x350?text=Slide+1', 'Discover Premium Fabrics', 'Explore our exclusive collection of traditional and modern styles', 1, true),
('https://via.placeholder.com/1920x350?text=Slide+2', 'Latest Collections', 'Browse our new arrivals and trending items', 2, true),
('https://via.placeholder.com/1920x350?text=Slide+3', 'Fashion Forward', 'Stay stylish with our premium selection', 3, true)
ON CONFLICT DO NOTHING;
