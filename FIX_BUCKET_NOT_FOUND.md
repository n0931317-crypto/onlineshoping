# FIX: Bucket Not Found Error - Step by Step

## Problem
When uploading product or service images, you get:
- ❌ "StorageApiError: Bucket not found"
- ❌ "File upload error: Bucket not found"
- ❌ "new row violates row-level security policy"

## Root Causes
1. **Missing Buckets** - Buckets don't exist in Supabase Storage
2. **Missing RLS Policies** - Row Level Security policies not configured

---

## SOLUTION: Complete Setup in 3 Steps

### STEP 1: Create Storage Buckets in Supabase Dashboard

Go to **https://app.supabase.com** → Your Project → **Storage**

Create these 5 buckets:

| Bucket Name | Public? | Purpose |
|------------|---------|---------|
| `product-images` | ✅ Yes | Product catalog images |
| `service-images` | ✅ Yes | Service/appointment images |
| `gallery-images` | ✅ Yes | Fashion gallery showcase |
| `category-images` | ✅ Yes | Category thumbnails |
| `admin-files` | ❌ No | Admin documents (private) |

**How to create each bucket:**
1. Click **"New Bucket"**
2. Enter the bucket name (exactly as shown above)
3. Check/uncheck "Public bucket" as needed
4. Click **"Create bucket"**

---

### STEP 2: Configure RLS Policies

Go to **SQL Editor** in Supabase Dashboard

1. **Copy the entire content** from [BUCKET_FIX_COMPLETE.sql](BUCKET_FIX_COMPLETE.sql)

2. **Paste it** into the SQL Editor

3. **Click "Run"** to execute

This will:
- ✅ Enable RLS on storage
- ✅ Drop old/conflicting policies
- ✅ Create new policies for public image buckets
- ✅ Create new policies for private admin bucket

---

### STEP 3: Verify Setup

In SQL Editor, run these verification queries:

**Check buckets exist:**
```sql
SELECT id, name, public FROM storage.buckets;
```

Expected output:
```
id              | name            | public
----------------|-----------------|--------
prod...        | product-images  | true
serv...        | service-images  | true
gall...        | gallery-images  | true
cate...        | category-images | true
adm...         | admin-files     | false
```

**Check RLS policies:**
```sql
SELECT policyname, permissive 
FROM pg_policies 
WHERE schemaname = 'storage' AND tablename = 'objects'
ORDER BY policyname;
```

---

## Testing Upload

After setup, test uploading in your admin panel:

1. **Go to Add/Edit Service** → Upload image → Click "Choose File" → Select a PNG/JPG
2. **Go to Add/Edit Product** → Upload image → Click "Choose File" → Select a PNG/JPG
3. **Go to Gallery** → Upload images

You should see:
- ✅ "Service created successfully!"
- ✅ "Product created successfully!"
- ✅ Images display in the table

---

## Troubleshooting

### Still getting "Bucket not found"?
- [ ] Verify bucket name is **exactly** as listed (lowercase, with hyphens)
- [ ] Check that ALL 5 buckets exist in Storage
- [ ] Run the SQL script to set up RLS policies
- [ ] Wait 30 seconds and try again

### Still getting "RLS policy violation"?
- [ ] Make sure you're logged in (authenticated user)
- [ ] Run the SQL script again - policies may have been skipped
- [ ] Check that policies were created: Run verification query above
- [ ] Try clearing browser cache (Ctrl+Shift+Delete)

### Files upload but don't appear?
- [ ] Check that the bucket is marked as **Public**
- [ ] Verify file size is under the limit (50MB for products/services)
- [ ] Check browser console for the error details

---

## Code Changes Made ✅

The code is already configured to use the correct buckets:

```javascript
// service-images bucket
await uploadFile(imageFile, 'service-images')

// product-images bucket  
await uploadFile(imageFile, 'product-images')

// gallery-images bucket
await uploadFile(file, 'gallery-images')
```

No code changes needed - just create the buckets and set up RLS!

---

## Quick Checklist

- [ ] Created all 5 buckets in Supabase Storage
- [ ] Ran the SQL script to set up RLS policies
- [ ] Verified buckets exist with verification query
- [ ] Verified policies exist with verification query
- [ ] Tested uploading a product image
- [ ] Tested uploading a service image
- [ ] Tested uploading a gallery image
- [ ] All uploads successful! ✅
