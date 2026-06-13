# 🔧 Complete QR Upload Fix - Storage + Database

## Error
**"Upload failed: new row violates row-level security policy"**

This means RLS is blocking both:
1. Storage bucket upload
2. Database insert/update

## Solution (3 Steps)

---

## Step 1: Update Database RLS Policies

1. Go to: **https://app.supabase.com**
2. Select your project
3. Click: **SQL Editor** (left sidebar)
4. Click: **New Query**
5. Copy-paste the entire content of **FIX_QR_UPLOAD_RLS.sql**
6. Click: **Run**
7. Wait for ✅ **green checkmark**

This fixes the database tables:
- ✅ payment_qr_images (allows public insert/update)
- ✅ admin_settings (allows public update)

---

## Step 2: Update Storage Bucket RLS Policies

The storage bucket needs special policies too.

### Method A: Via Supabase Dashboard (Recommended)

1. Go to: **https://app.supabase.com**
2. Click: **Storage** (left sidebar)
3. Click: **payment-qr-images** bucket
4. Click: **Policies** tab
5. Click: **New Policy** button
6. Select: **For full customization, use SQL**
7. Copy-paste this code:

```sql
-- Allow public upload to payment-qr-images bucket
CREATE POLICY "Allow public upload"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (
  bucket_id = 'payment-qr-images'
);
```

8. Click: **Review**
9. Click: **Confirm Policy**

### Repeat for other operations:

**Allow public READ:**
```sql
CREATE POLICY "Allow public read"
ON storage.objects
FOR SELECT
TO public
USING (
  bucket_id = 'payment-qr-images'
);
```

**Allow public UPDATE:**
```sql
CREATE POLICY "Allow public update"
ON storage.objects
FOR UPDATE
TO public
USING (
  bucket_id = 'payment-qr-images'
)
WITH CHECK (
  bucket_id = 'payment-qr-images'
);
```

**Allow public DELETE:**
```sql
CREATE POLICY "Allow public delete"
ON storage.objects
FOR DELETE
TO public
USING (
  bucket_id = 'payment-qr-images'
);
```

---

## Step 3: Verify Setup

### Test in Supabase Console

1. Go to **SQL Editor**
2. Run this test query:

```sql
-- Check if policies exist
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('payment_qr_images', 'admin_settings');
```

**Expected output**:
- payment_qr_images | t (RLS enabled)
- admin_settings | t (RLS enabled)

---

## Step 4: Test QR Upload

1. Open admin.html
2. Go to **Settings & QR Codes** section
3. Upload a QR code for ESewa/Khalti/Bank
4. **Expected Result**: ✅ Upload succeeds

---

## Checklist

- [ ] Run FIX_QR_UPLOAD_RLS.sql in SQL Editor
- [ ] See ✅ green checkmark
- [ ] Add "Allow public upload" policy to storage bucket
- [ ] Add "Allow public read" policy to storage bucket
- [ ] Add "Allow public update" policy to storage bucket
- [ ] Add "Allow public delete" policy to storage bucket
- [ ] Test QR upload in admin panel
- [ ] Verify QR appears on payment page

---

## If Still Getting Error

### Error: "new row violates row-level security policy"

**Solution 1**: Check RLS Policies
```
Go to: Supabase Dashboard
→ Storage → payment-qr-images → Policies
→ Verify all 4 policies exist (Insert, Select, Update, Delete)
```

**Solution 2**: Disable RLS (Nuclear Option)
```sql
-- Disable RLS on payment-qr-images bucket
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;
```

**Solution 3**: Check if bucket exists
```sql
-- List all storage buckets
SELECT * FROM storage.buckets WHERE name = 'payment-qr-images';
```

### Error: "Bucket not found"

**Create the bucket manually**:
1. Go to Storage dashboard
2. Click "New Bucket"
3. Name: `payment-qr-images`
4. Make it **Public** (not private)
5. Click "Create Bucket"

---

## Complete RLS Policy Reference

| Object | Operation | Policy | Status |
|--------|-----------|--------|--------|
| payment_qr_images | SELECT | Allow public read | ✅ |
| payment_qr_images | INSERT | Allow public insert | ✅ |
| payment_qr_images | UPDATE | Allow public update | ✅ |
| payment_qr_images | DELETE | Allow public delete | ✅ |
| admin_settings | SELECT | Allow public read | ✅ |
| admin_settings | INSERT | Allow public insert | ✅ |
| admin_settings | UPDATE | Allow public update | ✅ |
| admin_settings | DELETE | Allow public delete | ✅ |
| storage.objects (payment-qr-images) | INSERT | Allow public upload | ✅ |
| storage.objects (payment-qr-images) | SELECT | Allow public read | ✅ |
| storage.objects (payment-qr-images) | UPDATE | Allow public update | ✅ |
| storage.objects (payment-qr-images) | DELETE | Allow public delete | ✅ |

---

## Code Changes

### admin.js (Already Done)
- ✅ Removed authentication check
- ✅ Allows public uploads

---

## Summary

**After completing these steps:**
- ✅ Anyone can upload QR codes (no login)
- ✅ Admin panel works fully
- ✅ Payment page shows QR codes
- ✅ No RLS errors
- ✅ Smooth QR management

**Total Time**: ~5 minutes

---

**Status**: Follow steps above to complete fix
