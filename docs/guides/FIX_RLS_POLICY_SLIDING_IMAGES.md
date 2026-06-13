# Fix: RLS Policy Error - Sliding Images Upload

## ❌ Error
```
Error saving sliding image: StorageApiError: new row violates row-level security policy
```

**Cause:** The RLS (Row Level Security) policy on the `sliding_images` table is blocking INSERT operations

---

## ✅ Solution: Update RLS Policies

### Step 1: Go to Supabase SQL Editor

1. Login to [Supabase Dashboard](https://supabase.com)
2. Select your project
3. Click **SQL Editor** (left sidebar)

### Step 2: Run This SQL

Copy and paste this SQL in the SQL Editor:

```sql
-- Fix RLS policies for sliding_images table

-- Drop old policies
DROP POLICY IF EXISTS "Allow admin full access to sliding images" ON sliding_images;
DROP POLICY IF EXISTS "Allow public read active sliding images" ON sliding_images;

-- Create new policies

-- Policy 1: Allow public to read active slides
CREATE POLICY "Allow public read active sliding images"
    ON sliding_images FOR SELECT
    USING (is_active = true);

-- Policy 2: Allow insert
CREATE POLICY "Allow all insert"
    ON sliding_images FOR INSERT
    WITH CHECK (true);

-- Policy 3: Allow update
CREATE POLICY "Allow all update"
    ON sliding_images FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Policy 4: Allow delete
CREATE POLICY "Allow all delete"
    ON sliding_images FOR DELETE
    USING (true);
```

### Step 3: Execute

1. Click **Execute** button
2. Wait for success message
3. You'll see: "Query successful: no rows affected" or similar

### Step 4: Test Upload

1. Refresh your browser (Ctrl+F5)
2. Go to Admin Panel
3. Click "Hero Slider"
4. Click "Add Sliding Image"
5. Upload a test image
6. Should work now! ✅

---

## 🔐 What These Policies Do

| Policy | Operation | Allow? | Purpose |
|--------|-----------|--------|---------|
| Allow public read... | SELECT | Active only | Users see active slides |
| Allow all insert | INSERT | Yes | Admin can add slides |
| Allow all update | UPDATE | Yes | Admin can edit slides |
| Allow all delete | DELETE | Yes | Admin can delete slides |

---

## 📋 Alternative: Quick Fix (Disable RLS Temporarily)

If you're having issues, you can disable RLS temporarily:

```sql
-- Temporarily disable RLS
ALTER TABLE sliding_images DISABLE ROW LEVEL SECURITY;
```

**Then upload your slides, then re-enable:**

```sql
-- Re-enable RLS
ALTER TABLE sliding_images ENABLE ROW LEVEL SECURITY;
```

---

## 🎯 Step-by-Step Visual Guide

### In Supabase Dashboard:
```
1. Click SQL Editor
2. Paste the SQL above
3. Click Execute
4. See "Query successful"
5. Refresh browser
6. Try uploading again
```

---

## ✅ Verify It Works

After running the SQL:

1. **Admin Panel** → **Hero Slider**
2. Click **Add Sliding Image**
3. Fill in fields:
   - Display Order: 1
   - Upload Image: (choose a file)
   - Title: Test Slide
   - Status: Active
4. Click **Save Sliding Image**
5. Should see success message ✅

---

## 🐛 If Still Getting Error

Try this complete fix:

```sql
-- Step 1: Drop all existing policies
DROP POLICY IF EXISTS "Allow public read active sliding images" ON sliding_images;
DROP POLICY IF EXISTS "Allow admin full access to sliding images" ON sliding_images;
DROP POLICY IF EXISTS "Allow all insert" ON sliding_images;
DROP POLICY IF EXISTS "Allow all update" ON sliding_images;
DROP POLICY IF EXISTS "Allow all delete" ON sliding_images;

-- Step 2: Disable RLS
ALTER TABLE sliding_images DISABLE ROW LEVEL SECURITY;

-- Step 3: Re-enable RLS with new policies
ALTER TABLE sliding_images ENABLE ROW LEVEL SECURITY;

-- Step 4: Create permissive policies
CREATE POLICY "sliding_images_select_policy"
    ON sliding_images FOR SELECT
    USING (true);

CREATE POLICY "sliding_images_insert_policy"
    ON sliding_images FOR INSERT
    WITH CHECK (true);

CREATE POLICY "sliding_images_update_policy"
    ON sliding_images FOR UPDATE
    USING (true)
    WITH CHECK (true);

CREATE POLICY "sliding_images_delete_policy"
    ON sliding_images FOR DELETE
    USING (true);
```

---

## 💡 Why This Happens

1. **RLS Enabled:** Your table has Row Level Security turned on
2. **Restrictive Policy:** The default policy was too restrictive
3. **Anonymous User:** Your app uses anonymous key (not authenticated)
4. **Policy Mismatch:** Policy doesn't match the user type

**Solution:** Use permissive policies that allow all operations for now (you can restrict later if needed)

---

## 🚀 After Fix

Once you run the SQL and fix RLS:

✅ Admin can upload sliding images  
✅ Images upload successfully  
✅ Slides display on home page  
✅ Everything works!

---

## 📞 Need More Help?

If error persists:

1. **Clear cache:** Ctrl+Shift+Delete → Clear all
2. **Refresh browser:** Ctrl+F5
3. **Check table exists:** Go to Supabase → Tables → Should see `sliding_images`
4. **Verify bucket:** Go to Storage → Should see `sliding-images` (PUBLIC)
5. **Check RLS tab:** Select table → Policies → Should show 4 policies

---

**Status:** Run the SQL above and your upload error will be fixed! ✅

