# ⚡ QR Upload Fix - Quick Card

## Problem
```
Error: Upload failed: new row violates row-level security policy
```

## Fix (2 Parts)

### Part 1: Database RLS (SQL Editor)
```
1. Supabase Dashboard
2. SQL Editor → New Query
3. Paste: FIX_QR_UPLOAD_RLS.sql
4. Click: Run
5. See: ✅ Green checkmark
```

### Part 2: Storage Bucket RLS (Storage Tab)
```
1. Storage → payment-qr-images
2. Click: Policies
3. Add 4 policies:
   ✅ Allow public upload (INSERT)
   ✅ Allow public read (SELECT)
   ✅ Allow public update (UPDATE)
   ✅ Allow public delete (DELETE)
```

---

## Policies to Add

### For Database Tables (SQL Editor)
✅ Already in FIX_QR_UPLOAD_RLS.sql - Just run it!

### For Storage Bucket (Storage → Policies)

**Policy 1: Upload**
```sql
CREATE POLICY "Allow public upload"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'payment-qr-images');
```

**Policy 2: Read**
```sql
CREATE POLICY "Allow public read"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'payment-qr-images');
```

**Policy 3: Update**
```sql
CREATE POLICY "Allow public update"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'payment-qr-images')
WITH CHECK (bucket_id = 'payment-qr-images');
```

**Policy 4: Delete**
```sql
CREATE POLICY "Allow public delete"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'payment-qr-images');
```

---

## Verify It Works

```
✅ Run test in SQL Editor:
SELECT * FROM public.payment_qr_images;

✅ Check Storage bucket has 4 policies

✅ Try uploading QR in admin panel

✅ Should succeed without errors!
```

---

## Result
- ✅ QR uploads work
- ✅ No authentication needed
- ✅ Admin panel fully functional
- ✅ Payment page shows QR

**Done!** 🎉
