# Hero Video - SIMPLE WORKING METHOD

## ✅ FASTEST WAY TO GET VIDEO WORKING

### Step 1: Copy This Test Video URL

```
https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4
```

### Step 2: Go to Admin Panel

1. Open **admin.html**
2. Login
3. Find **"Home Screen Video"** section
4. In the **"Video URL"** field, paste:
   ```
   https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4
   ```
5. Click **"Save Video"**
6. Wait for green message: ✅ **"Video URL saved successfully!"**

### Step 3: See Your Video

1. Go to **home page** (index.html)
2. Press **F5** to refresh
3. **Video should play in hero section!** 🎥

---

## 🎯 Use Your Own Video

Once the test video works, follow these steps:

### Option A: Find a Public Video URL

Use any public video URL that:
- Starts with `https://`
- Ends with `.mp4`
- Is publicly accessible

**Example sources:**
- YouTube (right-click → Copy video URL)
- Pexels: https://www.pexels.com/videos/
- Pixabay: https://pixabay.com/videos/
- Coverr: https://coverr.co/

### Option B: Manual Database Insert

If admin panel doesn't work, insert directly in Supabase:

1. Go to **Supabase** → **SQL Editor**
2. Run this:

```sql
-- Delete old entry if exists
DELETE FROM settings WHERE key = 'hero_video';

-- Insert new video URL
INSERT INTO settings (key, hero_video_url, description)
VALUES (
  'hero_video',
  'PASTE_YOUR_VIDEO_URL_HERE',
  'Hero section background video'
);

-- Verify it worked
SELECT * FROM settings WHERE key = 'hero_video';
```

3. Replace `PASTE_YOUR_VIDEO_URL_HERE` with your video URL
4. Click **Run**
5. Go to home page and refresh

---

## 🧪 Test Video URLs (All Working)

Use these to test your setup:

```
https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4
https://commondatastorage.googleapis.com/gtv-videos-library/sample/Sintel.mp4
https://storage.googleapis.com/gtv-videos-library/sample/ForBiggerBlaze.mp4
https://storage.googleapis.com/gtv-videos-library/sample/ElephantsDream.mp4
```

---

## ❌ If It Still Doesn't Work

### Check 1: Is Settings Table Set Up?

Run this in Supabase SQL Editor:

```sql
-- Check if settings table exists
SELECT * FROM settings LIMIT 10;

-- If it doesn't exist, create it:
CREATE TABLE IF NOT EXISTS settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT UNIQUE NOT NULL,
    hero_video_url TEXT,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert hero_video entry
INSERT INTO settings (key, hero_video_url, description)
VALUES ('hero_video', '', 'Hero section background video')
ON CONFLICT (key) DO NOTHING;
```

### Check 2: Is RLS Blocking?

Run this in Supabase SQL Editor:

```sql
-- Fix RLS policies
DROP POLICY IF EXISTS "Allow public read settings" ON settings;
DROP POLICY IF EXISTS "Allow authenticated users insert settings" ON settings;
DROP POLICY IF EXISTS "Allow authenticated users update settings" ON settings;

-- Create working policies
CREATE POLICY "Allow public read settings" ON settings
    FOR SELECT USING (true);

CREATE POLICY "Allow authenticated users insert settings" ON settings
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow authenticated users update settings" ON settings
    FOR UPDATE USING (true)
    WITH CHECK (true);
```

### Check 3: Browser Console

1. Go to home page
2. Press **F12** → **Console**
3. Look for error messages
4. Send me the error text

---

## 🚀 What Happens When It Works

Your home page will show:

```
┌─────────────────────────────────────────────────┐
│                                                 │
│    [VIDEO PLAYING AS BACKGROUND]                │
│                                                 │
│         Discover Premium Fabrics & Fashion      │
│          Explore exclusive collections          │
│                                                 │
│                [Start Shopping]                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 📋 Video URL Requirements

Your video URL MUST:

- ✅ Start with `https://`
- ✅ End with `.mp4`
- ✅ Be publicly accessible (no password)
- ✅ Support CORS (most do)
- ✅ Be under 50 MB (smaller = faster)

---

## 🎬 If You Have Your Own Video File

### Step 1: Upload to Free Service

- **Google Drive**: Upload → Share → Get link
- **Dropbox**: Upload → Share → Get link
- **AWS S3**: Upload → Make public → Get URL
- **Cloudinary**: Sign up → Upload → Get URL
- **Imgur**: Upload → Copy URL

### Step 2: Get Direct URL

Make sure you get the **direct download link**, not the sharing page.

Example:
- ❌ Wrong: `https://drive.google.com/file/d/1abc...`
- ✅ Right: `https://example.com/path/to/video.mp4`

### Step 3: Paste in Admin Panel

1. Copy the direct video URL
2. Go to admin.html
3. Paste URL
4. Click "Save Video"

---

## 💡 Pro Tips

1. **Start with test video** - Verify setup works first
2. **Use MP4 format** - Best compatibility
3. **Keep videos short** - 30-60 seconds ideal
4. **Mute audio** - Videos auto-mute anyway
5. **Test URL in browser** - Paste URL in address bar, should play

---

## 📞 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Video doesn't show | Refresh page (F5), not back button |
| Browser says "File not found" | URL might be wrong, test in address bar |
| Admin shows error | Check browser console (F12) |
| URL won't save | Try manual SQL insert method |
| Video saves but doesn't play | Make sure video file is MP4 format |

---

## ✨ Need More Help?

1. Try the **test video URL first**
2. Check **browser console** (F12) for errors
3. Verify **settings table** in Supabase
4. Try the **manual SQL insert** method

