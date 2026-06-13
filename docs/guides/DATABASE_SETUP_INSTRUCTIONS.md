# 🚀 CRITICAL: Database Setup Required

## ⚠️ Current Issue
Your Supabase database is missing tables. The code is trying to query tables that don't exist yet.

---

## 🔧 STEP 1: Run Database Setup SQL

1. **Go to Supabase Console:**
   - Visit: https://app.supabase.com
   - Select your project: `znbxvkptusjrmeuyxibu`
   - Click **SQL Editor** (left sidebar)

2. **Create New Query:**
   - Click **New Query** button

3. **Copy and Paste SQL:**
   - Open file: `COMPLETE_DATABASE_AND_STORAGE_SETUP.sql`
   - Copy **ENTIRE CONTENT**
   - Paste into SQL Editor

4. **Execute:**
   - Click **Run** button
   - Wait for ✅ **Success** message

---

## 🔧 STEP 2: Insert Sample Data

1. **Create New Query** in SQL Editor
2. **Copy and Paste:**
   - Open file: `SAMPLE_DATA_SETUP.sql`
   - Copy **ENTIRE CONTENT**
   - Paste into SQL Editor
3. **Execute:** Click **Run** button
4. **Wait for ✅ Success**

---

## 🔧 STEP 3: Set Up Storage Buckets

1. **Go to Supabase Console**
2. **Click Storage** (left sidebar)
3. **Create these buckets** (if not exists):
   - `gallery` (public)
   - `products` (public)
   - `images` (public)
   - `videos` (public)

**To create a bucket:**
- Click **New Bucket**
- Enter name (e.g., `gallery`)
- Check **Public bucket**
- Click **Create**

---

## ✅ What Gets Created

**Tables:**
- ✅ services
- ✅ products
- ✅ reviews
- ✅ orders
- ✅ appointments
- ✅ gallery
- ✅ home_video
- ✅ payment_configuration
- ✅ admin_users
- ✅ and more...

**Storage Buckets:**
- ✅ gallery
- ✅ products
- ✅ images
- ✅ videos

---

## 🧪 Step 4: Test

1. **Hard Refresh:** `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
2. **Open Console:** Press `F12`
3. **Check:** Should see NO red errors
4. **Test Admin:** Try logging in with:
   - Email: `diwashb32@gmail.com`
   - Password: `dipak@121`

---

## 🆘 If Errors Still Appear

**Common Issues:**
1. **"Table does not exist"** → Run Step 1 again
2. **"Column does not exist"** → Run Step 1 again (tables might be partially created)
3. **"Bucket not found"** → Run Step 3 (create storage buckets)
4. **"Permission denied"** → Check RLS policies in Supabase

---

## 📝 Files Reference

| File | Purpose |
|------|---------|
| `COMPLETE_DATABASE_AND_STORAGE_SETUP.sql` | Creates all tables and RLS policies |
| `SAMPLE_DATA_SETUP.sql` | Inserts sample services, products, gallery items |
| `STORAGE_BUCKETS_SETUP.sql` | (Alternative) SQL to set up storage buckets |

---

**⏱️ Time to complete: ~5 minutes**

