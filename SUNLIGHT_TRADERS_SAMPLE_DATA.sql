-- Nepo Online stores Sample Data Setup
-- This SQL file populates the database with sample clothing products and data

-- Clear existing data (optional - comment out if you want to keep it)
-- DELETE FROM reviews;
-- DELETE FROM order_items;
-- DELETE FROM orders;
-- DELETE FROM appointments;
-- DELETE FROM gallery;
-- DELETE FROM product_images;
-- DELETE FROM products;
-- DELETE FROM services;
-- DELETE FROM admin_users;

-- Insert Collections (Services converted to clothing collections)
INSERT INTO services (name, description, price, duration) VALUES
('Sarees', 'Traditional and modern sarees with beautiful designs and patterns', 2500, 2),
('Ladies Suits', 'Designer ladies suits in various styles and fabrics', 3000, 2),
('Lehengas', 'Elegant lehengas for weddings and special occasions', 4500, 3),
('Boots & Shoes', 'Premium boots and footwear for all occasions', 2000, 1),
('Readymade Clothes', 'High-quality readymade garments for everyday wear', 1500, 1);

-- Insert Clothing Products
INSERT INTO products (name, description, price, image_url, category) VALUES
('Cotton Saree - Blue', 'Beautiful blue cotton saree with floral patterns, perfect for daily wear', 2500, '/product-images/saree-blue.jpg', 'Sarees'),
('Silk Saree - Red', 'Stunning red silk saree ideal for special occasions and celebrations', 5000, '/product-images/saree-red.jpg', 'Sarees'),
('Designer Suit - Green', 'Modern designer suit in green color with embroidery work', 3500, '/product-images/suit-green.jpg', 'Ladies Suits'),
('Cotton Suit - Yellow', 'Comfortable cotton suit in bright yellow shade for casual wear', 2500, '/product-images/suit-yellow.jpg', 'Ladies Suits'),
('Bridal Lehenga - Gold', 'Exquisite gold bridal lehenga with intricate beadwork and sequins', 8000, '/product-images/lehenga-gold.jpg', 'Lehengas');

-- Insert Product Images (if you have multiple images per product)
INSERT INTO product_images (product_id, image_url, display_order) VALUES
(1, '/product-images/saree-blue-1.jpg', 1),
(1, '/product-images/saree-blue-2.jpg', 2),
(2, '/product-images/saree-red-1.jpg', 1),
(3, '/product-images/suit-green-1.jpg', 1),
(4, '/product-images/suit-yellow-1.jpg', 1);

-- Insert Gallery Images (fashion/clothing showcase)
INSERT INTO gallery (title, description, image_url, category) VALUES
('Elegant Sarees Collection', 'Browse our collection of traditional and modern sarees', '/gallery-images/sarees-collection.jpg', 'Sarees'),
('Designer Suits', 'Latest designer suits for modern women', '/gallery-images/suits-collection.jpg', 'Ladies Suits'),
('Wedding Lehengas', 'Stunning bridal and wedding lehengas', '/gallery-images/lehengas-collection.jpg', 'Lehengas'),
('Footwear Collection', 'Premium boots and shoes for all occasions', '/gallery-images/boots-collection.jpg', 'Boots & Shoes'),
('Summer Collection', 'Comfortable readymade clothes for summer season', '/gallery-images/summer-readymade.jpg', 'Readymade Clothes');

-- Insert Customer Reviews
INSERT INTO reviews (product_id, customer_name, rating, comment, created_at) VALUES
(1, 'Priya Sharma', 5, 'Beautiful saree! Great quality and fast delivery. Highly recommended!', NOW() - INTERVAL '5 days'),
(2, 'Anita Gupta', 5, 'Excellent silk saree. Perfect for my wedding. Thank you!', NOW() - INTERVAL '10 days'),
(3, 'Neha Patel', 4, 'Nice suit, good fit. Colors are as shown in pictures.', NOW() - INTERVAL '15 days'),
(4, 'Pooja Singh', 5, 'Amazing suit! Comfortable and stylish. Love the color!', NOW() - INTERVAL '20 days'),
(5, 'Rajni Kumar', 5, 'Absolutely stunning lehenga! Made me feel like a bride!', NOW() - INTERVAL '25 days');

-- Insert Payment Configuration
INSERT INTO payment_configuration (payment_method, is_enabled, api_key, secret_key) VALUES
('razorpay', true, 'your_razorpay_key_id', 'your_razorpay_secret'),
('upi', true, 'upi_configuration', 'upi_details'),
('bank_transfer', true, 'bank_account_details', 'bank_config'),
('cod', true, 'cash_on_delivery', 'enabled');

-- Insert Settings
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
('business_description', 'Nepo Online stores offers premium quality clothing and fashion items including sarees, ladies suits, lehengas, boots, shoes, and readymade clothes.');

-- Insert Home Video (optional - update with your video URL)
INSERT INTO home_video (title, video_url, description) VALUES
('Nepo Online stores Fashion Showcase', 'https://www.youtube.com/embed/VIDEO_ID', 'Discover our latest collection of sarees, suits, and lehengas');

-- Update RLS policies if needed
-- Note: RLS policies are already created in COMPLETE_DATABASE_AND_STORAGE_SETUP.sql

COMMIT;

-- Verification queries (run these to verify data was inserted correctly):
-- SELECT COUNT(*) as total_services FROM services;
-- SELECT COUNT(*) as total_products FROM products;
-- SELECT COUNT(*) as total_gallery FROM gallery;
-- SELECT COUNT(*) as total_reviews FROM reviews;
-- SELECT * FROM products LIMIT 5;
