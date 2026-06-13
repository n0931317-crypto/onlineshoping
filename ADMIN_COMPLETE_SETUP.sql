-- ============================================
-- COMPLETE SUPABASE SETUP FOR ADMIN PANEL
-- Admin Status Update + Full Functionality
-- ============================================

-- ============================================
-- DROP EXISTING TABLES (Fresh Start)
-- ============================================
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
    admin_notes TEXT,
    confirmed_by_admin BOOLEAN DEFAULT FALSE,
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
-- CREATE ADMIN_SETTINGS TABLE
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
    delivery_charge DECIMAL(10, 2) DEFAULT 50,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_customer_email ON orders(customer_email);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

-- ============================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS POLICIES - ORDERS TABLE
-- ============================================

-- Policy 1: Allow public INSERT (for checkout)
CREATE POLICY "Allow insert orders" ON orders
    FOR INSERT
    WITH CHECK (true);

-- Policy 2: Allow public SELECT (for viewing orders)
CREATE POLICY "Allow select orders" ON orders
    FOR SELECT
    USING (true);

-- Policy 3: Allow UPDATE orders (for admin status updates)
CREATE POLICY "Allow update orders" ON orders
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Policy 4: Allow DELETE orders (for admin cleanup)
CREATE POLICY "Allow delete orders" ON orders
    FOR DELETE
    USING (true);

-- ============================================
-- RLS POLICIES - ORDER_ITEMS TABLE
-- ============================================

-- Policy 1: Allow public INSERT (for order items)
CREATE POLICY "Allow insert order items" ON order_items
    FOR INSERT
    WITH CHECK (true);

-- Policy 2: Allow public SELECT (for viewing items)
CREATE POLICY "Allow select order items" ON order_items
    FOR SELECT
    USING (true);

-- Policy 3: Allow UPDATE order items
CREATE POLICY "Allow update order items" ON order_items
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Policy 4: Allow DELETE order items
CREATE POLICY "Allow delete order items" ON order_items
    FOR DELETE
    USING (true);

-- ============================================
-- RLS POLICIES - ADMIN_SETTINGS TABLE
-- ============================================

-- Policy 1: Allow public SELECT (for QR codes on payment page)
CREATE POLICY "Allow select admin settings" ON admin_settings
    FOR SELECT
    USING (true);

-- Policy 2: Allow INSERT admin settings
CREATE POLICY "Allow insert admin settings" ON admin_settings
    FOR INSERT
    WITH CHECK (true);

-- Policy 3: Allow UPDATE admin settings (for admin panel)
CREATE POLICY "Allow update admin settings" ON admin_settings
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- ============================================
-- INSERT SAMPLE ADMIN SETTINGS
-- ============================================
INSERT INTO admin_settings (qr_esewa, qr_khalti, qr_bank, delivery_charge)
VALUES (
    'https://via.placeholder.com/300?text=eSewa+QR',
    'https://via.placeholder.com/300?text=Khalti+QR',
    'https://via.placeholder.com/300?text=Bank+QR',
    50
)
ON CONFLICT DO NOTHING;

-- ============================================
-- VERIFICATION
-- ============================================
-- Check if tables exist
SELECT 
    tablename,
    'Table created' as status
FROM pg_tables
WHERE tablename IN ('orders', 'order_items', 'admin_settings')
ORDER BY tablename;

-- Check policies
SELECT 
    schemaname,
    tablename,
    policyname,
    'Policy active' as status
FROM pg_policies
WHERE tablename IN ('orders', 'order_items', 'admin_settings')
ORDER BY tablename, policyname;
