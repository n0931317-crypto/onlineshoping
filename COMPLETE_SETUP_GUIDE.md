# 🚀 COMPLETE DATABASE SETUP GUIDE - STEP BY STEP

**Status:** Comprehensive & Foolproof  
**Time Required:** 30-45 minutes  
**Difficulty:** Easy (Copy & Paste)  
**No Coding Knowledge Needed** ✅

---

## 📋 TABLE OF CONTENTS

1. [Prerequisites & Login](#prerequisites)
2. [Step 1: Create Database Tables](#step-1-create-tables)
3. [Step 2: Insert Sample Data](#step-2-sample-data)
4. [Step 3: Create Storage Buckets](#step-3-storage)
5. [Step 4: Set Up RLS Policies](#step-4-rls)
6. [Step 5: Verify Everything](#step-5-verify)
7. [Troubleshooting](#troubleshooting)

---

## PREREQUISITES {#prerequisites}

✅ Supabase Project Created: `znbxvkptusjrmeuyxibu`  
✅ Project URL: `https://znbxvkptusjrmeuyxibu.supabase.co`  
✅ Files Ready: `COMPLETE_DATABASE_AND_STORAGE_SETUP.sql` + `SAMPLE_DATA_SETUP.sql`

---

# STEP 1: CREATE DATABASE TABLES {#step-1-create-tables}

## **Task:** Run the main SQL setup file that creates all tables

### **Sub-Step 1.1: Go to Supabase Console**

1. **Open browser and visit:**
   ```
   https://app.supabase.com
   ```

2. **Login with your account credentials**

3. **Select project:**
   - Look for: `znbxvkptusjrmeuyxibu`
   - Click on it

4. **Wait for dashboard to load** (2-3 seconds)

---

### **Sub-Step 1.2: Open SQL Editor**

1. **Left sidebar → Click "SQL Editor"**
   - Should see a list of recent queries or empty

2. **Click "New Query" button** (top right)
   - A blank SQL editor appears

---

### **Sub-Step 1.3: Copy The Setup SQL**

**IMPORTANT:** You must copy the ENTIRE SQL file

1. **Open file:** `COMPLETE_DATABASE_AND_STORAGE_SETUP.sql`
   - Located in: `b:\sunr\`

2. **Select ALL content:**
   - `Ctrl+A` (select all)

3. **Copy:**
   - `Ctrl+C`

**Visual Check:**
- File has 736 lines
- Contains CREATE TABLE statements
- Contains CREATE FUNCTION statements
- Contains CREATE POLICY statements (RLS)

---

### **Sub-Step 1.4: Paste into SQL Editor**

1. **Click in the SQL Editor** (the text area in Supabase)

2. **Paste the code:**
   - `Ctrl+V`

3. **Verify:**
   - You should see the SQL code in the editor
   - Should have many lines of code
   - Should see table creation statements

---

### **Sub-Step 1.5: Execute the SQL**

1. **Click the "Run" button** (usually at bottom right, or top right)
   - OR press `Ctrl+Shift+Enter`

2. **Wait for execution** (30-60 seconds)
   - You'll see: "Executing query..."
   - Then: ✅ "Success" message with notification

3. **Expected Success Message:**
   ```
   Query executed successfully
   Execution time: X seconds
   ```

**If you see ✅ Success → Congratulations! All tables are created!**

---

### **✅ What Tables Were Created**

These 13 tables are now ready:

| Table Name | Purpose | Records |
|-----------|---------|---------|
| `admin_users` | Admin accounts | 0 |
| `services` | Services offered | 0 |
| `products` | Products for sale | 0 |
| `product_images` | Product photos | 0 |
| `reviews` | Customer reviews | 0 |
| `review_helpful_votes` | Review votes | 0 |
| `appointments` | Service appointments | 0 |
| `gallery` | Gallery images | 0 |
| `home_video` | Hero section video | 0 |
| `payment_configuration` | Payment settings | 0 |
| `orders` | Customer orders | 0 |
| `order_items` | Items in orders | 0 |
| `settings` | Website settings | 0 |

---

# STEP 2: INSERT SAMPLE DATA {#step-2-sample-data}

## **Task:** Add sample products, services, and gallery images

### **Sub-Step 2.1: Open New SQL Query**

1. **SQL Editor → Click "New Query"** (again)
   - A fresh, blank editor appears

---

### **Sub-Step 2.2: Copy Sample Data SQL**

1. **Open file:** `SAMPLE_DATA_SETUP.sql`
   - Located in: `b:\sunr\`

2. **Select ALL and Copy:**
   - `Ctrl+A` → `Ctrl+C`

**Visual Check:**
- File has ~305 lines
- Contains INSERT statements
- Contains sample services, products, gallery data

---

### **Sub-Step 2.3: Paste into SQL Editor**

1. **Click in the SQL Editor**

2. **Paste:**
   - `Ctrl+V`

3. **Verify:**
   - Should see INSERT statements
   - Should see service names (Bridal Makeup, Facial Treatment, etc.)
   - Should see product names (Moisturizing Face Cream, Anti-Acne Serum, etc.)

---

### **Sub-Step 2.4: Execute the SQL**

1. **Click "Run" button**
   - OR press `Ctrl+Shift+Enter`

2. **Wait for completion** (10-20 seconds)

3. **Expected Success:**
   ```
   Query executed successfully
   ```

---

### **✅ What Data Was Inserted**

After this step, your database has:

| Table | Sample Data |
|-------|------------|
| **services** | 5 beauty services with prices |
| **products** | 5 beauty products with descriptions |
| **gallery** | 5 gallery images for showcase |
| **home_video** | 1 YouTube video link |
| **reviews** | 5 approved reviews from customers |
| **payment_configuration** | Payment method settings |
| **settings** | Website settings (name, phone, address, hours, etc.) |

---

# STEP 3: CREATE STORAGE BUCKETS {#step-3-storage}

## **Task:** Create file storage buckets for images and videos

### **Sub-Step 3.1: Go to Storage Section**

1. **Supabase Dashboard → Left Sidebar**
   - Click on **"Storage"**
   - Should see a list of buckets (probably empty)

---

### **Sub-Step 3.2: Create Bucket #1 - "product-images"**

1. **Click "New Bucket"** (button)

2. **Enter bucket name:**
   ```
   product-images
   ```

3. **Check the box:** "Public bucket" ✓
   - (This allows public read access)

4. **Click "Create bucket"**

5. **Wait for confirmation** ✅

---

### **Sub-Step 3.3: Create Bucket #2 - "gallery-images"**

1. **Click "New Bucket"** (again)

2. **Enter bucket name:**
   ```
   gallery-images
   ```

3. **Check:** "Public bucket" ✓

4. **Click "Create bucket"**

---

### **Sub-Step 3.4: Create Bucket #3 - "videos"**

1. **Click "New Bucket"**

2. **Enter bucket name:**
   ```
   videos
   ```

3. **Check:** "Public bucket" ✓

4. **Click "Create bucket"**

---

### **Sub-Step 3.5: Create Bucket #4 - "service-images"**

1. **Click "New Bucket"**

2. **Enter bucket name:**
   ```
   service-images
   ```

3. **Check:** "Public bucket" ✓

4. **Click "Create bucket"**

---

### **Sub-Step 3.6: Create Bucket #5 - "transaction-screenshots"**

1. **Click "New Bucket"**

2. **Enter bucket name:**
   ```
   transaction-screenshots
   ```

3. **Check:** "Public bucket" ✓

4. **Click "Create bucket"**

---

### **✅ Buckets Created**

You now have 5 public storage buckets:

| Bucket | Purpose |
|--------|---------|
| `product-images` | Product photos |
| `gallery-images` | Gallery showcase images |
| `videos` | Video files |
| `service-images` | Service photos |
| `transaction-screenshots` | Payment proof images |

---

# STEP 4: SET UP RLS POLICIES {#step-4-rls}

## **Task:** Configure Row Level Security for storage buckets

### **Sub-Step 4.1: Go to Storage Policies**

1. **Supabase Dashboard → Storage**
   - Should see your 5 buckets listed

2. **For EACH bucket, click on it:**
   - A menu appears with "Policies" option

---

### **Sub-Step 4.2: Set Policy for "product-images"**

1. **Click on bucket:** `product-images`

2. **Click "Policies"** (or Settings)

3. **Create policy #1: Allow public read**
   - Click "New Policy"
   - Choose: **FOR SELECT**
   - Paste this:
   ```
   bucket_id = 'product-images'
   ```
   - Click "Save Policy"

4. **Create policy #2: Allow authenticated upload**
   - Click "New Policy"
   - Choose: **FOR INSERT**
   - Paste this:
   ```
   auth.role() = 'authenticated'
   AND bucket_id = 'product-images'
   ```
   - Click "Save Policy"

---

### **Sub-Step 4.3: Repeat for Other Buckets**

**Do the SAME thing for:**
- `gallery-images`
- `videos`
- `service-images`
- `transaction-screenshots`

For each bucket:
1. Click bucket name
2. Click "Policies"
3. Create 2 policies (SELECT for public, INSERT for authenticated)
4. Copy the bucket name in the policy condition

---

### **✅ Storage Security Configured**

All buckets now have:
- ✅ Public read access (anyone can view)
- ✅ Authenticated write access (admin can upload)

---

# STEP 5: VERIFY EVERYTHING {#step-5-verify}

## **Task:** Check that all setup is correct

### **Sub-Step 5.1: Verify Tables Exist**

1. **SQL Editor → New Query**

2. **Paste this command:**
   ```sql
   SELECT table_name FROM information_schema.tables 
   WHERE table_schema = 'public' 
   ORDER BY table_name;
   ```

3. **Click Run**

4. **Expected result:** Should list all 13 tables:
   - admin_users
   - appointments
   - gallery
   - home_video
   - order_items
   - orders
   - payment_configuration
   - product_images
   - products
   - review_helpful_votes
   - reviews
   - services
   - settings

---

### **Sub-Step 5.2: Verify Data Was Inserted**

1. **SQL Editor → New Query**

2. **Paste this command:**
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

3. **Click Run**

4. **Expected result:**
   ```
   services | 5
   products | 5
   gallery | 5
   reviews | 5
   payment_configuration | 1
   settings | 11
   home_video | 1
   ```

---

### **Sub-Step 5.3: Verify Storage Buckets**

1. **Supabase Dashboard → Storage**

2. **Should see 5 buckets listed:**
   - ✓ product-images
   - ✓ gallery-images
   - ✓ videos
   - ✓ service-images
   - ✓ transaction-screenshots

---

### **Sub-Step 5.4: Test Your Website**

1. **Open your website** in browser

2. **Hard refresh:** `Ctrl+Shift+R`

3. **Open Developer Console:** Press `F12`

4. **Check Console tab:**
   - Should see ✅ SUCCESS messages
   - Should see **NO red errors**
   - Should see services loading
   - Should see products loading
   - Should see gallery images

5. **Visual Check:**
   - Logo appears ✓
   - Services section has data ✓
   - Products section has data ✓
   - Gallery has images ✓
   - Reviews visible ✓

6. **Test Admin Login:**
   - Go to: `admin.html`
   - Email: `diwashb32@gmail.com`
   - Password: `dipak@121`
   - Should login successfully ✓

---

# TROUBLESHOOTING {#troubleshooting}

## Problem 1: "Table Already Exists" Error

**What it means:** Tables were already created

**Solution:** This is OK! Continue to Step 2

---

## Problem 2: "Syntax Error" When Running SQL

**What it means:** The SQL file didn't copy correctly

**Solution:**
1. Copy the file again carefully
2. Make sure you're copying the ENTIRE file
3. Check no text is cut off
4. Run again

---

## Problem 3: "Permission Denied" Error

**What it means:** RLS policies are blocking access

**Solution:**
1. Check RLS policies in SQL Editor
2. Run SAMPLE_DATA_SETUP.sql again
3. Verify policies allow public read

---

## Problem 4: Website Still Shows Errors After Setup

**What it means:** Data didn't load properly

**Solution:**
1. Hard refresh: `Ctrl+Shift+R`
2. Wait 5 seconds
3. Open console: `F12`
4. Check if specific errors remain
5. Verify all 5 sample data insertion steps completed

---

## Problem 5: Storage Buckets Not Working

**What it means:** Buckets weren't created or policies missing

**Solution:**
1. Verify 5 buckets exist in Storage section
2. Check each bucket has 2 policies
3. Re-create missing buckets
4. Re-add policies

---

## Problem 6: Admin Login Failing

**What it means:** Admin user not created

**Solution:**
1. In SQL Editor, create admin manually:
   ```sql
   INSERT INTO admin_users (email, name, role, is_active)
   VALUES ('diwashb32@gmail.com', 'Diwas', 'admin', true);
   ```
2. Try login again

---

## Problem 7: "Column does not exist" Error

**What it means:** Sample data SQL had issues

**Solution:**
1. Check database schema is correct
2. Verify all 13 tables created in Step 1
3. Re-run SAMPLE_DATA_SETUP.sql

---

## Problem 8: Service/Product Images Not Showing

**What it means:** Image URLs are broken

**Solution:**
1. This is OK for now (sample data uses placeholder URLs)
2. You can upload real images later via admin panel
3. Or update URLs in database to your image links

---

# SUMMARY CHECKLIST {#summary}

## ✅ After Completing All Steps:

- [ ] **Step 1:** All 13 tables created
- [ ] **Step 2:** Sample data inserted (5 services, 5 products, 5 gallery items, etc.)
- [ ] **Step 3:** 5 storage buckets created
- [ ] **Step 4:** RLS policies configured for all buckets
- [ ] **Step 5:** Verified everything works
- [ ] **Test:** Website loads with NO errors
- [ ] **Test:** Admin panel login works
- [ ] **Test:** Services/products/gallery display data

---

# FINAL VALIDATION {#validation}

## Run These 3 Checks Before Declaring Success:

### Check 1: Browse Website
```
1. Open: http://localhost:8000 (or your website URL)
2. Press: Ctrl+Shift+R (hard refresh)
3. Wait: 3-5 seconds
4. Check: No red errors in F12 console
5. Verify: Services, products, gallery have data
```

### Check 2: Admin Login
```
1. Go to: admin.html
2. Email: diwashb32@gmail.com
3. Password: dipak@121
4. Should: Login successfully
5. Should: See admin panel
```

### Check 3: Database Query
```
1. SQL Editor → New Query
2. Run: SELECT COUNT(*) FROM services;
3. Result: Should be 5
4. Run: SELECT COUNT(*) FROM products;
5. Result: Should be 5
```

---

## 🎉 SUCCESS!

If all checks pass, your database is **100% set up and ready to use!**

**No errors should appear when using the website.**

---

## 📞 Need Help?

If you get stuck:
1. Check the troubleshooting section above
2. Make sure you completed each step completely
3. Verify files are copied correctly
4. Check console errors for specific messages
5. Try hard refresh: `Ctrl+Shift+R`

---

**Setup Complete! Your website is ready to go!** 🚀

