# Admin Video Upload - COMPLETE WORKING SETUP

## ✅ WHAT'S FIXED:

- ✓ Upload video from **URL** (paste any public video link)
- ✓ Upload video from **Device** (MP4/WebM/OGG files)
- ✓ Auto-detects which method you're using
- ✓ Verifies video is saved in database
- ✓ Video displays on home page after refresh

---

## 🚀 QUICK START (Choose One):

### **METHOD 1: Upload from URL (Fastest)**

1. **Get a video URL** (must start with `https://`)
   ```
   https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4
   ```

2. **Login to admin** → admin.html

3. **Find "Home Screen Video" section**

4. **Paste URL in "Video URL" field**

5. **Click "Save Video"**

6. **Wait for**: ✅ **"Video saved successfully!"**

7. **Go to home page** and press **Ctrl+F5** (hard refresh)

8. **Video appears!** 🎥

---

### **METHOD 2: Upload from Your Device**

1. **Login to admin** → admin.html

2. **Find "Home Screen Video" section**

3. **Click "Choose File"** button

4. **Select video file** from your computer (MP4, WebM, or OGG)

5. **Click "Save Video"**

6. **Wait for**: ✅ **"Video saved successfully!"**

7. **Go to home page** and press **Ctrl+F5** (hard refresh)

8. **Video appears!** 🎥

---

## 📝 Step-by-Step Walkthrough

### Admin Panel (Video Upload Section):

```
┌────────────────────────────────────┐
│  Home Screen Video                 │
│────────────────────────────────────│
│                                    │
│  Video URL:                        │
│  [https://example.com/video.mp4 ] ← Paste URL here
│                                    │
│  OR Upload Video File:             │
│  [Choose File]                  ← Or upload from device
│                                    │
│  [Save Video]                   ← Click to save
│                                    │
│  [Status message here]             │
│                                    │
└────────────────────────────────────┘
```

---

## 🧪 TEST IMMEDIATELY:

### Test Video URL (Copy & Paste):
```
https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4
```

**This is guaranteed to work!**

---

## ✨ How It Works:

1. **You enter video** (URL or file)
2. **Admin checks what you provided**
3. **If file:** Upload to Supabase Storage → Get public URL
4. **If URL:** Use the URL directly
5. **Save URL to settings table** in database
6. **Home page loads** and reads URL from settings
7. **Video displays** in hero section

---

## 🎯 Troubleshooting:

### Problem: "Error: Invalid file type"
**Solution:** Only MP4, WebM, and OGG files work. Convert your video to MP4.

### Problem: Video saves but doesn't appear
**Solution:** 
1. Hard refresh: **Ctrl+F5** (not just F5)
2. Clear cache: **Ctrl+Shift+Delete**
3. Check if video URL in database

### Problem: Upload fails
**Solution:**
1. Check file size (should be < 20 MB)
2. Try URL method instead
3. Check browser console (F12) for error

### Problem: "Video URL must start with https://"
**Solution:** Make sure your URL starts with `https://` (not `http://`)

---

## 📋 Video Requirements:

### For FILE upload:
- Format: MP4, WebM, or OGG
- Size: Less than 20 MB
- No special characters in filename

### For URL:
- Must start with `https://`
- Must be publicly accessible
- No authentication required
- MP4 format recommended

---

## 🔗 Free Video Sources:

Use these if you don't have your own video:

| Name | URL |
|------|-----|
| **BigBuckBunny** (TEST) | https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4 |
| **Sintel** | https://commondatastorage.googleapis.com/gtv-videos-library/sample/Sintel.mp4 |
| **ForBiggerBlaze** | https://storage.googleapis.com/gtv-videos-library/sample/ForBiggerBlaze.mp4 |
| **Pexels Videos** | https://www.pexels.com/videos/ |
| **Pixabay Videos** | https://pixabay.com/videos/ |

---

## 🎬 Expected Behavior:

### While Uploading:
- Message shows: "⏳ Processing video..."
- Then: "⏳ Uploading file..." (if file)
- Then: "⏳ Saving to database..."

### On Success:
- Green message: ✅ **"Video saved successfully!"**
- Then: ✅ **"Complete! Refresh home page (Ctrl+F5) to see your video."**

### On Home Page:
1. Refresh (Ctrl+F5)
2. See video playing in hero section
3. Text overlay on top
4. "Start Shopping" button
5. Video loops continuously

---

## 🔍 Verify It Worked:

### Check 1: Refresh Home Page
- Go to home page
- Press Ctrl+F5 (hard refresh)
- Do you see video?

### Check 2: Check Database
- Go to Supabase
- Click "settings" table
- Find row with `key = 'hero_video'`
- Check `hero_video_url` column has a value

### Check 3: Browser Console
- Go to home page
- Press F12 → Console
- Look for: "✓ Setting video source"
- Any error messages?

---

## 💡 Pro Tips:

1. **Test with BigBuckBunny URL first** to verify setup
2. **Always hard refresh** with Ctrl+F5 (not just F5)
3. **Check console** (F12) if something fails
4. **Keep videos short** (30-60 seconds ideal)
5. **Test file URL in browser** before saving

---

## 📞 If It Still Doesn't Work:

1. Check browser console (F12) for error messages
2. Verify video URL in settings table (Supabase)
3. Try the test URL first
4. Clear browser cache (Ctrl+Shift+Delete)
5. Try file upload instead of URL (or vice versa)

---

## ✅ Final Checklist:

- [ ] Admin panel loads without errors
- [ ] Can paste URL or select file
- [ ] Click "Save Video" shows success
- [ ] Hard refresh (Ctrl+F5) done on home page
- [ ] Video appears in hero section
- [ ] Video loops continuously
- [ ] No console errors (F12)

**If all checked, your setup is complete!** 🎉

