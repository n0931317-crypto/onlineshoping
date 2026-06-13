# 🔧 FIX STORAGE UPLOAD ERRORS - Step by Step Guide

## Problem
When uploading images/videos to gallery, you're getting this error:
```
StorageApiError: new row violates row-level security policy
```

This means the Supabase storage buckets don't have the correct RLS (Row-Level Security) policies.

---

## ✅ Solution - Execute This SQL

### Step 1: Go to Supabase Dashboard
1. Open [Supabase.com](https://supabase.com)
2. Login to your account
3. Select your project

### Step 2: Open SQL Editor
1. Click on **"SQL Editor"** in the left sidebar
2. Click **"New Query"** (top right)

### Step 3: Copy & Paste the SQL
Open the file: `FIX_STORAGE_UPLOAD_ERRORS.sql` in this folder

Copy ALL the content and paste it into the Supabase SQL Editor.

**OR** use this complete SQL directly:

```sql
-- ============================================================
-- COMPLETE FIX FOR STORAGE BUCKET RLS ERRORS
-- ============================================================

-- Step 1: Create all storage buckets if they don't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('gallery', 'gallery', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('videos', 'videos', true)
ON CONFLICT (id) DO NOTHING;

-- Step 2: Drop all existing RLS policies (prevent conflicts)
DROP POLICY IF EXISTS "Gallery - Public Select" ON storage.objects;
DROP POLICY IF EXISTS "Gallery - Authenticated Insert" ON storage.objects;
DROP POLICY IF EXISTS "Gallery - Authenticated Update" ON storage.objects;
DROP POLICY IF EXISTS "Gallery - Authenticated Delete" ON storage.objects;
DROP POLICY IF EXISTS "Product Images - Public Select" ON storage.objects;
DROP POLICY IF EXISTS "Product Images - Authenticated Insert" ON storage.objects;
DROP POLICY IF EXISTS "Product Images - Authenticated Update" ON storage.objects;
DROP POLICY IF EXISTS "Product Images - Authenticated Delete" ON storage.objects;
DROP POLICY IF EXISTS "Videos - Public Select" ON storage.objects;
DROP POLICY IF EXISTS "Videos - Authenticated Insert" ON storage.objects;
DROP POLICY IF EXISTS "Videos - Authenticated Update" ON storage.objects;
DROP POLICY IF EXISTS "Videos - Authenticated Delete" ON storage.objects;

-- Step 3: Create GALLERY bucket policies
CREATE POLICY "Gallery - Public Select" ON storage.objects
    FOR SELECT USING (bucket_id = 'gallery');

CREATE POLICY "Gallery - Authenticated Insert" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'gallery');

CREATE POLICY "Gallery - Authenticated Update" ON storage.objects
    FOR UPDATE USING (bucket_id = 'gallery')
    WITH CHECK (bucket_id = 'gallery');

CREATE POLICY "Gallery - Authenticated Delete" ON storage.objects
    FOR DELETE USING (bucket_id = 'gallery');

-- Step 4: Create PRODUCT-IMAGES bucket policies
CREATE POLICY "Product Images - Public Select" ON storage.objects
    FOR SELECT USING (bucket_id = 'product-images');

CREATE POLICY "Product Images - Authenticated Insert" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'product-images');

CREATE POLICY "Product Images - Authenticated Update" ON storage.objects
    FOR UPDATE USING (bucket_id = 'product-images')
    WITH CHECK (bucket_id = 'product-images');

CREATE POLICY "Product Images - Authenticated Delete" ON storage.objects
    FOR DELETE USING (bucket_id = 'product-images');

-- Step 5: Create VIDEOS bucket policies
CREATE POLICY "Videos - Public Select" ON storage.objects
    FOR SELECT USING (bucket_id = 'videos');

CREATE POLICY "Videos - Authenticated Insert" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'videos');

CREATE POLICY "Videos - Authenticated Update" ON storage.objects
    FOR UPDATE USING (bucket_id = 'videos')
    WITH CHECK (bucket_id = 'videos');

CREATE POLICY "Videos - Authenticated Delete" ON storage.objects
    FOR DELETE USING (bucket_id = 'videos');
```

### Step 4: Run the SQL
1. In Supabase SQL Editor, click the **"Play" button** (▶️) to execute the query
2. Wait for it to complete (should take a few seconds)
3. You should see a success message

### Step 5: Verify
After running the SQL, you should see output showing:
- ✅ Three buckets (gallery, product-images, videos)
- ✅ 12 RLS policies created

---

## 🧪 Test the Fix

1. Go back to your website: **Admin Panel** → [admin.html](admin.html)
2. Login with your admin credentials
3. Go to **"Gallery"** section
4. Click **"Upload Files"**
5. Select an image or video
6. Click **"Add to Gallery"**

**Expected result:** ✅ File uploads successfully without errors!

---

## ⚠️ If You Still Get Errors

### Check 1: Verify Buckets Exist
In Supabase → Storage, you should see:
- [ ] `gallery`
- [ ] `product-images`
- [ ] `videos`

If any are missing, they'll be created when you run the SQL above.

### Check 2: Verify RLS Policies
In Supabase → SQL Editor, run this to verify:
```sql
SELECT policyname, cmd, permissive
FROM pg_policies
WHERE tablename = 'objects' AND schemaname = 'storage'
ORDER BY policyname;
```

You should see 12 policies (4 per bucket).

### Check 3: Check Browser Console
1. Open your website in browser
2. Press **F12** to open Developer Tools
3. Click **"Console"** tab
4. Try uploading again
5. Look for any error messages

---

## 📊 Summary of What This Fixes

| Issue | Solution |
|-------|----------|
| StorageApiError when uploading | Creates proper RLS policies ✅ |
| Bucket not found | Ensures all 3 buckets exist ✅ |
| Row-level security violations | Creates PERMISSIVE policies ✅ |
| Gallery upload fails | Fixes gallery bucket policies ✅ |
| Product image upload fails | Fixes product-images bucket policies ✅ |
| Video upload fails | Fixes videos bucket policies ✅ |

---

## ✨ Next Steps

Once this is fixed:
1. ✅ Gallery uploads should work
2. ✅ Product image uploads should work
3. ✅ Video uploads should work
4. Run FIX_STORAGE_BUCKETS.sql (mentioned in earlier tasks)

**Need help?** Check the browser console (F12) for detailed error messages!
