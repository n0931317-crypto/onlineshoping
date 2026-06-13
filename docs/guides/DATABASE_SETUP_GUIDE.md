# Complete Database & Storage Setup Guide - Sunlights Website

## Overview

This document provides step-by-step instructions to set up the complete database and storage infrastructure for the Sunlights website in Supabase.

---

## 📋 What's Included

### Database Tables (13 total)
1. **admin_users** - Admin user credentials and roles
2. **services** - Service offerings
3. **products** - Product catalog
4. **product_images** - Multiple images per product
5. **reviews** - Product reviews and ratings
6. **review_helpful_votes** - Helpful votes on reviews
7. **appointments** - Service appointments
8. **gallery** - Gallery images
9. **home_video** - Home video content
10. **payment_configuration** - Payment method details
11. **orders** - Customer orders
12. **order_items** - Products in orders
13. **settings** - Application settings

### Storage Buckets (6 total)
1. **product-images** - Product listing images
2. **product-images-slot-1 to slot-4** - Multiple images per product
3. **gallery-images** - Gallery images
4. **videos** - Home video and promotional content
5. **transaction-screenshots** - Payment proof images
6. **service-images** - Service images

### Features
- ✅ Row Level Security (RLS) policies for all tables
- ✅ Automatic timestamp management
- ✅ Order number generation
- ✅ Product review statistics
- ✅ Helpful votes tracking
- ✅ Admin order management
- ✅ Multiple payment method support
- ✅ Performance indexes on all key fields

---

## 🚀 Setup Instructions

### Step 1: Run the SQL Setup Script

1. Go to **Supabase Dashboard** → **SQL Editor**
2. Click **"New Query"**
3. Open the file `COMPLETE_DATABASE_AND_STORAGE_SETUP.sql`
4. Copy all the SQL code
5. Paste it into the Supabase SQL Editor
6. Click **"Run"** (or press Ctrl+Enter)
7. Wait for all commands to complete successfully

### Step 2: Create Storage Buckets

1. Go to **Supabase Dashboard** → **Storage**
2. Click **"Create new bucket"**

#### Create these buckets (in order):

**Bucket 1: product-images**
- Name: `product-images`
- Public: **ON** (toggle to enable)
- Click Create

**Bucket 2: product-images-slot-1**
- Name: `product-images-slot-1`
- Public: **ON**
- Click Create

**Bucket 3: product-images-slot-2**
- Name: `product-images-slot-2`
- Public: **ON**
- Click Create

**Bucket 4: product-images-slot-3**
- Name: `product-images-slot-3`
- Public: **ON**
- Click Create

**Bucket 5: product-images-slot-4**
- Name: `product-images-slot-4`
- Public: **ON**
- Click Create

**Bucket 6: gallery-images**
- Name: `gallery-images`
- Public: **ON**
- Click Create

**Bucket 7: videos**
- Name: `videos`
- Public: **ON**
- Click Create

**Bucket 8: transaction-screenshots**
- Name: `transaction-screenshots`
- Public: **ON**
- Click Create

**Bucket 9: service-images**
- Name: `service-images`
- Public: **ON**
- Click Create

### Step 3: Verify Setup

Run these verification queries in the SQL Editor to confirm everything is set up:

```sql
-- Check all tables exist
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

-- Check storage buckets
SELECT name, public FROM storage.buckets ORDER BY name;
```

---

## 📊 Database Schema Details

### 1. admin_users Table
Stores admin user accounts.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| email | VARCHAR(255) | Unique, used for login |
| password_hash | VARCHAR(255) | Hashed password |
| name | VARCHAR(255) | Admin full name |
| role | VARCHAR(50) | Admin role (default: 'admin') |
| is_active | BOOLEAN | Account status |
| last_login | TIMESTAMP | Last login timestamp |
| created_at | TIMESTAMP | Created timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### 2. products Table
Product catalog.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| name | TEXT | Product name |
| description | TEXT | Product description |
| price | DECIMAL(10,2) | Product price |
| stock_quantity | BIGINT | Available stock |
| image_url | TEXT | Main product image |
| category | TEXT | Product category |
| is_active | BOOLEAN | Visibility status |
| reviews_count | INTEGER | Total reviews (auto-updated) |
| average_rating | DECIMAL(3,2) | Average rating (auto-updated) |
| created_at | TIMESTAMP | Created timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### 3. reviews Table
Product reviews and ratings.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| product_id | BIGINT | Foreign Key to products |
| customer_name | VARCHAR(255) | Reviewer name |
| customer_email | VARCHAR(255) | Reviewer email |
| rating | INTEGER | Rating 1-5 (checked) |
| review_title | VARCHAR(255) | Review title |
| review_text | TEXT | Review content |
| is_verified_purchase | BOOLEAN | Purchase verification |
| helpful_count | INTEGER | Helpful votes count |
| status | VARCHAR(50) | pending/approved/rejected |
| created_at | TIMESTAMP | Created timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### 4. orders Table
Customer orders.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| order_number | VARCHAR(50) | Unique order number (auto-generated) |
| customer_name | TEXT | Customer name |
| customer_email | TEXT | Customer email |
| customer_phone | TEXT | Customer phone |
| street_address | TEXT | Delivery address |
| city | TEXT | City |
| state | TEXT | State/Province |
| postal_code | TEXT | Postal code |
| delivery_instructions | TEXT | Special instructions |
| transaction_code | TEXT | Payment transaction ID |
| transaction_screenshot | TEXT | Payment proof URL |
| transaction_notes | TEXT | Payment notes |
| payment_method | VARCHAR(50) | Payment method used |
| subtotal | DECIMAL(10,2) | Items subtotal |
| delivery_charge | DECIMAL(10,2) | Delivery fee |
| total_amount | DECIMAL(10,2) | Total order amount |
| status | VARCHAR(30) | Order status |
| order_notes | TEXT | Customer notes |
| confirmed_by_admin | BOOLEAN | Admin confirmation |
| admin_notes | TEXT | Admin notes |
| confirmed_at | TIMESTAMP | Confirmation timestamp |
| created_at | TIMESTAMP | Created timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### 5. order_items Table
Products in orders.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| order_id | BIGINT | Foreign Key to orders |
| product_id | BIGINT | Foreign Key to products |
| product_name | TEXT | Product name (snapshot) |
| quantity | BIGINT | Quantity ordered |
| price | DECIMAL(10,2) | Price at purchase |
| subtotal | DECIMAL(10,2) | Quantity × Price |
| created_at | TIMESTAMP | Created timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### 6. appointments Table
Service appointments.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| service_id | BIGINT | Foreign Key to services |
| customer_name | TEXT | Customer name |
| customer_email | TEXT | Customer email |
| customer_phone | TEXT | Customer phone |
| appointment_date | DATE | Appointment date |
| appointment_time | TIME | Appointment time |
| appointment_notes | TEXT | Customer notes |
| status | VARCHAR(20) | pending/confirmed/completed |
| created_at | TIMESTAMP | Created timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### 7. services Table
Service offerings.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| title | TEXT | Service name |
| description | TEXT | Service description |
| price | DECIMAL(10,2) | Service price |
| image_url | TEXT | Service image |
| duration_hours | SMALLINT | Service duration in hours |
| is_active | BOOLEAN | Visibility status |
| created_at | TIMESTAMP | Created timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### 8. product_images Table
Multiple images per product.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| product_id | BIGINT | Foreign Key to products |
| image_url | TEXT | Image URL |
| image_order | SMALLINT | Display order (1-4) |
| bucket_name | VARCHAR(100) | Storage bucket name |
| storage_path | VARCHAR(255) | Path in storage |
| is_active | BOOLEAN | Visibility status |
| created_at | TIMESTAMP | Created timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### 9. reviews Table
Product reviews (covered above)

### 10. review_helpful_votes Table
Helpful votes on reviews.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| review_id | BIGINT | Foreign Key to reviews |
| voter_email | VARCHAR(255) | Voter email |
| created_at | TIMESTAMP | Created timestamp |
| UNIQUE | (review_id, voter_email) | One vote per user per review |

### 11. gallery Table
Gallery images.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| title | TEXT | Image title |
| image_url | TEXT | Image URL |
| image_type | VARCHAR(50) | Image type |
| description | TEXT | Image description |
| is_active | BOOLEAN | Visibility status |
| display_order | BIGINT | Display order |
| created_at | TIMESTAMP | Created timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### 12. home_video Table
Home video content.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| title | TEXT | Video title |
| video_url | TEXT | Video URL |
| description | TEXT | Video description |
| is_active | BOOLEAN | Visibility status |
| created_at | TIMESTAMP | Created timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### 13. payment_configuration Table
Payment method settings.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| esewa_number | TEXT | eSewa account number |
| esewa_name | TEXT | eSewa account name |
| esewa_active | BOOLEAN | eSewa enabled |
| khalti_number | TEXT | Khalti account number |
| khalti_name | TEXT | Khalti account name |
| khalti_active | BOOLEAN | Khalti enabled |
| bank_name | TEXT | Bank name |
| bank_account | TEXT | Bank account number |
| bank_holder | TEXT | Account holder name |
| bank_code | TEXT | Bank code |
| bank_active | BOOLEAN | Bank transfer enabled |
| is_active | BOOLEAN | Overall status |
| created_at | TIMESTAMP | Created timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### 14. settings Table
Application settings.

| Field | Type | Notes |
|-------|------|-------|
| id | BIGSERIAL | Primary Key |
| setting_key | VARCHAR(255) | Setting key (unique) |
| setting_value | TEXT | Setting value |
| description | TEXT | Setting description |
| is_active | BOOLEAN | Setting enabled |
| created_at | TIMESTAMP | Created timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

---

## 🔐 Row Level Security (RLS) Policies

### Public Access (Anyone can read)
- `services` - All services
- `products` - All products
- `product_images` - Active images
- `gallery` - Active gallery items
- `home_video` - Active videos
- `payment_configuration` - Active configuration
- `orders` - All orders (for tracking)
- `order_items` - All items
- `appointments` - All appointments
- `reviews` - Approved reviews only
- `review_helpful_votes` - All votes
- `settings` - Active settings only

### Insert Allowed (Anyone can create)
- `orders` - Anyone can place orders
- `order_items` - Anyone can add items
- `appointments` - Anyone can book appointments
- `reviews` - Anyone can submit reviews
- `review_helpful_votes` - Anyone can vote

### Admin Only
- `admin_users` - Admins only

---

## 🗄️ Storage Bucket Policies

### All Buckets
- **SELECT**: Public (anyone can read/download)
- **INSERT**: Authenticated users
- **UPDATE**: Authenticated users (own files)
- **DELETE**: Authenticated users (own files)

### Bucket Details

| Bucket | Purpose | Size |
|--------|---------|------|
| product-images | Product listing images | 50 MB |
| product-images-slot-1 | Product image slot 1 | 50 MB |
| product-images-slot-2 | Product image slot 2 | 50 MB |
| product-images-slot-3 | Product image slot 3 | 50 MB |
| product-images-slot-4 | Product image slot 4 | 50 MB |
| gallery-images | Gallery images | 50 MB |
| videos | Videos | 100 MB |
| transaction-screenshots | Payment proofs | 50 MB |
| service-images | Service images | 50 MB |

---

## 📝 Database Functions

### generate_order_number()
Generates unique order numbers in format: `ORD-YYYYMMDDHH24MISS-XXXX`

```sql
SELECT generate_order_number();
-- Returns: ORD-20240115103045-4829
```

### update_order_status(order_id, new_status, admin_notes)
Updates order status and admin notes.

```sql
SELECT update_order_status(1, 'confirmed', 'Order confirmed by admin');
```

### get_order_details(order_id)
Retrieves complete order details including items.

```sql
SELECT * FROM get_order_details(1);
```

### update_product_reviews_stats()
Auto-updates product review count and average rating.
(Runs automatically via trigger)

---

## ⚙️ Automatic Triggers

1. **trg_set_order_number** - Auto-generates order number on insert
2. **trg_update_*_timestamp** - Updates timestamp on every table update
3. **trigger_update_product_reviews_stats** - Updates product stats when review changes

---

## 🧪 Testing the Setup

### Test 1: Insert a Sample Product
```sql
INSERT INTO products (name, description, price, stock_quantity, category)
VALUES (
    'Test Product',
    'This is a test product',
    999.99,
    50,
    'Test Category'
);
```

### Test 2: Insert a Sample Review
```sql
INSERT INTO reviews (product_id, customer_name, customer_email, rating, review_title, review_text, status)
VALUES (
    1,
    'Test Customer',
    'test@example.com',
    5,
    'Great Product!',
    'This product exceeded my expectations.',
    'approved'
);
```

### Test 3: Insert a Sample Order
```sql
INSERT INTO orders (customer_name, customer_email, customer_phone, total_amount, street_address, city)
VALUES (
    'John Doe',
    'john@example.com',
    '9841234567',
    5999.99,
    '123 Main Street',
    'Kathmandu'
);
```

### Test 4: Check Generated Order Number
```sql
SELECT order_number FROM orders ORDER BY id DESC LIMIT 1;
```

### Test 5: Verify Reviews Stats Updated
```sql
SELECT id, name, reviews_count, average_rating FROM products WHERE id = 1;
```

---

## 🛠️ Maintenance

### Add New Product with Images
```sql
-- Insert product
INSERT INTO products (name, description, price, stock_quantity, category)
VALUES ('New Product', 'Description', 999.99, 10, 'Category')
RETURNING id;

-- Then insert images (replace product_id)
INSERT INTO product_images (product_id, image_url, image_order, bucket_name)
VALUES 
(1, 'https://...image1.jpg', 1, 'product-images-slot-1'),
(1, 'https://...image2.jpg', 2, 'product-images-slot-2');
```

### Update Payment Configuration
```sql
UPDATE payment_configuration 
SET esewa_number = '033590207', esewa_active = true
WHERE id = 1;
```

### Approve a Review
```sql
UPDATE reviews 
SET status = 'approved' 
WHERE id = 1;
```

### Update Order Status
```sql
SELECT update_order_status(1, 'shipped', 'Order dispatched');
```

---

## ❓ Troubleshooting

### Issue: "permission denied for schema public"
**Solution:** Ensure RLS policies are properly set. Run the RLS setup section again.

### Issue: "relation does not exist"
**Solution:** Run the entire SQL setup script again to create missing tables.

### Issue: Storage bucket not accessible
**Solution:** Verify bucket is set to PUBLIC in Storage settings.

### Issue: Images not uploading
**Solution:** Check the bucket name matches exactly in JavaScript code.

### Issue: Order number not generating
**Solution:** Verify the trigger is created: 
```sql
SELECT * FROM information_schema.triggers WHERE trigger_name = 'trg_set_order_number';
```

---

## 📞 Support

For issues or questions:
1. Check Supabase logs in Dashboard
2. Verify all SQL executed without errors
3. Check storage bucket settings
4. Verify RLS policies are enabled on all tables

---

## ✅ Checklist

Before going live:

- [ ] All 13 tables created successfully
- [ ] All 9 storage buckets created and set to PUBLIC
- [ ] RLS policies applied to all tables
- [ ] Sample data inserted and verified
- [ ] Order number generation tested
- [ ] Review stats calculation tested
- [ ] Payment configuration set up
- [ ] Database backups configured
- [ ] Admin credentials set
- [ ] JavaScript code updated with correct Supabase URL and key

---

**Setup Complete! Your database is ready to use.** 🎉
