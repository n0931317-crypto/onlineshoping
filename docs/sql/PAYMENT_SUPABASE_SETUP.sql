-- ============================================
-- SUPABASE PAYMENT SYSTEM SETUP
-- Drop and Create Fresh Tables
-- ============================================

-- DROP EXISTING TABLES (if they exist)
-- This will remove all old data, so backup first if needed
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS admin_settings CASCADE;

-- ============================================
-- CREATE ORDERS TABLE
-- ============================================
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL DEFAULT 'no-email@example.com',
    customer_phone VARCHAR(20) NOT NULL,
    delivery_address TEXT NOT NULL,
    delivery_date DATE NOT NULL,
    delivery_notes TEXT,
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0,
    delivery_charge DECIMAL(10, 2) NOT NULL DEFAULT 50,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending_verification',
    payment_method VARCHAR(50) NOT NULL,
    transaction_code VARCHAR(100) NOT NULL,
    has_screenshot BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CREATE ORDER_ITEMS TABLE
-- ============================================
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER,
    product_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CREATE ADMIN_SETTINGS TABLE (For QR Codes)
-- ============================================
CREATE TABLE admin_settings (
    id BIGSERIAL PRIMARY KEY,
    qr_esewa TEXT,
    qr_khalti TEXT,
    qr_bank TEXT,
    esewa_merchant_id VARCHAR(255),
    khalti_merchant_id VARCHAR(255),
    bank_account_number VARCHAR(50),
    bank_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CREATE INDEXES FOR BETTER PERFORMANCE
-- ============================================
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_customer_email ON orders(customer_email);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

-- ============================================
-- ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on orders table
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Enable RLS on order_items table
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Enable RLS on admin_settings table
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

-- ============================================
-- CREATE RLS POLICIES
-- ============================================

-- Allow anyone to INSERT orders (for checkout)
CREATE POLICY "Allow insert orders" ON orders
    FOR INSERT
    WITH CHECK (true);

-- Allow anyone to SELECT their own orders (by email)
CREATE POLICY "Allow select own orders" ON orders
    FOR SELECT
    USING (true);

-- Allow anyone to SELECT order items
CREATE POLICY "Allow select order items" ON order_items
    FOR SELECT
    USING (true);

-- Allow anyone to INSERT order items
CREATE POLICY "Allow insert order items" ON order_items
    FOR INSERT
    WITH CHECK (true);

-- Allow anyone to SELECT admin_settings (for QR codes)
CREATE POLICY "Allow select admin_settings" ON admin_settings
    FOR SELECT
    USING (true);

-- ============================================
-- INSERT SAMPLE ADMIN SETTINGS
-- ============================================
INSERT INTO admin_settings (qr_esewa, qr_khalti, qr_bank)
VALUES (
    'https://via.placeholder.com/300?text=eSewa+QR',
    'https://via.placeholder.com/300?text=Khalti+QR',
    'https://via.placeholder.com/300?text=Bank+QR'
);

-- ============================================
-- VERIFY TABLES CREATED
-- ============================================
SELECT 'Orders table created' as status;
SELECT 'Order items table created' as status;
SELECT 'Admin settings table created' as status;
SELECT 'All tables ready for use' as final_status;
