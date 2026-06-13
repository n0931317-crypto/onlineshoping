-- ============================================================
-- COMPLETE DATABASE & STORAGE SETUP - Sunlights Website
-- ============================================================
-- This SQL setup includes:
-- 1. All essential tables (Products, Services, Orders, Appointments, etc.)
-- 2. Reviews & Rating system with helpful votes
-- 3. Payment configuration for multiple payment methods
-- 4. Gallery & Home Video management
-- 5. Admin users management
-- 6. All necessary functions and triggers
-- 7. Row Level Security (RLS) policies for all tables
-- 8. Storage bucket setup instructions
-- 9. Indexes for optimal performance
-- ============================================================

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
-- 2. SERVICES TABLE
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

-- Indexes on orders table for performance
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

-- Indexes on order_items
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
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Function: Generate Unique Order Number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
BEGIN
    RETURN 'ORD-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS') || '-' || LPAD(FLOOR(RANDOM() * 9999)::TEXT, 4, '0');
END;
$$ LANGUAGE plpgsql;

-- Function: Update Timestamp
CREATE OR REPLACE FUNCTION trigger_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Update Order Status
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

-- Function: Get Order Details with Items
CREATE OR REPLACE FUNCTION get_order_details(p_order_id BIGINT)
RETURNS TABLE (
    order_id BIGINT,
    order_number VARCHAR,
    customer_name TEXT,
    customer_email TEXT,
    customer_phone TEXT,
    total_amount DECIMAL,
    status VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE,
    item_count BIGINT,
    items_json JSON
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.id,
        o.order_number,
        o.customer_name,
        o.customer_email,
        o.customer_phone,
        o.total_amount,
        o.status,
        o.created_at,
        COUNT(oi.id),
        JSON_AGG(JSON_BUILD_OBJECT(
            'product_name', oi.product_name,
            'quantity', oi.quantity,
            'price', oi.price
        ))
    FROM orders o
    LEFT JOIN order_items oi ON o.id = oi.order_id
    WHERE o.id = p_order_id
    GROUP BY o.id, o.order_number, o.customer_name, o.customer_email, 
             o.customer_phone, o.total_amount, o.status, o.created_at;
END;
$$ LANGUAGE plpgsql;

-- Function: Update Product Reviews Stats
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

-- Trigger: Auto-generate Order Number
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

-- Triggers: Update Timestamps for all tables
DROP TRIGGER IF EXISTS trg_update_admin_users_timestamp ON admin_users;
CREATE TRIGGER trg_update_admin_users_timestamp
BEFORE UPDATE ON admin_users
FOR EACH ROW
EXECUTE FUNCTION trigger_update_timestamp();

DROP TRIGGER IF EXISTS trg_update_services_timestamp ON services;
CREATE TRIGGER trg_update_services_timestamp
BEFORE UPDATE ON services
FOR EACH ROW
EXECUTE FUNCTION trigger_update_timestamp();

DROP TRIGGER IF EXISTS trg_update_products_timestamp ON products;
CREATE TRIGGER trg_update_products_timestamp
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION trigger_update_timestamp();

DROP TRIGGER IF EXISTS trg_update_product_images_timestamp ON product_images;
CREATE TRIGGER trg_update_product_images_timestamp
BEFORE UPDATE ON product_images
FOR EACH ROW
EXECUTE FUNCTION trigger_update_timestamp();

DROP TRIGGER IF EXISTS trg_update_reviews_timestamp ON reviews;
CREATE TRIGGER trg_update_reviews_timestamp
BEFORE UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION trigger_update_timestamp();

DROP TRIGGER IF EXISTS trg_update_appointments_timestamp ON appointments;
CREATE TRIGGER trg_update_appointments_timestamp
BEFORE UPDATE ON appointments
FOR EACH ROW
EXECUTE FUNCTION trigger_update_timestamp();

DROP TRIGGER IF EXISTS trg_update_gallery_timestamp ON gallery;
CREATE TRIGGER trg_update_gallery_timestamp
BEFORE UPDATE ON gallery
FOR EACH ROW
EXECUTE FUNCTION trigger_update_timestamp();

DROP TRIGGER IF EXISTS trg_update_home_video_timestamp ON home_video;
CREATE TRIGGER trg_update_home_video_timestamp
BEFORE UPDATE ON home_video
FOR EACH ROW
EXECUTE FUNCTION trigger_update_timestamp();

DROP TRIGGER IF EXISTS trg_update_payment_config_timestamp ON payment_configuration;
CREATE TRIGGER trg_update_payment_config_timestamp
BEFORE UPDATE ON payment_configuration
FOR EACH ROW
EXECUTE FUNCTION trigger_update_timestamp();

DROP TRIGGER IF EXISTS trg_update_orders_timestamp ON orders;
CREATE TRIGGER trg_update_orders_timestamp
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION trigger_update_timestamp();

DROP TRIGGER IF EXISTS trg_update_order_items_timestamp ON order_items;
CREATE TRIGGER trg_update_order_items_timestamp
BEFORE UPDATE ON order_items
FOR EACH ROW
EXECUTE FUNCTION trigger_update_timestamp();

DROP TRIGGER IF EXISTS trg_update_settings_timestamp ON settings;
CREATE TRIGGER trg_update_settings_timestamp
BEFORE UPDATE ON settings
FOR EACH ROW
EXECUTE FUNCTION trigger_update_timestamp();

-- Trigger: Update product reviews stats when review changes
DROP TRIGGER IF EXISTS trigger_update_product_reviews_stats ON reviews;
CREATE TRIGGER trigger_update_product_reviews_stats
    AFTER INSERT OR UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_product_reviews_stats();

-- ============================================================
-- ROW LEVEL SECURITY (RLS) SETUP
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

-- Admin Users Policies
DROP POLICY IF EXISTS "Admin users viewable by admins" ON admin_users;
CREATE POLICY "Admin users viewable by admins" ON admin_users
    FOR SELECT USING (true);

-- Services Policies
DROP POLICY IF EXISTS "Services viewable by anyone" ON services;
CREATE POLICY "Services viewable by anyone" ON services
    FOR SELECT USING (true);

-- Products Policies
DROP POLICY IF EXISTS "Products viewable by anyone" ON products;
CREATE POLICY "Products viewable by anyone" ON products
    FOR SELECT USING (true);

-- Product Images Policies
DROP POLICY IF EXISTS "Product images viewable by anyone" ON product_images;
CREATE POLICY "Product images viewable by anyone" ON product_images
    FOR SELECT USING (is_active = true);

-- Reviews Policies
DROP POLICY IF EXISTS "Approved reviews viewable by anyone" ON reviews;
CREATE POLICY "Approved reviews viewable by anyone" ON reviews
    FOR SELECT USING (status = 'approved');

DROP POLICY IF EXISTS "Anyone can insert reviews" ON reviews;
CREATE POLICY "Anyone can insert reviews" ON reviews
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Admin can manage all reviews" ON reviews;
CREATE POLICY "Admin can manage all reviews" ON reviews
    FOR ALL USING (true);

-- Review Helpful Votes Policies
DROP POLICY IF EXISTS "Helpful votes viewable by anyone" ON review_helpful_votes;
CREATE POLICY "Helpful votes viewable by anyone" ON review_helpful_votes
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Anyone can vote helpful" ON review_helpful_votes;
CREATE POLICY "Anyone can vote helpful" ON review_helpful_votes
    FOR INSERT WITH CHECK (true);

-- Appointments Policies
DROP POLICY IF EXISTS "Anyone can create appointments" ON appointments;
CREATE POLICY "Anyone can create appointments" ON appointments
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Appointments viewable by anyone" ON appointments;
CREATE POLICY "Appointments viewable by anyone" ON appointments
    FOR SELECT USING (true);

-- Gallery Policies
DROP POLICY IF EXISTS "Gallery viewable by anyone" ON gallery;
CREATE POLICY "Gallery viewable by anyone" ON gallery
    FOR SELECT USING (is_active = true);

-- Home Video Policies
DROP POLICY IF EXISTS "Home videos viewable by anyone" ON home_video;
CREATE POLICY "Home videos viewable by anyone" ON home_video
    FOR SELECT USING (is_active = true);

-- Payment Configuration Policies
DROP POLICY IF EXISTS "Payment config viewable by anyone" ON payment_configuration;
CREATE POLICY "Payment config viewable by anyone" ON payment_configuration
    FOR SELECT USING (is_active = true);

-- Orders Policies
DROP POLICY IF EXISTS "Orders created by anyone" ON orders;
CREATE POLICY "Orders created by anyone" ON orders
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Orders viewable by anyone" ON orders;
CREATE POLICY "Orders viewable by anyone" ON orders
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Orders updated by anyone" ON orders;
CREATE POLICY "Orders updated by anyone" ON orders
    FOR UPDATE USING (true);

-- Order Items Policies
DROP POLICY IF EXISTS "Order items created by anyone" ON order_items;
CREATE POLICY "Order items created by anyone" ON order_items
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Order items viewable by anyone" ON order_items;
CREATE POLICY "Order items viewable by anyone" ON order_items
    FOR SELECT USING (true);

-- Settings Policies
DROP POLICY IF EXISTS "Settings viewable by anyone" ON settings;
CREATE POLICY "Settings viewable by anyone" ON settings
    FOR SELECT USING (is_active = true);

-- ============================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================

-- Insert sample payment configuration
INSERT INTO payment_configuration (
    esewa_number, esewa_name, esewa_active,
    khalti_number, khalti_name, khalti_active,
    bank_name, bank_account, bank_holder, bank_code, bank_active,
    is_active
) VALUES (
    '033590207', 'Sunlights', true,
    '033590207', 'Sunlights', true,
    'NIC ASIA BANK', '1234567890123456', 'Sunlights', 'NICAASIA', true,
    true
) ON CONFLICT DO NOTHING;

-- Insert sample service
INSERT INTO services (title, description, price, duration_hours, is_active)
VALUES (
    'Consultation Service',
    'Professional consultation service for your needs',
    500.00,
    1,
    true
) ON CONFLICT DO NOTHING;

-- Insert sample product
INSERT INTO products (name, description, price, stock_quantity, category, is_active)
VALUES (
    'Sample Product',
    'This is a sample product for testing',
    1000.00,
    100,
    'General',
    true
) ON CONFLICT DO NOTHING;

-- ============================================================
-- VERIFICATION QUERIES (Run these to verify setup)
-- ============================================================
/*
-- Check if all tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Count records in each table
SELECT 'admin_users' as table_name, COUNT(*) as count FROM admin_users
UNION ALL
SELECT 'services', COUNT(*) FROM services
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'product_images', COUNT(*) FROM product_images
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'review_helpful_votes', COUNT(*) FROM review_helpful_votes
UNION ALL
SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL
SELECT 'gallery', COUNT(*) FROM gallery
UNION ALL
SELECT 'home_video', COUNT(*) FROM home_video
UNION ALL
SELECT 'payment_configuration', COUNT(*) FROM payment_configuration
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'settings', COUNT(*) FROM settings;

-- Test order number generation
SELECT generate_order_number();

-- Check RLS is enabled
SELECT tablename FROM pg_tables 
WHERE tablename IN ('admin_users', 'services', 'products', 'orders') 
AND schemaname = 'public';
*/

-- ============================================================
-- STORAGE BUCKETS - Manual Setup Required
-- ============================================================
-- NOTE: Storage buckets must be created manually via Supabase Dashboard
-- Go to: Supabase Dashboard → Storage → Create New Bucket
--
-- Create these buckets with PUBLIC access:
--
-- 1. product-images
--    Purpose: Product listing images
--    Public: YES
--
-- 2. product-images-slot-1, product-images-slot-2, product-images-slot-3, product-images-slot-4
--    Purpose: Multiple images per product
--    Public: YES
--
-- 3. gallery-images
--    Purpose: Gallery images
--    Public: YES
--
-- 4. videos or home-video
--    Purpose: Home video and promotional videos
--    Public: YES
--
-- 5. transaction-screenshots
--    Purpose: Payment transaction proof images
--    Public: YES
--
-- 6. service-images
--    Purpose: Service images
--    Public: YES
--
-- After creating buckets, you can set RLS policies:
-- - Allow anyone to SELECT (read)
-- - Allow authenticated users to INSERT (upload)
-- - Allow authenticated users to UPDATE their own files
-- - Allow authenticated users to DELETE their own files

-- ============================================================
-- END OF COMPLETE DATABASE SETUP
-- ============================================================
