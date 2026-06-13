-- ============================================================
-- QUICK REFERENCE - Common SQL Operations
-- ============================================================
-- Use these queries for common tasks after setup

-- ============================================================
-- PRODUCTS - Management
-- ============================================================

-- Add a new product
INSERT INTO products (name, description, price, stock_quantity, category, is_active)
VALUES (
    'Product Name',
    'Product description',
    1999.99,
    50,
    'Category Name',
    true
)
RETURNING id, name, created_at;

-- Update product
UPDATE products 
SET name = 'Updated Name', 
    price = 2499.99,
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1;

-- Deactivate product
UPDATE products SET is_active = false WHERE id = 1;

-- Get all active products with reviews
SELECT 
    p.id, p.name, p.price, 
    p.reviews_count, 
    p.average_rating,
    p.stock_quantity
FROM products p
WHERE p.is_active = true
ORDER BY p.created_at DESC;

-- Get product with all images
SELECT 
    p.id, p.name, p.price,
    ARRAY_AGG(
        JSON_BUILD_OBJECT(
            'image_url', pi.image_url,
            'image_order', pi.image_order
        ) ORDER BY pi.image_order
    ) as images
FROM products p
LEFT JOIN product_images pi ON p.id = pi.product_id
WHERE p.id = 1
GROUP BY p.id, p.name, p.price;

-- Delete product (cascade deletes images, reviews, order items)
DELETE FROM products WHERE id = 1;

-- ============================================================
-- PRODUCT IMAGES - Management
-- ============================================================

-- Add product images
INSERT INTO product_images (product_id, image_url, image_order, bucket_name)
VALUES 
(1, 'https://bucket.supabase.co/storage/v1/object/public/product-images-slot-1/image1.jpg', 1, 'product-images-slot-1'),
(1, 'https://bucket.supabase.co/storage/v1/object/public/product-images-slot-2/image2.jpg', 2, 'product-images-slot-2'),
(1, 'https://bucket.supabase.co/storage/v1/object/public/product-images-slot-3/image3.jpg', 3, 'product-images-slot-3'),
(1, 'https://bucket.supabase.co/storage/v1/object/public/product-images-slot-4/image4.jpg', 4, 'product-images-slot-4');

-- Get all images for a product
SELECT * FROM product_images 
WHERE product_id = 1 
ORDER BY image_order;

-- Update product image
UPDATE product_images 
SET image_url = 'https://new-url.jpg'
WHERE product_id = 1 AND image_order = 1;

-- Delete product image
DELETE FROM product_images 
WHERE product_id = 1 AND image_order = 1;

-- ============================================================
-- REVIEWS - Management
-- ============================================================

-- Insert new review
INSERT INTO reviews (product_id, customer_name, customer_email, rating, review_title, review_text, status, is_verified_purchase)
VALUES (
    1,
    'Customer Name',
    'customer@example.com',
    5,
    'Excellent Product!',
    'This product is amazing and exceeded my expectations.',
    'pending',
    false
)
RETURNING id, created_at;

-- Get all reviews for a product
SELECT 
    id, customer_name, rating, review_title, review_text,
    helpful_count, status, created_at
FROM reviews
WHERE product_id = 1 AND status = 'approved'
ORDER BY helpful_count DESC, created_at DESC;

-- Approve review
UPDATE reviews SET status = 'approved' WHERE id = 1;

-- Reject review
UPDATE reviews SET status = 'rejected' WHERE id = 1;

-- Get pending reviews (for admin)
SELECT 
    r.id, r.product_id, p.name as product_name,
    r.customer_name, r.rating, r.review_title,
    r.created_at
FROM reviews r
JOIN products p ON r.product_id = p.id
WHERE r.status = 'pending'
ORDER BY r.created_at;

-- Delete review
DELETE FROM reviews WHERE id = 1;

-- ============================================================
-- REVIEW HELPFUL VOTES - Management
-- ============================================================

-- Add helpful vote
INSERT INTO review_helpful_votes (review_id, voter_email)
VALUES (1, 'voter@example.com')
ON CONFLICT DO NOTHING;

-- Get helpful votes count for a review
SELECT COUNT(*) as helpful_count FROM review_helpful_votes WHERE review_id = 1;

-- Check if user already voted
SELECT * FROM review_helpful_votes WHERE review_id = 1 AND voter_email = 'voter@example.com';

-- ============================================================
-- SERVICES - Management
-- ============================================================

-- Add new service
INSERT INTO services (title, description, price, duration_hours, is_active)
VALUES (
    'Service Name',
    'Service description',
    500.00,
    1,
    true
)
RETURNING id, title, created_at;

-- Get all active services
SELECT id, title, description, price, duration_hours
FROM services
WHERE is_active = true
ORDER BY created_at DESC;

-- Update service
UPDATE services 
SET title = 'Updated Title', price = 750.00
WHERE id = 1;

-- Deactivate service
UPDATE services SET is_active = false WHERE id = 1;

-- ============================================================
-- APPOINTMENTS - Management
-- ============================================================

-- Book new appointment
INSERT INTO appointments (service_id, customer_name, customer_email, customer_phone, appointment_date, appointment_time, appointment_notes)
VALUES (
    1,
    'Customer Name',
    'customer@example.com',
    '9841234567',
    '2024-01-20',
    '14:30:00',
    'Special requirements here'
)
RETURNING id, appointment_date, appointment_time;

-- Get all appointments for a date
SELECT 
    a.id, a.customer_name, a.customer_phone,
    s.title as service_name,
    a.appointment_time, a.status
FROM appointments a
LEFT JOIN services s ON a.service_id = s.id
WHERE a.appointment_date = '2024-01-20'
ORDER BY a.appointment_time;

-- Get pending appointments
SELECT 
    a.id, a.customer_name, a.customer_email,
    s.title as service_name,
    a.appointment_date, a.appointment_time
FROM appointments a
LEFT JOIN services s ON a.service_id = s.id
WHERE a.status = 'pending'
ORDER BY a.appointment_date, a.appointment_time;

-- Confirm appointment
UPDATE appointments SET status = 'confirmed' WHERE id = 1;

-- Get appointments by email
SELECT * FROM appointments 
WHERE customer_email = 'customer@example.com'
ORDER BY appointment_date DESC;

-- ============================================================
-- ORDERS - Management
-- ============================================================

-- Get all pending orders (for admin)
SELECT 
    id, order_number, customer_name, customer_email,
    customer_phone, total_amount, status,
    created_at
FROM orders
WHERE status = 'pending_verification'
ORDER BY created_at DESC;

-- Get order with all details
SELECT 
    o.id, o.order_number, o.customer_name, o.customer_email,
    o.customer_phone, o.total_amount, o.status,
    o.created_at, o.street_address, o.city,
    COUNT(oi.id) as item_count
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.id = 1
GROUP BY o.id;

-- Get order items
SELECT 
    product_name, quantity, price, 
    (quantity * price) as subtotal
FROM order_items
WHERE order_id = 1;

-- Confirm order
SELECT update_order_status(1, 'confirmed', 'Order confirmed by admin');

-- Ship order
SELECT update_order_status(1, 'shipped', 'Order dispatched');

-- Deliver order
SELECT update_order_status(1, 'delivered', 'Order delivered successfully');

-- Cancel order
SELECT update_order_status(1, 'cancelled', 'Order cancelled by customer');

-- Get order by customer phone (for tracking)
SELECT 
    id, order_number, status, total_amount, created_at
FROM orders
WHERE customer_phone = '9841234567'
ORDER BY created_at DESC;

-- Get order by customer email
SELECT 
    id, order_number, status, total_amount, created_at
FROM orders
WHERE customer_email = 'customer@example.com'
ORDER BY created_at DESC;

-- Get order statistics
SELECT 
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as average_order_value,
    COUNT(CASE WHEN status = 'pending_verification' THEN 1 END) as pending,
    COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as confirmed,
    COUNT(CASE WHEN status = 'shipped' THEN 1 END) as shipped,
    COUNT(CASE WHEN status = 'delivered' THEN 1 END) as delivered,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled
FROM orders;

-- Get orders by status
SELECT 
    status,
    COUNT(*) as count,
    SUM(total_amount) as total_amount
FROM orders
GROUP BY status
ORDER BY count DESC;

-- Get orders in date range
SELECT 
    order_number, customer_name, total_amount, status, created_at
FROM orders
WHERE created_at BETWEEN '2024-01-01' AND '2024-01-31'
ORDER BY created_at DESC;

-- ============================================================
-- ORDER ITEMS - Management
-- ============================================================

-- Add item to order
INSERT INTO order_items (order_id, product_id, product_name, quantity, price)
VALUES (1, 1, 'Product Name', 2, 999.99);

-- Get items with product details
SELECT 
    oi.product_name,
    oi.quantity,
    oi.price,
    (oi.quantity * oi.price) as subtotal
FROM order_items oi
WHERE oi.order_id = 1;

-- ============================================================
-- GALLERY - Management
-- ============================================================

-- Add gallery image
INSERT INTO gallery (title, image_url, image_type, description, display_order, is_active)
VALUES (
    'Gallery Title',
    'https://bucket.supabase.co/storage/v1/object/public/gallery-images/image.jpg',
    'image',
    'Image description',
    1,
    true
)
RETURNING id, title;

-- Get all gallery images
SELECT id, title, image_url, display_order
FROM gallery
WHERE is_active = true
ORDER BY display_order;

-- Update gallery image order
UPDATE gallery SET display_order = 2 WHERE id = 1;

-- Delete gallery image
DELETE FROM gallery WHERE id = 1;

-- ============================================================
-- HOME VIDEO - Management
-- ============================================================

-- Add home video
INSERT INTO home_video (title, video_url, description, is_active)
VALUES (
    'Video Title',
    'https://youtube.com/embed/VIDEO_ID',
    'Video description',
    true
)
RETURNING id, title;

-- Get active home video
SELECT * FROM home_video WHERE is_active = true;

-- Update home video
UPDATE home_video 
SET video_url = 'https://youtube.com/embed/NEW_ID',
    is_active = true
WHERE id = 1;

-- ============================================================
-- PAYMENT CONFIGURATION - Management
-- ============================================================

-- Get payment configuration
SELECT * FROM payment_configuration WHERE is_active = true;

-- Update payment config
UPDATE payment_configuration
SET 
    esewa_number = '033590207',
    esewa_name = 'Sunlights',
    esewa_active = true,
    khalti_number = '033590207',
    khalti_name = 'Sunlights',
    khalti_active = true
WHERE id = 1;

-- Disable payment method
UPDATE payment_configuration 
SET esewa_active = false 
WHERE id = 1;

-- ============================================================
-- ADMIN USERS - Management
-- ============================================================

-- Add admin user
INSERT INTO admin_users (email, password_hash, name, role, is_active)
VALUES (
    'admin@example.com',
    'HASHED_PASSWORD_HERE',
    'Admin Name',
    'admin',
    true
);

-- Get all admin users
SELECT id, email, name, role, is_active FROM admin_users;

-- Deactivate admin
UPDATE admin_users SET is_active = false WHERE email = 'admin@example.com';

-- Update last login
UPDATE admin_users SET last_login = CURRENT_TIMESTAMP WHERE email = 'admin@example.com';

-- ============================================================
-- SETTINGS - Management
-- ============================================================

-- Add setting
INSERT INTO settings (setting_key, setting_value, description, is_active)
VALUES (
    'site_title',
    'Sunlights',
    'Website title',
    true
);

-- Get setting value
SELECT setting_value FROM settings WHERE setting_key = 'site_title';

-- Update setting
UPDATE settings SET setting_value = 'New Value' WHERE setting_key = 'site_title';

-- Get all active settings
SELECT setting_key, setting_value FROM settings WHERE is_active = true;

-- ============================================================
-- ANALYTICS & REPORTING
-- ============================================================

-- Get total revenue by month
SELECT 
    DATE_TRUNC('month', created_at)::date as month,
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as average_order
FROM orders
WHERE status IN ('delivered', 'shipped')
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month DESC;

-- Get top products by sales
SELECT 
    p.name,
    COUNT(oi.id) as times_sold,
    SUM(oi.quantity) as total_quantity,
    SUM(oi.quantity * oi.price) as total_revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status IN ('delivered', 'shipped')
GROUP BY p.id, p.name
ORDER BY total_revenue DESC
LIMIT 10;

-- Get best rated products
SELECT 
    id, name, average_rating, reviews_count
FROM products
WHERE reviews_count > 0 AND average_rating > 0
ORDER BY average_rating DESC, reviews_count DESC;

-- Get sales by payment method
SELECT 
    payment_method,
    COUNT(*) as count,
    SUM(total_amount) as total
FROM orders
WHERE status IN ('delivered', 'shipped')
GROUP BY payment_method
ORDER BY total DESC;

-- Get customer statistics
SELECT 
    COUNT(DISTINCT customer_email) as unique_customers,
    COUNT(*) as total_orders,
    AVG(total_amount) as avg_order_value,
    MAX(total_amount) as highest_order
FROM orders;

-- Get repeat customers
SELECT 
    customer_email,
    customer_name,
    COUNT(*) as order_count,
    SUM(total_amount) as total_spent,
    MAX(created_at) as last_order_date
FROM orders
WHERE status IN ('delivered', 'shipped')
GROUP BY customer_email, customer_name
HAVING COUNT(*) > 1
ORDER BY total_spent DESC;

-- ============================================================
-- MAINTENANCE
-- ============================================================

-- Rebuild indexes
REINDEX TABLE products;
REINDEX TABLE orders;
REINDEX TABLE reviews;

-- Get table sizes
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Get row counts for all tables
SELECT 
    tablename,
    n_live_tup as row_count
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY n_live_tup DESC;

-- Vacuum table (optimize storage)
VACUUM ANALYZE products;
VACUUM ANALYZE orders;

-- ============================================================
-- END OF QUICK REFERENCE
-- ============================================================
