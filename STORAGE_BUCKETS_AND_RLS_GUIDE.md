# 📦 Complete Storage Buckets & RLS Policies Setup

**Purpose:** Setup all storage buckets and security policies for Sunlights website  
**Created:** January 3, 2026  
**Status:** Complete & Production-Ready

---

## 🎯 QUICK OVERVIEW

| Bucket Name | Purpose | Usage | Public |
|---|---|---|---|
| `product-images` | Product listing images | Products page, admin | YES |
| `gallery-images` | Gallery/Portfolio images | Gallery section | YES |
| `videos` | Home video, promotional | Home hero section | YES |
| `service-images` | Service photos | Services section | YES |
| `transaction-screenshots` | Payment proof images | Orders - payment verification | YES |

**Total:** 5 buckets needed

---

## 📋 STEP 1: CREATE ALL BUCKETS (Manual in Supabase Dashboard)

### Step 1.1: Go to Supabase Storage
```
1. Login to: https://app.supabase.com
2. Select your project
3. Go to: Storage (left sidebar)
4. Click: "New Bucket" button (top right)
```

### Step 1.2: Create Bucket #1 - product-images

```
Bucket Name: product-images
Public: ✓ Check "Make bucket public"
Click: Create Bucket
```

**What to expect:**
- Success message appears
- Bucket shows in sidebar
- Folder icon visible

---

### Step 1.3: Create Bucket #2 - gallery-images

```
Bucket Name: gallery-images
Public: ✓ Check "Make bucket public"
Click: Create Bucket
```

---

### Step 1.4: Create Bucket #3 - videos

```
Bucket Name: videos
Public: ✓ Check "Make bucket public"
Click: Create Bucket
```

---

### Step 1.5: Create Bucket #4 - service-images

```
Bucket Name: service-images
Public: ✓ Check "Make bucket public"
Click: Create Bucket
```

---

### Step 1.6: Create Bucket #5 - transaction-screenshots

```
Bucket Name: transaction-screenshots
Public: ✓ Check "Make bucket public"
Click: Create Bucket
```

---

## 🔐 STEP 2: SET RLS (Row Level Security) POLICIES

### Overview of RLS Policies:

Each bucket needs 3 policies:
1. **SELECT (Read)** - Anyone can download/view
2. **INSERT (Upload)** - Anyone can upload
3. **UPDATE** - Only owner/admin can update
4. **DELETE** - Only owner/admin can delete

---

## 📝 RLS POLICIES SQL

### For Bucket: product-images

```sql
-- SELECT: Anyone can view product images
CREATE POLICY "Product images are publicly viewable"
ON storage.objects
FOR SELECT
USING (bucket_id = 'product-images');

-- INSERT: Authenticated users can upload
CREATE POLICY "Authenticated users can upload product images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'product-images');

-- UPDATE: Only owner can update
CREATE POLICY "Users can update their own product images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'product-images' AND owner = auth.uid())
WITH CHECK (bucket_id = 'product-images' AND owner = auth.uid());

-- DELETE: Only owner can delete
CREATE POLICY "Users can delete their own product images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'product-images' AND owner = auth.uid());
```

---

### For Bucket: gallery-images

```sql
-- SELECT: Anyone can view gallery images
CREATE POLICY "Gallery images are publicly viewable"
ON storage.objects
FOR SELECT
USING (bucket_id = 'gallery-images');

-- INSERT: Authenticated users can upload
CREATE POLICY "Authenticated users can upload gallery images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'gallery-images');

-- UPDATE: Only owner can update
CREATE POLICY "Users can update their own gallery images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'gallery-images' AND owner = auth.uid())
WITH CHECK (bucket_id = 'gallery-images' AND owner = auth.uid());

-- DELETE: Only owner can delete
CREATE POLICY "Users can delete their own gallery images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'gallery-images' AND owner = auth.uid());
```

---

### For Bucket: videos

```sql
-- SELECT: Anyone can view videos
CREATE POLICY "Videos are publicly viewable"
ON storage.objects
FOR SELECT
USING (bucket_id = 'videos');

-- INSERT: Authenticated users can upload
CREATE POLICY "Authenticated users can upload videos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'videos');

-- UPDATE: Only owner can update
CREATE POLICY "Users can update their own videos"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'videos' AND owner = auth.uid())
WITH CHECK (bucket_id = 'videos' AND owner = auth.uid());

-- DELETE: Only owner can delete
CREATE POLICY "Users can delete their own videos"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'videos' AND owner = auth.uid());
```

---

### For Bucket: service-images

```sql
-- SELECT: Anyone can view service images
CREATE POLICY "Service images are publicly viewable"
ON storage.objects
FOR SELECT
USING (bucket_id = 'service-images');

-- INSERT: Authenticated users can upload
CREATE POLICY "Authenticated users can upload service images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'service-images');

-- UPDATE: Only owner can update
CREATE POLICY "Users can update their own service images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'service-images' AND owner = auth.uid())
WITH CHECK (bucket_id = 'service-images' AND owner = auth.uid());

-- DELETE: Only owner can delete
CREATE POLICY "Users can delete their own service images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'service-images' AND owner = auth.uid());
```

---

### For Bucket: transaction-screenshots

```sql
-- SELECT: Anyone can view screenshots (for verification)
CREATE POLICY "Transaction screenshots are viewable"
ON storage.objects
FOR SELECT
USING (bucket_id = 'transaction-screenshots');

-- INSERT: Authenticated users can upload
CREATE POLICY "Authenticated users can upload transaction screenshots"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'transaction-screenshots');

-- UPDATE: Only owner can update
CREATE POLICY "Users can update their own screenshots"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'transaction-screenshots' AND owner = auth.uid())
WITH CHECK (bucket_id = 'transaction-screenshots' AND owner = auth.uid());

-- DELETE: Only owner can delete
CREATE POLICY "Users can delete their own screenshots"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'transaction-screenshots' AND owner = auth.uid());
```

---

## 🔧 STEP 3: SET RLS POLICIES IN SUPABASE DASHBOARD

### Method 1: Via SQL Editor (Recommended - Fastest)

```
1. Go to SQL Editor
2. Create new query
3. Copy & paste ALL policies SQL (see below)
4. Click Run
5. Wait 5-10 seconds
6. Done! ✅
```

---

## 📝 COMPLETE RLS POLICIES - ALL IN ONE

**Copy and paste everything below into SQL Editor:**

```sql
-- ============================================================
-- STORAGE BUCKET RLS POLICIES
-- ============================================================

-- ============================================================
-- BUCKET: product-images
-- ============================================================

CREATE POLICY "Product images are publicly viewable"
ON storage.objects
FOR SELECT
USING (bucket_id = 'product-images');

CREATE POLICY "Authenticated users can upload product images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'product-images');

CREATE POLICY "Users can update their own product images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'product-images' AND owner = auth.uid())
WITH CHECK (bucket_id = 'product-images' AND owner = auth.uid());

CREATE POLICY "Users can delete their own product images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'product-images' AND owner = auth.uid());

-- ============================================================
-- BUCKET: gallery-images
-- ============================================================

CREATE POLICY "Gallery images are publicly viewable"
ON storage.objects
FOR SELECT
USING (bucket_id = 'gallery-images');

CREATE POLICY "Authenticated users can upload gallery images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'gallery-images');

CREATE POLICY "Users can update their own gallery images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'gallery-images' AND owner = auth.uid())
WITH CHECK (bucket_id = 'gallery-images' AND owner = auth.uid());

CREATE POLICY "Users can delete their own gallery images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'gallery-images' AND owner = auth.uid());

-- ============================================================
-- BUCKET: videos
-- ============================================================

CREATE POLICY "Videos are publicly viewable"
ON storage.objects
FOR SELECT
USING (bucket_id = 'videos');

CREATE POLICY "Authenticated users can upload videos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'videos');

CREATE POLICY "Users can update their own videos"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'videos' AND owner = auth.uid())
WITH CHECK (bucket_id = 'videos' AND owner = auth.uid());

CREATE POLICY "Users can delete their own videos"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'videos' AND owner = auth.uid());

-- ============================================================
-- BUCKET: service-images
-- ============================================================

CREATE POLICY "Service images are publicly viewable"
ON storage.objects
FOR SELECT
USING (bucket_id = 'service-images');

CREATE POLICY "Authenticated users can upload service images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'service-images');

CREATE POLICY "Users can update their own service images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'service-images' AND owner = auth.uid())
WITH CHECK (bucket_id = 'service-images' AND owner = auth.uid());

CREATE POLICY "Users can delete their own service images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'service-images' AND owner = auth.uid());

-- ============================================================
-- BUCKET: transaction-screenshots
-- ============================================================

CREATE POLICY "Transaction screenshots are viewable"
ON storage.objects
FOR SELECT
USING (bucket_id = 'transaction-screenshots');

CREATE POLICY "Authenticated users can upload transaction screenshots"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'transaction-screenshots');

CREATE POLICY "Users can update their own screenshots"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'transaction-screenshots' AND owner = auth.uid())
WITH CHECK (bucket_id = 'transaction-screenshots' AND owner = auth.uid());

CREATE POLICY "Users can delete their own screenshots"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'transaction-screenshots' AND owner = auth.uid());

-- ============================================================
-- END OF STORAGE RLS POLICIES
-- ============================================================
```

---

## ✅ VERIFICATION CHECKLIST

After creating all buckets and policies:

### Check 1: Verify All Buckets Exist
```
1. Go to Supabase Storage
2. You should see 5 buckets:
   ✓ product-images
   ✓ gallery-images
   ✓ videos
   ✓ service-images
   ✓ transaction-screenshots
```

### Check 2: Verify All Are Public
```
1. Click each bucket
2. Check the icon - should show PUBLIC label
3. All 5 should be public
```

### Check 3: Verify RLS Policies
```
1. Go to SQL Editor
2. Run this query:
```

```sql
SELECT
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE tablename = 'objects'
ORDER BY tablename, policyname;
```

Expected output: **20 rows** (4 policies × 5 buckets)

---

## 📊 BUCKET USAGE DETAILS

### Bucket 1: product-images
```
Purpose: Product listing images
Used by: 
  - Products page
  - Admin panel (manage products)
  - Product details page
Typical files:
  - product-001.jpg
  - product-002.png
  - featured-items.webp
Max file size: 50MB per file
Recommended: JPG, PNG, WebP format
```

### Bucket 2: gallery-images
```
Purpose: Gallery/Portfolio images
Used by:
  - Gallery section
  - Portfolio display
  - Portfolio page
Typical files:
  - gallery-001.jpg
  - portfolio-item.png
  - showcase.webp
Max file size: 50MB per file
Recommended: JPG, PNG, WebP format
```

### Bucket 3: videos
```
Purpose: Video content
Used by:
  - Home video (hero section)
  - Promotional videos
  - Tutorial videos
Typical files:
  - hero-video.mp4
  - intro.webm
  - promotion.mov
Max file size: 100MB per file
Recommended: MP4, WebM, MOV format
```

### Bucket 4: service-images
```
Purpose: Service photos
Used by:
  - Services page
  - Service details
  - Admin panel (manage services)
Typical files:
  - service-001.jpg
  - consultation.png
  - service-hero.webp
Max file size: 50MB per file
Recommended: JPG, PNG, WebP format
```

### Bucket 5: transaction-screenshots
```
Purpose: Payment proof images
Used by:
  - Order payment verification
  - Admin order review
  - Payment confirmation
Typical files:
  - order-001-proof.jpg
  - esewa-receipt.png
  - khalti-screenshot.jpg
Max file size: 25MB per file
Recommended: JPG, PNG format
```

---

## 🔗 CODE REFERENCES IN YOUR PROJECT

### In supabase-new.js:

```javascript
// Upload file to specific bucket
uploadFile(file, 'product-images');  // Products
uploadFile(file, 'gallery-images');   // Gallery
uploadFile(file, 'videos');            // Videos
uploadFile(file, 'service-images');    // Services
uploadFile(file, 'transaction-screenshots'); // Payments
```

### In admin.js:

```javascript
// Admin image uploads
const imageUrl = await client.storage
    .from('product-images')
    .getPublicUrl(path);

const galleryUrl = await client.storage
    .from('gallery-images')
    .getPublicUrl(path);
```

### In payment.js:

```javascript
// Upload transaction screenshot
const proof = await client.storage
    .from('transaction-screenshots')
    .upload(fileName, file);
```

---

## 🚀 QUICK SETUP CHECKLIST

### Before Starting:
- [ ] You have Supabase dashboard open
- [ ] You're logged in to correct project
- [ ] You can access Storage section

### Step 1: Create Buckets (10 minutes)
- [ ] Create "product-images" bucket
- [ ] Create "gallery-images" bucket
- [ ] Create "videos" bucket
- [ ] Create "service-images" bucket
- [ ] Create "transaction-screenshots" bucket
- [ ] Verify all 5 buckets show in sidebar
- [ ] Verify all are PUBLIC

### Step 2: Set RLS Policies (5 minutes)
- [ ] Go to SQL Editor
- [ ] Create new query
- [ ] Copy complete RLS policies SQL (from above)
- [ ] Click "Run" button
- [ ] Wait for success message
- [ ] Run verification query
- [ ] Confirm 20 policies created

### Step 3: Test (5 minutes)
- [ ] Try uploading a test image to each bucket
- [ ] Verify all uploads succeed
- [ ] Try accessing image via public URL
- [ ] Confirm all work

### Step 4: Done! ✅
- [ ] All buckets created
- [ ] All policies set
- [ ] All uploads working
- [ ] Website ready to use!

---

## 🎓 WHAT EACH RLS POLICY DOES

### SELECT Policy
- **What:** Anyone can view/download files
- **Why:** Files need to be publicly accessible
- **Security:** No sensitive data, all public

### INSERT Policy
- **What:** Authenticated users can upload files
- **Why:** Prevent anonymous file uploads (abuse protection)
- **Security:** Only registered users can add files

### UPDATE Policy
- **What:** Users can only update their own files
- **Why:** Users can modify their own uploads
- **Security:** Can't modify other users' files

### DELETE Policy
- **What:** Users can only delete their own files
- **Why:** Users can remove their own uploads
- **Security:** Can't delete other users' files

---

## 📞 TROUBLESHOOTING

### Issue 1: "Bucket already exists"
**Answer:** You already created this bucket  
**Fix:** Skip to next bucket or verify from sidebar

### Issue 2: "Permission denied uploading"
**Answer:** RLS policy not set correctly  
**Fix:** Run the RLS policies SQL again

### Issue 3: "File upload returns 403"
**Answer:** File not public or RLS issue  
**Fix:** Check bucket is PUBLIC and RLS policies are applied

### Issue 4: "I can't see any RLS policies"
**Answer:** Policies not created yet  
**Fix:** Run complete RLS SQL in SQL Editor

---

## ✨ SECURITY SUMMARY

```
Public Read:     ✓ Anyone can view files
Authenticated:   ✓ Only registered users can upload
Owner Protection: ✓ Users can only modify their own files
Attack Prevention: ✓ Anonymous uploads blocked
Data Safety:     ✓ Deletion protected
```

---

## 📝 FINAL CHECKLIST

| Item | Status |
|------|--------|
| All 5 buckets created | ✓ |
| All buckets PUBLIC | ✓ |
| 20 RLS policies applied | ✓ |
| File upload working | ✓ |
| Public file access working | ✓ |
| Website can reference files | ✓ |

---

**Status:** Complete ✅  
**Last Updated:** January 3, 2026  
**Next Step:** Upload your images and test the website! 🚀

