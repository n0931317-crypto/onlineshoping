-- Nepo Online stores - Complete CRUD Operations Guide
-- For Clothing & Fashion E-Commerce Platform

-- ============================================================================
-- SECTION 1: PRODUCTS CRUD OPERATIONS
-- ============================================================================

-- CREATE: Add a new product
INSERT INTO products (name, description, price, image_url, category, stock_quantity, sku, is_active)
VALUES (
    'Premium Silk Saree - Green',
    'Luxurious green silk saree with gold embroidery work, perfect for weddings and celebrations',
    6500,
    '/product-images/saree-green.jpg',
    'Sarees',
    10,
    'SKU-SAREE-003',
    true
);

-- READ: Get all active products
SELECT id, name, description, price, category, stock_quantity, created_at
FROM products
WHERE is_active = true
ORDER BY created_at DESC;

-- READ: Get products by category
SELECT id, name, price, stock_quantity
FROM products
WHERE category = 'Sarees' AND is_active = true;

-- READ: Get product by ID
SELECT * FROM products WHERE id = 1;

-- READ: Get low stock products (less than 5 items)
SELECT id, name, stock_quantity, price
FROM products
WHERE stock_quantity < 5 AND is_active = true;

-- UPDATE: Update product details
UPDATE products
SET 
    name = 'Premium Silk Saree - Green with Gold',
    description = 'Updated description with more details',
    price = 6800,
    stock_quantity = 12
WHERE id = 3;

-- UPDATE: Disable a product
UPDATE products
SET is_active = false
WHERE id = 2;

-- UPDATE: Add stock quantity
UPDATE products
SET stock_quantity = stock_quantity + 5
WHERE id = 1;

-- DELETE: Delete a product (soft delete - set as inactive)
UPDATE products SET is_active = false WHERE id = 5;

-- DELETE: Hard delete (use with caution)
DELETE FROM products WHERE id = 5;

-- ============================================================================
-- SECTION 2: SERVICES/COLLECTIONS CRUD OPERATIONS
-- ============================================================================

-- CREATE: Add a new collection
INSERT INTO services (name, description, price, duration, is_active)
VALUES (
    'Designer Bridal Collection',
    'Exclusive bridal lehengas and sarees for your special day',
    15000,
    4,
    true
);

-- READ: Get all active services
SELECT id, name, description, price, duration
FROM services
WHERE is_active = true;

-- READ: Get service by ID
SELECT * FROM services WHERE id = 1;

-- UPDATE: Update service details
UPDATE services
SET 
    description = 'Updated collection description',
    price = 3500
WHERE id = 2;

-- UPDATE: Activate/Deactivate service
UPDATE services SET is_active = false WHERE id = 3;

-- DELETE: Soft delete service
UPDATE services SET is_active = false WHERE id = 4;

-- ============================================================================
-- SECTION 3: ORDERS CRUD OPERATIONS
-- ============================================================================

-- CREATE: Add a new order
INSERT INTO orders (order_number, customer_name, customer_email, customer_phone, shipping_address, total_amount, payment_method, order_status)
VALUES (
    'ORD-202501-001',
    'Rajesh Kumar',
    'rajesh@email.com',
    '+91-9876543210',
    '123 Fashion Street, New Delhi, 110001',
    5500,
    'razorpay',
    'pending'
);

-- CREATE: Add order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price)
VALUES 
(1, 1, 2, 2500, 5000),
(1, 3, 1, 3500, 3500);

-- READ: Get all orders
SELECT id, order_number, customer_name, total_amount, order_status, created_at
FROM orders
ORDER BY created_at DESC;

-- READ: Get order details
SELECT 
    o.id,
    o.order_number,
    o.customer_name,
    o.customer_email,
    o.customer_phone,
    o.total_amount,
    o.order_status,
    COUNT(oi.id) as item_count
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.id = 1
GROUP BY o.id;

-- READ: Get orders by status
SELECT id, order_number, customer_name, total_amount, created_at
FROM orders
WHERE order_status = 'pending'
ORDER BY created_at DESC;

-- READ: Get orders by customer email
SELECT id, order_number, total_amount, order_status
FROM orders
WHERE customer_email = 'rajesh@email.com';

-- READ: Get order items
SELECT 
    oi.id,
    p.name,
    oi.quantity,
    oi.unit_price,
    oi.total_price
FROM order_items oi
JOIN products p ON oi.product_id = p.id
WHERE oi.order_id = 1;

-- UPDATE: Update order status
UPDATE orders
SET order_status = 'confirmed'
WHERE id = 1;

-- UPDATE: Mark as shipped
UPDATE orders
SET order_status = 'shipped'
WHERE id = 1;

-- UPDATE: Mark as delivered
UPDATE orders
SET order_status = 'delivered'
WHERE id = 1;

-- DELETE: Cancel order (soft delete)
UPDATE orders
SET order_status = 'cancelled'
WHERE id = 1;

-- ============================================================================
-- SECTION 4: REVIEWS CRUD OPERATIONS
-- ============================================================================

-- CREATE: Add a new review
INSERT INTO reviews (product_id, customer_name, email, rating, comment, is_approved)
VALUES (
    1,
    'Sneha Verma',
    'sneha@email.com',
    5,
    'Excellent quality saree! Delivery was fast and packaging was perfect. Highly recommended!',
    true
);

-- READ: Get all approved reviews
SELECT id, product_id, customer_name, rating, comment, created_at
FROM reviews
WHERE is_approved = true
ORDER BY created_at DESC;

-- READ: Get reviews for a specific product
SELECT id, customer_name, rating, comment, created_at
FROM reviews
WHERE product_id = 1 AND is_approved = true
ORDER BY created_at DESC;

-- READ: Get average rating for a product
SELECT 
    product_id,
    ROUND(AVG(rating), 2) as average_rating,
    COUNT(*) as total_reviews,
    SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) as five_star,
    SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) as four_star,
    SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) as three_star,
    SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) as two_star,
    SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) as one_star
FROM reviews
WHERE product_id = 1 AND is_approved = true
GROUP BY product_id;

-- READ: Get pending reviews (for moderation)
SELECT id, product_id, customer_name, rating, comment, created_at
FROM reviews
WHERE is_approved = false
ORDER BY created_at ASC;

-- UPDATE: Approve a review
UPDATE reviews
SET is_approved = true
WHERE id = 3;

-- UPDATE: Reject a review
UPDATE reviews
SET is_approved = false
WHERE id = 4;

-- DELETE: Delete a review
DELETE FROM reviews WHERE id = 5;

-- ============================================================================
-- SECTION 5: GALLERY CRUD OPERATIONS
-- ============================================================================

-- CREATE: Add gallery image
INSERT INTO gallery (title, description, image_url, category, display_order, is_active)
VALUES (
    'New Year Fashion Collection',
    'Latest designs for the new year celebrations',
    '/gallery-images/newyear-collection.jpg',
    'Sarees',
    1,
    true
);

-- READ: Get all active gallery images
SELECT id, title, category, display_order, created_at
FROM gallery
WHERE is_active = true
ORDER BY category, display_order ASC;

-- READ: Get gallery images by category
SELECT id, title, image_url, display_order
FROM gallery
WHERE category = 'Sarees' AND is_active = true
ORDER BY display_order;

-- UPDATE: Update gallery image
UPDATE gallery
SET 
    title = 'Updated Title',
    description = 'Updated description',
    display_order = 2
WHERE id = 1;

-- UPDATE: Reorder gallery images
UPDATE gallery
SET display_order = display_order + 1
WHERE category = 'Sarees' AND id > 5;

-- DELETE: Soft delete gallery image
UPDATE gallery SET is_active = false WHERE id = 10;

-- DELETE: Hard delete
DELETE FROM gallery WHERE id = 10;

-- ============================================================================
-- SECTION 6: PRODUCT IMAGES CRUD OPERATIONS
-- ============================================================================

-- CREATE: Add product image
INSERT INTO product_images (product_id, image_url, display_order)
VALUES (1, '/product-images/saree-blue-carousel-1.jpg', 2);

-- READ: Get all images for a product
SELECT id, image_url, display_order
FROM product_images
WHERE product_id = 1
ORDER BY display_order ASC;

-- READ: Get main product image (first one)
SELECT image_url
FROM product_images
WHERE product_id = 1
ORDER BY display_order ASC
LIMIT 1;

-- UPDATE: Update image display order
UPDATE product_images
SET display_order = 3
WHERE id = 1 AND product_id = 1;

-- DELETE: Delete product image
DELETE FROM product_images WHERE id = 5;

-- ============================================================================
-- SECTION 7: APPOINTMENTS CRUD OPERATIONS
-- ============================================================================

-- CREATE: Add appointment
INSERT INTO appointments (customer_name, customer_email, customer_phone, service_id, appointment_date, appointment_time, status, notes)
VALUES (
    'Meena Singh',
    'meena@email.com',
    '+91-9876543210',
    1,
    '2026-01-15',
    '14:00:00',
    'pending',
    'Interested in saree fitting'
);

-- READ: Get all pending appointments
SELECT id, customer_name, customer_phone, appointment_date, appointment_time, status
FROM appointments
WHERE status = 'pending'
ORDER BY appointment_date ASC;

-- READ: Get appointments for a specific date
SELECT id, customer_name, appointment_time, status
FROM appointments
WHERE appointment_date = '2026-01-15'
ORDER BY appointment_time ASC;

-- UPDATE: Update appointment status
UPDATE appointments
SET status = 'confirmed'
WHERE id = 1;

-- UPDATE: Change appointment time
UPDATE appointments
SET appointment_time = '15:30:00'
WHERE id = 1;

-- DELETE: Cancel appointment
UPDATE appointments
SET status = 'cancelled'
WHERE id = 1;

-- ============================================================================
-- SECTION 8: PAYMENT CONFIGURATION CRUD
-- ============================================================================

-- READ: Get payment configuration
SELECT payment_method, is_enabled, api_key
FROM payment_configuration
WHERE is_enabled = true;

-- UPDATE: Update payment method
UPDATE payment_configuration
SET 
    api_key = 'new_api_key_here',
    secret_key = 'new_secret_key_here'
WHERE payment_method = 'razorpay';

-- UPDATE: Enable/Disable payment method
UPDATE payment_configuration
SET is_enabled = false
WHERE payment_method = 'upi';

-- ============================================================================
-- SECTION 9: SETTINGS CRUD OPERATIONS
-- ============================================================================

-- CREATE: Add new setting
INSERT INTO settings (setting_key, setting_value)
VALUES ('site_maintenance_mode', 'false')
ON CONFLICT (setting_key) DO UPDATE SET setting_value = 'false';

-- READ: Get all settings
SELECT setting_key, setting_value FROM settings ORDER BY setting_key;

-- READ: Get specific setting
SELECT setting_value FROM settings WHERE setting_key = 'business_name';

-- UPDATE: Update setting value
UPDATE settings
SET setting_value = '+91-8976543210'
WHERE setting_key = 'business_phone';

-- UPDATE: Multiple settings at once
UPDATE settings
SET setting_value = CASE 
    WHEN setting_key = 'tax_rate' THEN '20'
    WHEN setting_key = 'free_delivery_threshold' THEN '1500'
    ELSE setting_value
END
WHERE setting_key IN ('tax_rate', 'free_delivery_threshold');

-- ============================================================================
-- SECTION 10: ADMIN USERS CRUD OPERATIONS
-- ============================================================================

-- CREATE: Add admin user (password should be hashed in application)
INSERT INTO admin_users (email, password_hash, full_name, role, is_active)
VALUES (
    'admin@sunlighttradersco.in',
    'hashed_password_here',
    'Admin User',
    'admin',
    true
);

-- READ: Get admin users
SELECT id, email, full_name, role, is_active, last_login
FROM admin_users
WHERE is_active = true;

-- UPDATE: Update last login
UPDATE admin_users
SET last_login = NOW()
WHERE email = 'admin@sunlighttradersco.in';

-- UPDATE: Change role
UPDATE admin_users
SET role = 'moderator'
WHERE id = 1;

-- UPDATE: Deactivate user
UPDATE admin_users
SET is_active = false
WHERE id = 2;

-- DELETE: Delete admin user
DELETE FROM admin_users WHERE id = 3;

-- ============================================================================
-- SECTION 11: ADVANCED QUERIES - ANALYTICS & REPORTS
-- ============================================================================

-- Get sales summary
SELECT 
    DATE(created_at) as sale_date,
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as average_order_value
FROM orders
WHERE order_status IN ('delivered', 'shipped')
GROUP BY DATE(created_at)
ORDER BY sale_date DESC;

-- Get top selling products
SELECT 
    p.id,
    p.name,
    SUM(oi.quantity) as total_sold,
    SUM(oi.total_price) as total_revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 10;

-- Get products by category sales
SELECT 
    category,
    COUNT(DISTINCT id) as product_count,
    SUM(stock_quantity) as total_stock,
    AVG(price) as average_price
FROM products
WHERE is_active = true
GROUP BY category
ORDER BY product_count DESC;

-- Get customer with most orders
SELECT 
    customer_email,
    customer_name,
    COUNT(*) as order_count,
    SUM(total_amount) as total_spent
FROM orders
GROUP BY customer_email, customer_name
ORDER BY total_spent DESC
LIMIT 10;

-- Get average rating by product
SELECT 
    p.id,
    p.name,
    ROUND(AVG(r.rating), 2) as average_rating,
    COUNT(r.id) as review_count
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id AND r.is_approved = true
GROUP BY p.id, p.name
ORDER BY average_rating DESC;

-- ============================================================================
-- SECTION 12: BULK OPERATIONS
-- ============================================================================

-- Bulk update: Increase all product prices by 10%
UPDATE products
SET price = price * 1.10
WHERE category = 'Sarees' AND is_active = true;

-- Bulk insert: Add multiple products
INSERT INTO products (name, description, price, category, stock_quantity, sku, is_active)
VALUES 
('Cotton Saree - Purple', 'Beautiful cotton saree in purple', 2300, 'Sarees', 20, 'SKU-SAREE-101', true),
('Silk Saree - Pink', 'Elegant silk saree in pink', 5500, 'Sarees', 8, 'SKU-SAREE-102', true),
('Designer Suit - Orange', 'Modern suit in orange', 4000, 'Ladies Suits', 15, 'SKU-SUIT-101', true);

-- Bulk delete: Deactivate old products
UPDATE products
SET is_active = false
WHERE created_at < NOW() - INTERVAL '90 days' AND stock_quantity = 0;

-- ============================================================================
-- SECTION 13: VERIFICATION & MAINTENANCE
-- ============================================================================

-- Verify table integrity
SELECT 
    'Products' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_records
FROM products
UNION ALL
SELECT 'Services', COUNT(*), COUNT(CASE WHEN is_active = true THEN 1 END) FROM services
UNION ALL
SELECT 'Orders', COUNT(*), COUNT(CASE WHEN order_status != 'cancelled' THEN 1 END) FROM orders
UNION ALL
SELECT 'Reviews', COUNT(*), COUNT(CASE WHEN is_approved = true THEN 1 END) FROM reviews;

-- Check stock levels
SELECT name, stock_quantity, price
FROM products
WHERE stock_quantity < 10
ORDER BY stock_quantity ASC;

-- Get monthly revenue
SELECT 
    TO_CHAR(created_at, 'YYYY-MM') as month,
    COUNT(*) as orders,
    SUM(total_amount) as revenue
FROM orders
WHERE order_status IN ('delivered', 'shipped')
GROUP BY TO_CHAR(created_at, 'YYYY-MM')
ORDER BY month DESC;

-- ============================================================================
-- END OF CRUD OPERATIONS GUIDE
-- ============================================================================
