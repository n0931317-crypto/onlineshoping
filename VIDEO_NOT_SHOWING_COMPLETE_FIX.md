# Hero Video Not Showing - Complete Fix Guide

## 🎯 What We're Doing:

Getting your uploaded video to display on the hero section background of your home page.

---

## ✅ STEP 1: Verify Video is Saved in Database

### Method A: Check Supabase Console (Easiest)

1. Go to **Supabase Project** → **Tables** (left sidebar)
2. Click on **settings** table
3. Look for a row with:
   - **key** column = `hero_video`
   - **hero_video_url** column = Your video URL (should start with `https://`)

**What you should see:**
```
key: hero_video
hero_video_url: https://qmvajxvilwreoftylnmk.supabase.co/storage/v1/object/public/videos/...
```

**If hero_video_url is empty:**
- The upload didn't save properly
- Go back to admin panel and try uploading again
- Use the test URL first: https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4

**If row doesn't exist:**
- Run this SQL in Supabase SQL Editor:
```sql
INSERT INTO settings (key, hero_video_url, description)
VALUES ('hero_video', 'https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4', 'Test video');
```

### Method B: Use Browser Console Diagnostic

1. Go to your **home page** (index.html)
2. Press **F12** to open Developer Tools
3. Go to **Console** tab
4. You'll see a diagnostic report showing:
   - ✓ Video element exists
   - ✓ Video URL from database
   - ✓ If URL is accessible
   - ✓ Any errors

---

## ✅ STEP 2: Understand the Video Upload Flow

### Current Process:

1. **Admin uploads video** → admin.html
2. **Video saved to:** settings table, hero_video_url column
3. **Home page loads** → index.html
4. **JavaScript queries database** → Gets video URL
5. **Sets video element src** → `<video src="URL">` 
6. **Video displays** in hero section

### Where it might fail:

❌ **Database save** → URL not saved
❌ **Database read** → Can't fetch URL
❌ **URL invalid** → Video not accessible
❌ **Video element** → Not displaying

---

## ✅ STEP 3: Test with Known-Working Video

Let's test with a guaranteed video that works:

### Test Video URL:
```
https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4
```

### Steps:

1. **Go to Supabase** → **settings** table
2. **Edit the hero_video row**
3. **Replace hero_video_url with:**
   ```
   https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4
   ```
4. **Click Update**
5. **Go to your home page**
6. **Press F5 to refresh**
7. **Video should appear!**

If this test video shows, your setup is correct. Then you can upload your own.

---

## ✅ STEP 4: Upload Your Own Video

Once test video works:

### Option A: Upload MP4 File

1. Go to **admin.html** (login if needed)
2. Find **"Home Screen Video"** section
3. Click **"Choose File"**
4. Select your MP4 video (1-5 MB recommended)
5. Click **"Save Video"**
6. Wait for: **"✓ Video saved successfully!"**
7. Go to home page and refresh (F5)

### Option B: Paste Video URL

1. Go to **admin.html**
2. In **"Video URL"** field, paste a public video link
3. Click **"Save Video"**
4. Check database to confirm it saved
5. Go to home page and refresh (F5)

---

## ✅ STEP 5: Browser Console Debugging

If video still doesn't show:

1. **Open home page** (index.html)
2. **Press F12** → **Console tab**
3. **Look for diagnostic output:**

```
=== VIDEO DIAGNOSTIC CHECK ===

✓ Video element exists: true
  - src: https://... (or empty)
  - display: block
  - z-index: 1
  - width: 1920
  - height: 1080

✓ Supabase available: true

📡 Querying settings table...
✓ Data retrieved: [{key: 'hero_video', hero_video_url: 'https://...'}]
✓ Video URL: https://...

🔗 Testing URL accessibility...
✓ URL is accessible: true (Status: 200)

=== END DIAGNOSTIC ===
```

### What each line means:

- ✓ = Good, working correctly
- ❌ = Problem, needs fixing
- ⚠ = Warning, might be issue

---

## 🔧 Common Problems & Solutions

### Problem 1: "Video element exists: true" but "src: (empty)"
**Cause:** URL not in database
**Fix:** 
1. Check settings table
2. If empty, manually insert test URL
3. Or upload again from admin panel

### Problem 2: "Data retrieved: []" (empty array)
**Cause:** settings table or hero_video row doesn't exist
**Fix:** Run SQL:
```sql
INSERT INTO settings (key, hero_video_url, description)
VALUES ('hero_video', 'https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4', 'Hero video');
```

### Problem 3: "URL is accessible: false"
**Cause:** Video URL is invalid or not public
**Fix:**
1. Test URL in browser address bar - does it play?
2. If not, use test URL instead
3. Ensure video is publicly accessible (not private)

### Problem 4: "Video element exists: false"
**Cause:** HTML doesn't have video element
**Fix:** Make sure index.html has:
```html
<video id="heroVideo" autoplay muted loop></video>
```

---

## 🎬 Video Format Requirements

Your video MUST be:

| Requirement | Value |
|------------|-------|
| Format | MP4 (.mp4) |
| Size | 1-5 MB |
| Resolution | 1920x1080 or higher |
| Aspect Ratio | 16:9 |
| Duration | 30-60 seconds |
| Codec | H.264 (standard MP4) |
| Audio | Muted (video won't have sound) |
| Access | Publicly accessible (https://) |

### How to compress video:

```bash
# Install FFmpeg first, then run:
ffmpeg -i original.mp4 -c:v libx264 -crf 28 -s 1920x1080 -c:a aac -b:a 96k output.mp4
```

---

## 🚀 Expected Result After Fix

Once working, home page will show:

1. **Hero section** with your video playing as background
2. **Text overlay** on top of video: "Discover Premium Fabrics & Fashion"
3. **"Start Shopping" button** on top of video
4. **Video loops** continuously
5. **No audio** (muted automatically)
6. **Works on mobile, tablet, desktop**

---

## 📋 Quick Checklist

Before assuming it's broken:

- [ ] Video saved to settings table (check database)
- [ ] hero_video_url has a value (not empty)
- [ ] URL starts with `https://`
- [ ] URL is publicly accessible (test in browser)
- [ ] Page is refreshed (F5, not just browser back button)
- [ ] Browser cache is cleared (Ctrl+Shift+Delete)
- [ ] Console shows "✓ Video element exists"
- [ ] Console shows video URL is not empty
- [ ] Test with known-working video first

---

## 🔗 Test URLs (Guaranteed to Work)

Use these to verify your setup works:

1. **BigBuckBunny.mp4** (8 sec, 4K)
```
https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4
```

2. **Sintel** (4 min, 1080p)
```
https://commondatastorage.googleapis.com/gtv-videos-library/sample/Sintel.mp4
```

3. **ForBiggerBlaze** (16 sec, 1080p)
```
https://storage.googleapis.com/gtv-videos-library/sample/ForBiggerBlaze.mp4
```

---

## 💡 Pro Tips

1. **Upload smaller videos** - Faster loading
2. **Use MP4 format** - Best compatibility
3. **Test URL before saving** - Copy URL to browser address bar, make sure it plays
4. **Clear browser cache** - Old versions might be cached
5. **Use test video first** - Verify setup works before uploading your video
6. **Check console often** - F12 Console shows exact error messages

---

## 📞 If Still Not Working:

1. **Clear everything** and start fresh:
   - Delete the hero_video row from settings table
   - Upload video again from admin panel
   - Refresh home page with Ctrl+F5

2. **Try test URL** from list above

3. **Check browser console** (F12) for actual error message

4. **Verify video URL is accessible** by pasting in browser address bar

5. **Check that modern-ecommerce.js is loading** (should appear in Network tab in F12)

