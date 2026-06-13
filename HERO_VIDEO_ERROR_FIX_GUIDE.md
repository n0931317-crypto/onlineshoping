# Hero Video Upload - Complete Error Fix

## 🔴 Errors Solved

✅ **Error 1**: "StorageApiError: Bucket not found"
- **Cause**: `videos` bucket doesn't exist in Supabase Storage
- **Solution**: Create bucket in Supabase console

✅ **Error 2**: "StorageApiError: new row violates row-level security policy"
- **Cause**: Missing RLS write policies on settings table
- **Solution**: Run SQL to create proper RLS policies

✅ **Error 3**: Network 400/406 errors
- **Cause**: Invalid storage path and missing bucket
- **Solution**: Proper bucket setup with correct API path

---

## ✅ STEP-BY-STEP FIX

### STEP 1️⃣: Run SQL in Supabase Console (2 minutes)

1. Open your Supabase Project
2. Go to **SQL Editor**
3. Click **New Query**
4. Copy and paste the SQL from: **FIX_HERO_VIDEO_COMPLETE.sql**
5. Click **Run** (blue button)

✅ This will:
- Create `settings` table
- Create `home_video` table
- Enable RLS on both tables
- Add proper INSERT/UPDATE/DELETE policies

---

### STEP 2️⃣: Create Storage Bucket (2 minutes)

1. In Supabase, go to **Storage** (sidebar)
2. Click **Create a new bucket**
3. Name it exactly: `videos` (lowercase)
4. Toggle **"Make it public"** ON
5. Click **Create bucket**

✅ Bucket created successfully

---

### STEP 3️⃣: Set Storage Permissions (2 minutes)

In Supabase SQL Editor, run this to set storage policies:

```sql
-- Create bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('videos', 'videos', true)
ON CONFLICT (id) DO NOTHING;

-- Policy: Public can READ videos
CREATE POLICY "Public Access" ON storage.objects
    FOR SELECT USING (bucket_id = 'videos');

-- Policy: Authenticated can UPLOAD videos
CREATE POLICY "Authenticated Upload" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'videos' AND auth.role() = 'authenticated');

-- Policy: Authenticated can DELETE videos
CREATE POLICY "Authenticated Delete" ON storage.objects
    FOR DELETE USING (bucket_id = 'videos' AND auth.role() = 'authenticated');
```

✅ Storage policies are now set

---

### STEP 4️⃣: Test Video Upload (2 minutes)

1. Go to your website admin panel: **admin.html**
2. Find the **"Set Hero Video"** section
3. Either:
   - **Option A**: Paste a video URL (any public MP4 link)
   - **Option B**: Upload an MP4 file from your computer
4. Click **Upload Video**
5. Wait for ✓ "Video saved successfully!" message

✅ Video is now set and will appear on the home page!

---

## 🎥 Video Requirements

For best results, use these specs:

- **Format**: MP4 (most compatible)
- **Size**: 1-5 MB (smaller = faster loading)
- **Resolution**: 1920x1080 or higher
- **Aspect Ratio**: 16:9
- **Duration**: 30-60 seconds
- **Audio**: Muted (no sound on autoplay)

**Quick way to optimize video:**

```bash
# Windows: Install FFmpeg, then run:
ffmpeg -i original.mp4 -c:v libx264 -crf 28 -s 1920x1080 -c:a aac -b:a 96k hero-video.mp4
```

---

## 🧪 How to Test

### Option 1: Direct Upload
```
1. Admin Panel → Set Hero Video section
2. Upload or paste URL
3. Click "Upload Video"
4. See "✓ Video saved successfully!"
```

### Option 2: Check Database
```
Go to Supabase → settings table
Verify hero_video_url column has your video URL
```

### Option 3: View on Website
```
1. Go to your website home page (index.html)
2. Look at hero section
3. You should see the video playing
```

---

## 🔍 Troubleshooting

### Error: "Bucket not found"
**Solution**: 
- Create `videos` bucket in Supabase Storage (Step 2)
- Make sure it's set to PUBLIC

### Error: "RLS policy violation"
**Solution**:
- Run the SQL from FIX_HERO_VIDEO_COMPLETE.sql (Step 1)
- Make sure settings table has proper policies

### Error: "Invalid video format"
**Solution**:
- Use MP4 format only
- Check file size (should be < 5 MB)
- Re-encode video using FFmpeg

### Video doesn't show on homepage
**Solution**:
- Check browser console (F12) for errors
- Verify video URL is correct in settings table
- Check if video element exists in index.html
- Refresh browser cache (Ctrl+Shift+Delete)

---

## 📋 Database Tables Created

### `settings` Table
```
id: UUID (primary key)
key: TEXT (unique) - "hero_video"
hero_video_url: TEXT - Your video URL
description: TEXT
created_at: TIMESTAMP
updated_at: TIMESTAMP
```

### `home_video` Table (Optional, for backup)
```
id: UUID (primary key)
title: TEXT
video_url: TEXT
is_active: BOOLEAN
created_at: TIMESTAMP
updated_at: TIMESTAMP
```

---

## 🚀 Advanced: Custom Video Upload Form

If you want admins to have a better UI, the admin.js function `saveHomeVideo()` has been updated to:

✅ Validate video file type (MP4, WebM, OGG)
✅ Upload to correct storage bucket
✅ Get proper public URL automatically
✅ Save to settings table with correct RLS
✅ Show clear error messages
✅ Reload page on success

---

## 🎬 Video Sources

### Free Video Sites (Good for testing)
1. **Pexels Videos**: https://www.pexels.com/videos/
2. **Pixabay Videos**: https://pixabay.com/videos/
3. **Unsplash Videos**: https://unsplash.com/videos (requires account)
4. **Coverr**: https://coverr.co/

### Use for Commercial
Look for videos tagged "free commercial use"

---

## 📞 Support

If you still see errors:

1. **Check Console**: Press F12 → Console tab
2. **Look for**: Red error messages
3. **Common errors**:
   - "Bucket not found" → Create `videos` bucket
   - "RLS violation" → Run SQL from Step 1
   - "Invalid URL" → Check URL format (must start with https://)

---

## ✨ Success Indicators

After completing all steps, you should see:

✅ No errors in browser console
✅ Video playing on home page
✅ Video URL in settings table (Supabase)
✅ File in storage bucket (Supabase → Storage → videos)
✅ "✓ Video saved successfully!" message in admin

**You're all set! 🎉**
