-- ============================================================
-- SAMPLE DATA SETUP FOR Nepo Online stores
-- Run this AFTER running COMPLETE_DATABASE_AND_STORAGE_SETUP.sql
-- ============================================================

-- ============================================================
-- 1. INSERT SAMPLE SERVICES
-- ============================================================

INSERT INTO services (title, description, price, duration_hours, image_url, is_active) VALUES
(
    'Bridal Makeup',
    'Complete bridal makeup package with premium products and long-lasting finish',
    5000,
    2,
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/service-images/bridal-makeup.jpg',
    true
),
(
    'Facial Treatment',
    'Deep cleansing facial with professional skincare products',
    1500,
    1,
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/service-images/facial.jpg',
    true
),
(
    'Hair Styling',
    'Professional hair styling for all occasions',
    2000,
    1.5,
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/service-images/hair-styling.jpg',
    true
),
(
    'Threading',
    'Professional eyebrow threading and shaping',
    300,
    0.5,
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/service-images/threading.jpg',
    true
),
(
    'Massage Therapy',
    'Relaxing full body massage with essential oils',
    2500,
    1,
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/service-images/massage.jpg',
    true
);

-- ============================================================
-- 2. INSERT SAMPLE PRODUCTS
-- ============================================================

INSERT INTO products (name, description, price, stock_quantity, image_url, category, is_active) VALUES
(
    'Moisturizing Face Cream',
    'Premium moisturizing cream for all skin types, with SPF 30',
    1200,
    50,
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/product-images/face-cream.jpg',
    'Skincare',
    true
),
(
    'Anti-Acne Serum',
    'Powerful anti-acne serum with neem and tea tree oil',
    1500,
    35,
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/product-images/acne-serum.jpg',
    'Skincare',
    true
),
(
    'Lip Gloss Shine',
    'Long-lasting lip gloss with natural shine and moisture',
    400,
    100,
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/product-images/lip-gloss.jpg',
    'Makeup',
    true
),
(
    'Foundation Base',
    'Smooth coverage foundation with natural finish',
    950,
    45,
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/product-images/foundation.jpg',
    'Makeup',
    true
),
(
    'Eye Shadow Palette',
    '12-color eye shadow palette with rich pigmentation',
    1800,
    25,
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/product-images/eyeshadow.jpg',
    'Makeup',
    true
);

-- ============================================================
-- 3. INSERT SAMPLE GALLERY IMAGES
-- ============================================================

INSERT INTO gallery (title, image_url, image_type, description, is_active) VALUES
(
    'Professional Makeup Application',
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/gallery-images/makeup1.jpg',
    'image',
    'Professional Makeup Application',
    true
),
(
    'Beautiful Bridal Makeover',
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/gallery-images/bridal1.jpg',
    'image',
    'Beautiful Bridal Makeover',
    true
),
(
    'Elegant Hair Styling',
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/gallery-images/hair1.jpg',
    'image',
    'Elegant Hair Styling',
    true
),
(
    'Glowing Skin Care Results',
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/gallery-images/skin1.jpg',
    'image',
    'Glowing Skin Care Results',
    true
),
(
    'Creative Makeup Design',
    'https://gqzajmxtkfnvfceokwip.supabase.co/storage/v1/object/public/gallery-images/makeup2.jpg',
    'image',
    'Creative Makeup Design',
    true
);

-- ============================================================
-- 4. INSERT HOME VIDEO (HERO SECTION)
-- ============================================================

INSERT INTO home_video (video_url, title, is_active) VALUES
(
    'https://youtu.be/dQw4w9WgXcQ',
    'Nepo Online stores - Welcome Video',
    true
);

-- ============================================================
-- 5. INSERT SAMPLE REVIEWS
-- ============================================================

INSERT INTO reviews (product_id, customer_name, customer_email, rating, review_title, review_text, status) VALUES
(
    1,
    'Priya Sharma',
    'priya@example.com',
    5,
    'Excellent moisturizer!',
    'Excellent moisturizer! My skin feels hydrated all day long. Highly recommended!',
    'approved'
),
(
    1,
    'Anjali Gupta',
    'anjali@example.com',
    4,
    'Good product',
    'Good product, works well. Just a bit pricey for the quantity.',
    'approved'
),
(
    2,
    'Neha Singh',
    'neha@example.com',
    5,
    'Best serum!',
    'Best serum I have ever used! My acne cleared up in 2 weeks.',
    'approved'
),
(
    3,
    'Pooja Verma',
    'pooja@example.com',
    4,
    'Nice quality',
    'Nice lip gloss, good color, stays on for hours.',
    'approved'
),
(
    4,
    'Meera Patel',
    'meera@example.com',
    5,
    'Amazing quality!',
    'Amazing quality eye shadows. Colors are vibrant and long-lasting.',
    'approved'
);

-- ============================================================
-- 6. INSERT PAYMENT CONFIGURATION
-- ============================================================

INSERT INTO payment_configuration (payment_method, is_enabled, config_data) VALUES
(
    'cash_on_delivery',
    true,
    '{"min_order": 0, "max_order": 100000}'::jsonb
),
(
    'credit_card',
    true,
    '{"gateway": "razorpay", "currency": "INR"}'::jsonb
),
(
    'upi',
    true,
    '{"gateway": "razorpay", "currency": "INR"}'::jsonb
);

-- ============================================================
-- 7. INSERT WEBSITE SETTINGS
-- ============================================================

INSERT INTO settings (setting_key, setting_value) VALUES
('business_name', 'Nepo Online stores & Cosmetic Center'),
('business_phone', '033590207'),
('business_email', 'info@manishabeauty.com'),
('business_address', 'Khaireni, Gulmi, Nepal'),
('business_hours', '10:00 AM - 8:00 PM'),
('facebook_url', 'https://facebook.com/manishabeauty'),
('instagram_url', 'https://instagram.com/manishabeauty'),
('youtube_url', 'https://youtube.com/manishabeauty'),
('about_text', 'Welcome to Nepo Online stores & Cosmetic Center. We provide premium beauty and wellness services with professional expertise.'),
('terms_text', 'By using our services, you agree to our terms and conditions.'),
('privacy_text', 'Your privacy is important to us. We do not share your personal information.');

-- ============================================================
-- 8. VERIFY DATA INSERTION
-- ============================================================

SELECT 'Services' as table_name, COUNT(*) as row_count FROM services
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Gallery', COUNT(*) FROM gallery
UNION ALL
SELECT 'Reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'Payment Config', COUNT(*) FROM payment_configuration
UNION ALL
SELECT 'Settings', COUNT(*) FROM settings
UNION ALL
SELECT 'Home Video', COUNT(*) FROM home_video;

-- ============================================================
-- 9. UPDATE RLS POLICIES (If needed)
-- ============================================================

-- Ensure public can read services
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read services" ON services;
CREATE POLICY "Public read services" ON services
    FOR SELECT USING (is_active = true);

-- Ensure public can read products
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read products" ON products;
CREATE POLICY "Public read products" ON products
    FOR SELECT USING (is_active = true);

-- Ensure public can read gallery
ALTER TABLE gallery ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read gallery" ON gallery;
CREATE POLICY "Public read gallery" ON gallery
    FOR SELECT USING (is_active = true);

-- Ensure public can read reviews
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read reviews" ON reviews;
CREATE POLICY "Public read reviews" ON reviews
    FOR SELECT USING (is_approved = true);

-- Ensure public can read home video
ALTER TABLE home_video ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read home video" ON home_video;
CREATE POLICY "Public read home video" ON home_video
    FOR SELECT USING (is_active = true);

-- Ensure public can read settings
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read settings" ON settings;
CREATE POLICY "Public read settings" ON settings
    FOR SELECT USING (true);

-- ============================================================
-- END OF SAMPLE DATA SETUP
-- ============================================================
