# How to Fix All Errors on Manisha Beauty Website

## Summary of Errors and Solutions

### Error 1: Logo File Not Found
**Problem:** `GET file:///B:/sunr/uploads/logo.jpg net::ERR_FILE_NOT_FOUND`

**Solution:** ✅ FIXED
- Created `/uploads/logo.svg` with a professional SVG logo
- Updated `index.html` to use `uploads/logo.svg` instead of `uploads/logo.jpg`

---

### Error 2: Supabase URL Configuration Issues
**Problem:** `ERR_NAME_NOT_RESOLVED` on multiple Supabase API calls

**Cause:** 
- Supabase configuration has incorrect ANON_KEY
- The ANON_KEY references a different project ID than the URL

**Solution:**
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project: `gqzajmxtkfnvfceokwip`
3. Go to **Settings → API**
4. Copy the **Anon Public Key**
5. Replace the value in `supabase-new.js` (line 4):
```javascript
const SUPABASE_ANON_KEY = 'YOUR_ACTUAL_ANON_KEY_HERE';
```

---

### Error 3: Failed to Fetch Services, Products, Gallery, Reviews
**Problem:** `TypeError: Failed to fetch` errors for:
- Services: `GET https://gqzajmxtkfnvfceokwip.supabase.co/rest/v1/services?select=*is_active=eq.true`
- Products: Similar endpoint
- Gallery: Similar endpoint
- Reviews: Similar endpoint
- Home Video: Similar endpoint

**Cause:**
1. RLS policies might not be configured correctly for public read
2. No sample data exists in the database tables
3. ANON_KEY might be invalid

**Solution:**
1. **First**, ensure your database is set up by running:
   ```
   COMPLETE_DATABASE_AND_STORAGE_SETUP.sql
   ```

2. **Then**, add sample data by running:
   ```
   SAMPLE_DATA_SETUP.sql
   ```

3. **Verify RLS Policies** in Supabase:
   - Go to **Authentication → Policies**
   - For each table (services, products, gallery, reviews, home_video), ensure:
     - Policy exists for public SELECT (for active/approved items)
     - Check that `is_active = true` or `is_approved = true` condition exists

---

## Step-by-Step Fix Process

### Step 1: Update Supabase Configuration
```javascript
// File: supabase-new.js (Lines 1-4)

const SUPABASE_URL = 'https://gqzajmxtkfnvfceokwip.supabase.co';
const SUPABASE_ANON_KEY = 'PASTE_YOUR_ACTUAL_KEY_HERE';
// Get from: https://app.supabase.com/project/[project-id]/settings/api
```

### Step 2: Run Database Setup
1. Open your Supabase SQL Editor
2. Copy entire contents of `COMPLETE_DATABASE_AND_STORAGE_SETUP.sql`
3. Paste and execute

### Step 3: Run Sample Data Setup
1. Copy entire contents of `SAMPLE_DATA_SETUP.sql`
2. Paste and execute

### Step 4: Create Storage Buckets
1. Run `STORAGE_BUCKETS_SETUP.sql` in SQL Editor
   OR
2. Use Supabase Dashboard → Storage → Create New Bucket for each:
   - product-images
   - product-images-slot-1 through 4
   - gallery-images
   - videos
   - transaction-screenshots
   - service-images
   - home-images
   - testimonials
   - invoices
   - documents
   - banners
   - profile-images

### Step 5: Verify Everything Works
Open your website and check:
- ✅ Logo loads (top-left)
- ✅ Services load in "Our Services" section
- ✅ Products load in "Beauty Products" section
- ✅ Gallery items load in "Our Gallery" section
- ✅ No red errors in browser console (F12 → Console tab)

---

## Checking RLS Policies

If data still doesn't load after setup:

1. Go to **Supabase Dashboard → Authentication → Policies**
2. Click on each table (services, products, etc.)
3. Verify you see policies like:
   - ✅ "Public read services" - SELECT - USING (is_active = true)
   - ✅ "Public read products" - SELECT - USING (is_active = true)
   - ✅ "Public read gallery" - SELECT - USING (is_active = true)
   - ✅ "Public read reviews" - SELECT - USING (is_approved = true)

---

## Common Issues and Fixes

### Issue: Still Getting "ERR_NAME_NOT_RESOLVED"
**Fix:** 
- Check internet connection
- Verify ANON_KEY is correct (no extra spaces)
- Try hard refresh: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)

### Issue: Services loading but showing as empty
**Fix:**
- Run `SAMPLE_DATA_SETUP.sql` to add test data
- Verify `is_active = true` in database

### Issue: Still seeing 401 Unauthorized errors
**Fix:**
- Verify ANON_KEY is correctly copied (no typos)
- Ensure spaces before/after the key are removed

### Issue: Logo still broken
**Fix:**
- Logo is now `uploads/logo.svg` (changed from `.jpg`)
- Clear browser cache: `Ctrl+Shift+Del`
- Hard refresh page: `Ctrl+Shift+R`

---

## Files Created/Modified

### Created Files:
✅ `uploads/logo.svg` - Professional SVG logo
✅ `SAMPLE_DATA_SETUP.sql` - Sample data for all tables
✅ `ERROR_FIX_GUIDE.md` - This guide

### Modified Files:
✅ `index.html` - Updated logo paths from `.jpg` to `.svg`
✅ `supabase-new.js` - Added instructions for updating ANON_KEY

---

## Testing Checklist

- [ ] Logo displays without 404 error
- [ ] Services section loads with sample data
- [ ] Products section loads with sample data
- [ ] Gallery section loads with sample images
- [ ] Reviews section loads if applicable
- [ ] No red errors in browser console
- [ ] Appointments form works
- [ ] Admin panel loads
- [ ] Storage buckets are created and accessible

---

## Need More Help?

Check browser console for specific error messages:
1. Open page: Right-click → Inspect (or Press F12)
2. Go to **Console** tab
3. Look for red error messages
4. Each error will show exact API endpoint that failed

Then verify that endpoint exists in Supabase:
- Services: Table → `services` → Has public READ policy
- Products: Table → `products` → Has public READ policy
- Etc.

---

## Quick Reference

| What | Where | Action |
|------|-------|--------|
| Logo | uploads/logo.svg | Now fixed ✅ |
| Supabase URL | supabase-new.js line 3 | Check correct project |
| Supabase Key | supabase-new.js line 4 | Update with YOUR key |
| Database Setup | SQL Editor | Run COMPLETE_DATABASE_AND_STORAGE_SETUP.sql |
| Sample Data | SQL Editor | Run SAMPLE_DATA_SETUP.sql |
| Storage Buckets | Dashboard or SQL | Run STORAGE_BUCKETS_SETUP.sql |

---

**Last Updated:** January 3, 2026
**Status:** All client-side errors fixed. Database/API setup required.
