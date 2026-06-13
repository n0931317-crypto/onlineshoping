# 🚀 QUICK FIX CARD - Storage Upload Errors

## Error You're Getting
```
❌ StorageApiError: new row violates row-level security policy
```

## ⏱️ Time to Fix: 2 Minutes

---

## 3 SIMPLE STEPS

### 1️⃣ Go to Supabase
- Open https://supabase.com
- Login → Select your project

### 2️⃣ Open SQL Editor
- Click **"SQL Editor"** (left sidebar)
- Click **"New Query"** (top right)

### 3️⃣ Copy & Run This SQL
```sql
INSERT INTO storage.buckets (id, name, public) VALUES ('gallery', 'gallery', true) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('product-images', 'product-images', true) ON CONFLICT (id) DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('videos', 'videos', true) ON CONFLICT (id) DO NOTHING;
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
CREATE POLICY "Gallery - Public Select" ON storage.objects FOR SELECT USING (bucket_id = 'gallery');
CREATE POLICY "Gallery - Authenticated Insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'gallery');
CREATE POLICY "Gallery - Authenticated Update" ON storage.objects FOR UPDATE USING (bucket_id = 'gallery') WITH CHECK (bucket_id = 'gallery');
CREATE POLICY "Gallery - Authenticated Delete" ON storage.objects FOR DELETE USING (bucket_id = 'gallery');
CREATE POLICY "Product Images - Public Select" ON storage.objects FOR SELECT USING (bucket_id = 'product-images');
CREATE POLICY "Product Images - Authenticated Insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'product-images');
CREATE POLICY "Product Images - Authenticated Update" ON storage.objects FOR UPDATE USING (bucket_id = 'product-images') WITH CHECK (bucket_id = 'product-images');
CREATE POLICY "Product Images - Authenticated Delete" ON storage.objects FOR DELETE USING (bucket_id = 'product-images');
CREATE POLICY "Videos - Public Select" ON storage.objects FOR SELECT USING (bucket_id = 'videos');
CREATE POLICY "Videos - Authenticated Insert" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'videos');
CREATE POLICY "Videos - Authenticated Update" ON storage.objects FOR UPDATE USING (bucket_id = 'videos') WITH CHECK (bucket_id = 'videos');
CREATE POLICY "Videos - Authenticated Delete" ON storage.objects FOR DELETE USING (bucket_id = 'videos');
SELECT id, name, public FROM storage.buckets WHERE id IN ('gallery', 'product-images', 'videos');
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'objects' AND schemaname = 'storage' ORDER BY policyname;
```

4️⃣ Click **Play ▶️** button

---

## ✅ What This Does
- ✅ Creates 3 storage buckets (gallery, product-images, videos)
- ✅ Creates 12 RLS security policies (4 per bucket)
- ✅ Allows authenticated users to upload files
- ✅ Allows public viewing of files

---

## 🧪 Test It
1. Go to **Admin** → **Gallery**
2. Click **"Upload Files"**
3. Select an image → Upload
4. **Should work now! ✅**

---

## 📝 File Reference
| File | Purpose |
|------|---------|
| [QUICK_FIX_STORAGE_RLS.sql](QUICK_FIX_STORAGE_RLS.sql) | Quick SQL (minimal, clean) |
| [FIX_STORAGE_UPLOAD_ERRORS.sql](FIX_STORAGE_UPLOAD_ERRORS.sql) | Full SQL (with comments) |
| [FIX_STORAGE_UPLOAD_ERRORS_GUIDE.md](FIX_STORAGE_UPLOAD_ERRORS_GUIDE.md) | Detailed guide |

---

## ❓ Still Not Working?
1. Check browser console (F12)
2. Look for error messages
3. Make sure you ran ALL the SQL (didn't skip lines)
4. Refresh browser and try again
