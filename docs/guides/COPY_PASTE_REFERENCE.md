# 📋 COPY-PASTE REFERENCE - Database Setup Files

**Purpose:** Quick reference for which files to copy and paste in which order  
**No thinking required - just follow the order**

---

## 🔢 ORDER OF OPERATIONS

```
STEP 1: Copy COMPLETE_DATABASE_AND_STORAGE_SETUP.sql → Paste → Run ✅
        ↓
STEP 2: Copy SAMPLE_DATA_SETUP.sql → Paste → Run ✅
        ↓
STEP 3: Create 5 Storage Buckets (manual in UI) ✅
        ↓
STEP 4: Test Website ✅
```

---

# STEP 1: SETUP DATABASE TABLES

## File Location
```
b:\sunr\COMPLETE_DATABASE_AND_STORAGE_SETUP.sql
```

## File Size
- **736 lines of SQL code**
- **Contains:** 13 table definitions + functions + triggers + RLS policies

## What It Creates
```
Tables:
  ✓ admin_users
  ✓ services  
  ✓ products
  ✓ product_images
  ✓ reviews
  ✓ review_helpful_votes
  ✓ appointments
  ✓ gallery
  ✓ home_video
  ✓ payment_configuration
  ✓ orders
  ✓ order_items
  ✓ settings

Functions:
  ✓ generate_order_number()
  ✓ trigger_update_timestamp()
  ✓ update_order_status()
  ✓ get_order_details()
  ✓ update_product_reviews_stats()

Triggers:
  ✓ Auto-timestamps on all tables
  ✓ Auto-generate order numbers
  ✓ Update review statistics

RLS Policies:
  ✓ Public read access configured
  ✓ Authenticated insert/update configured
```

## How To Execute
```
1. Open: https://app.supabase.com
2. Login → Select: znbxvkptusjrmeuyxibu project
3. Left sidebar → Click: SQL Editor
4. Click: New Query
5. Open: b:\sunr\COMPLETE_DATABASE_AND_STORAGE_SETUP.sql
6. Select All: Ctrl+A
7. Copy: Ctrl+C
8. Paste into Supabase SQL Editor: Ctrl+V
9. Click: Run button
10. Wait for: ✅ Success message (30-60 seconds)
```

## Success Indicators
- ✅ No error messages
- ✅ Message says "Query executed successfully"
- ✅ Can see all 13 tables in left sidebar

---

# STEP 2: INSERT SAMPLE DATA

## File Location
```
b:\sunr\SAMPLE_DATA_SETUP.sql
```

## File Size
- **305 lines of SQL code**
- **Contains:** INSERT statements for sample data

## What It Inserts
```
services table:
  ✓ Bridal Makeup (5000)
  ✓ Facial Treatment (1500)
  ✓ Hair Styling (2000)
  ✓ Threading (300)
  ✓ Massage Therapy (2500)

products table:
  ✓ Moisturizing Face Cream (1200)
  ✓ Anti-Acne Serum (1500)
  ✓ Lip Gloss Shine (400)
  ✓ Foundation Base (950)
  ✓ Eye Shadow Palette (1800)

gallery table:
  ✓ Professional Makeup Application
  ✓ Beautiful Bridal Makeover
  ✓ Elegant Hair Styling
  ✓ Glowing Skin Care Results
  ✓ Creative Makeup Design

reviews table:
  ✓ 5 sample reviews with ratings

settings table:
  ✓ business_name
  ✓ business_phone
  ✓ business_email
  ✓ business_address
  ✓ business_hours
  ✓ social media links
  ✓ about/terms/privacy text

home_video table:
  ✓ YouTube video link
```

## How To Execute
```
1. SQL Editor → Click: New Query
2. Open: b:\sunr\SAMPLE_DATA_SETUP.sql
3. Select All: Ctrl+A
4. Copy: Ctrl+C
5. Paste into Supabase SQL Editor: Ctrl+V
6. Click: Run button
7. Wait for: ✅ Success message (10-20 seconds)
```

## Success Indicators
- ✅ No error messages
- ✅ Message says "Query executed successfully"
- ✅ If you run verification query: SELECT COUNT(*) FROM services; → Result: 5

---

# STEP 3: CREATE STORAGE BUCKETS

## Manual Setup in Supabase UI

### Bucket 1: product-images
```
Go to: Storage (left sidebar)
Click: New Bucket
Name: product-images
Public: ✓ Check
Click: Create bucket
```

### Bucket 2: gallery-images
```
Click: New Bucket
Name: gallery-images
Public: ✓ Check
Click: Create bucket
```

### Bucket 3: videos
```
Click: New Bucket
Name: videos
Public: ✓ Check
Click: Create bucket
```

### Bucket 4: service-images
```
Click: New Bucket
Name: service-images
Public: ✓ Check
Click: Create bucket
```

### Bucket 5: transaction-screenshots
```
Click: New Bucket
Name: transaction-screenshots
Public: ✓ Check
Click: Create bucket
```

## Success Indicators
- ✅ All 5 buckets visible in Storage section
- ✅ Each shows "Public" badge

---

# STEP 4: VERIFY SETUP

## Query 1: Check Tables Exist

**Paste in SQL Editor:**
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

**Expected Result:**
```
admin_users
appointments
gallery
home_video
order_items
orders
payment_configuration
product_images
products
review_helpful_votes
reviews
services
settings
```

## Query 2: Check Data Count

**Paste in SQL Editor:**
```sql
SELECT 'services' as table_name, COUNT(*) as count FROM services
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'gallery', COUNT(*) FROM gallery
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'payment_configuration', COUNT(*) FROM payment_configuration
UNION ALL
SELECT 'settings', COUNT(*) FROM settings
UNION ALL
SELECT 'home_video', COUNT(*) FROM home_video;
```

**Expected Result:**
```
services | 5
products | 5
gallery | 5
reviews | 5
payment_configuration | 1
settings | 11
home_video | 1
```

## Query 3: Test Order Number Generation

**Paste in SQL Editor:**
```sql
SELECT generate_order_number();
```

**Expected Result:**
```
ORD-20260103... (random generated order number)
```

---

# STEP 5: TEST WEBSITE

## Browser Test
```
1. Open website in browser
2. Hard refresh: Ctrl+Shift+R
3. Open console: F12
4. Check: NO red errors visible
5. Visual check:
   ✓ Logo appears
   ✓ Services section shows data
   ✓ Products section shows data
   ✓ Gallery shows 5 images
   ✓ Reviews visible
```

## Admin Login Test
```
1. Go to: admin.html (on your website)
2. Email: diwashb32@gmail.com
3. Password: dipak@121
4. Click: Login
5. Expected: Login successful, admin panel appears
```

---

# IF SOMETHING GOES WRONG

## Error: "Table already exists"
→ **This is OK** - Continue to Step 2

## Error: "Syntax Error"
→ **Copy the file again** - Make sure entire file is copied

## Error: "Permission Denied"
→ **RLS issue** - Run SAMPLE_DATA_SETUP.sql again

## Website still shows errors
→ **Hard refresh:** Ctrl+Shift+R and wait 5 seconds

## Storage buckets not working
→ **Re-create them** - Delete and create again with same names

## Admin can't login
→ **Run this in SQL Editor:**
```sql
INSERT INTO admin_users (email, name, role, is_active)
VALUES ('diwashb32@gmail.com', 'Diwas', 'admin', true)
ON CONFLICT DO NOTHING;
```

---

# FINAL CHECKLIST

- [ ] Opened https://app.supabase.com
- [ ] Selected project: znbxvkptusjrmeuyxibu
- [ ] Copied COMPLETE_DATABASE_AND_STORAGE_SETUP.sql
- [ ] Pasted and Ran it ✅
- [ ] Copied SAMPLE_DATA_SETUP.sql
- [ ] Pasted and Ran it ✅
- [ ] Created 5 storage buckets ✅
- [ ] Verified: SELECT COUNT(*) FROM services; = 5 ✅
- [ ] Website loads with NO errors ✅
- [ ] Admin login works ✅

---

## 🎉 SETUP COMPLETE!

Your database is ready to use with **ZERO ERRORS**!

