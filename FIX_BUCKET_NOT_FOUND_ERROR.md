# Fix: Bucket Not Found Error - Category Images Upload

## ❌ Error
```
StorageApiError: Bucket not found
    at supabase.js:19:10413
```

**Cause:** The `category-images` bucket doesn't exist in Supabase Storage

---

## ✅ Solution: Create Storage Buckets

### Method 1: Create via Supabase Dashboard (Recommended)

#### Step 1: Go to Supabase Dashboard
1. Login to [Supabase](https://supabase.com)
2. Select your project
3. Click **Storage** in the left sidebar

#### Step 2: Create category-images Bucket
1. Click **Create a new bucket**
2. Enter bucket name: `category-images`
3. **Uncheck** "Make bucket private" (keep it **public**)
4. Click **Create bucket**

#### Step 3: Create Other Required Buckets
Create these buckets the same way (all public):
- `service-images` (for service/collection images)
- `product-images` (for product images)
- `gallery` (for gallery images)
- `product-photos` (for multi-image carousel)

### Bucket Configuration

| Bucket Name | Type | Purpose |
|------------|------|---------|
| `category-images` | Public | Category showcase images |
| `service-images` | Public | Service/collection images |
| `product-images` | Public | Product main images |
| `product-photos` | Public | Product carousel images (up to 4) |
| `gallery` | Public | Gallery images and videos |
| `payment-qr-images` | Public | Payment QR codes |

---

## 🔐 Bucket Policies (Row Level Security)

After creating buckets, you need to set up policies. Click on each bucket and set:

### For Each Bucket:
1. **Policies** tab
2. **New Policy**
3. **For queries only**
4. **Allow SELECT**
5. **authenticated role** OR **public**

### Recommended Policy:
```
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'category-images');
```

Or use the UI:
1. Click **New Policy**
2. Select **For SELECT**
3. Select **Public access**
4. Click **Save**

---

## Step-by-Step Screenshot Guide

### Step 1: Click Storage
```
Supabase Dashboard
└── Storage (left sidebar)
```

### Step 2: Create Bucket
```
Storage Dashboard
├── Click "Create a new bucket"
├── Name: category-images
├── Uncheck "Make bucket private"
└── Click "Create bucket"
```

### Step 3: Set Public Access
```
category-images bucket
├── Click "Policies" tab
├── Click "New Policy"
├── Select "For SELECT"
├── Select "Public access"
└── Click "Save"
```

---

## ✅ After Setup

### Verify Buckets Created
1. Go to Storage in Supabase
2. You should see:
   - ✅ category-images
   - ✅ service-images
   - ✅ product-images
   - ✅ gallery
   - ✅ product-photos

### Verify Policies Set
1. Click each bucket
2. Go to **Policies** tab
3. Should show **Public** policy

### Test Upload
1. Go to Admin Panel
2. Click Categories
3. Click "Add New Category"
4. Upload an image
5. Should work now! ✅

---

## 🔧 Troubleshooting

### Still Getting "Bucket not found"?
**Solution:**
1. Refresh the page (Ctrl+F5 or Cmd+Shift+R)
2. Wait 5-10 seconds after creating bucket
3. Clear browser cache
4. Try different bucket name

### Images Upload but Don't Display?
**Solution:**
1. Check bucket is set to **Public** (not private)
2. Verify policy allows **SELECT** (read) access
3. Check image URL format

### Policy Won't Save?
**Solution:**
1. Make sure you select role: **anon** or **authenticated**
2. Make sure you select **SELECT** operation
3. Retry or refresh page

---

## 📝 SQL Alternative (Advanced)

If you prefer SQL, paste this in Supabase SQL Editor:

```sql
-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "storage";

-- Note: Storage buckets must be created via dashboard UI
-- This SQL cannot create buckets, but here's documentation:

-- Manual steps in Supabase Dashboard:
-- 1. Go to Storage
-- 2. Create bucket: category-images (Public)
-- 3. Create bucket: product-images (Public)
-- 4. Create bucket: service-images (Public)
-- 5. Create bucket: gallery (Public)
-- 6. Create bucket: product-photos (Public)
-- 7. Set policies for each bucket to allow PUBLIC READ

-- After creating buckets, set policies via Dashboard:
-- For each bucket → Policies → New Policy → SELECT → Public
```

---

## 📋 Quick Checklist

After creating buckets, verify:

- [ ] `category-images` bucket exists
- [ ] `category-images` is **Public** (not private)
- [ ] `category-images` has **SELECT** policy
- [ ] Other buckets exist: product-images, service-images, gallery
- [ ] All buckets are **Public**
- [ ] All buckets have **SELECT** policies

---

## 🚀 Test the Fix

Once buckets are created:

1. **Refresh browser** (Ctrl+F5)
2. **Go to Admin Panel**
3. **Click Categories**
4. **Add New Category**
5. **Upload an image**
6. **Should work!** ✅

---

## 📸 Visual Guide

### Before (Error)
```
Admin Panel → Categories → Add New → Upload Image
❌ Error: Bucket not found
```

### After (Fixed)
```
Admin Panel → Categories → Add New → Upload Image
✅ Image uploads successfully
✅ Image displays on home page
```

---

## 💡 Why This Happens

1. **Your Supabase Storage** starts with no buckets
2. **Your code** tries to upload to `category-images` bucket
3. **Bucket doesn't exist** → Error!
4. **Solution:** Create the bucket in Supabase Dashboard

---

## 🎯 Complete Bucket Setup List

Create these buckets in Supabase (all should be **Public**):

```
1. category-images
   ├── Used for: Category images
   ├── Type: Public
   └── Policy: SELECT (public read)

2. product-images
   ├── Used for: Main product image
   ├── Type: Public
   └── Policy: SELECT (public read)

3. product-photos
   ├── Used for: Product carousel (4 images)
   ├── Type: Public
   └── Policy: SELECT (public read)

4. service-images
   ├── Used for: Service/collection images
   ├── Type: Public
   └── Policy: SELECT (public read)

5. gallery
   ├── Used for: Gallery images and videos
   ├── Type: Public
   └── Policy: SELECT (public read)

6. payment-qr-images
   ├── Used for: Payment QR codes
   ├── Type: Public
   └── Policy: SELECT (public read)
```

---

## ✅ You're Done!

Once you:
1. ✅ Create `category-images` bucket (Public)
2. ✅ Set policies to allow reads
3. ✅ Refresh your page

**Category image uploads will work!** 🎉

---

## 🆘 Still Having Issues?

1. **Check bucket name exactly:** `category-images` (lowercase, with hyphen)
2. **Check Public access:** Make sure "Private" is NOT checked
3. **Check policies:** Go to bucket → Policies → Should have a policy allowing reads
4. **Check Supabase connection:** Verify your Supabase URL and key are correct
5. **Clear cache:** Press Ctrl+Shift+Delete → Clear all

---

**Status:** Follow the steps above and your category image uploads will be fixed! ✅

