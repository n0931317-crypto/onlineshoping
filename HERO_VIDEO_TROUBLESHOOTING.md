# Hero Video Not Showing - Troubleshooting Guide

## 🔴 Problems Fixed:

1. **Automatic logout after save** - ✅ Fixed (removed page reload)
2. **Video not displaying** - Need to verify URL is saved

## ✅ Step-by-Step Fix:

### Step 1: Verify Video URL is in Database

1. Go to **Supabase** → **Tables** 
2. Click on **settings** table
3. Look for a row with:
   - `key` = `hero_video`
   - `hero_video_url` = Your full video URL (starts with https://)

**If hero_video_url is empty:**
- The upload function is not saving it correctly
- Check if it's saving to the right table/column

**If hero_video_url has a value:**
- Continue to Step 2

### Step 2: Check Browser Console

1. Go to your **home page** (index.html)
2. Press **F12** to open Developer Tools
3. Go to **Console** tab
4. Look for messages like:
   - "Loading hero video from settings..." ✅
   - "Setting video source to: https://..." ✅
   - Or error messages ❌

**What to look for:**
```
✅ Good: "Setting video source to: https://..."
❌ Bad: "No video URL found in settings"
❌ Bad: "Error fetching video URL: ..."
```

### Step 3: Try Different Video Formats

If URL is correct but video doesn't play:

1. Try a **public YouTube video** or **free stock video**
2. Test with a simple public URL first
3. URLs must start with `https://` (not http://)

### Step 4: Direct URL Test

Paste your video URL directly in browser address bar. 

- ✅ If it plays in browser = URL is good
- ❌ If it shows error = URL is bad

### Step 5: Clear Browser Cache

Sometimes videos won't show due to caching:

1. Press **Ctrl + Shift + Delete** (Windows)
2. Select "All time" 
3. Check "Cached images and files"
4. Click "Clear data"
5. Refresh page

## 🎯 Complete Video Upload Process:

1. **Go to Admin Page** → admin.html
2. **Login** with your credentials
3. **Find "Home Screen Video" section**
4. **Choose one:**
   - **Option A**: Paste video URL (must be public https://)
   - **Option B**: Upload MP4 file (< 5 MB recommended)
5. **Click "Save Video"**
6. **Wait for**: "✓ Video saved successfully!"
7. **Go to home page** (index.html)
8. **Refresh the page** (F5)
9. **Video should appear** in hero section

## 🧪 Test Video URLs (Use These to Test):

These are guaranteed to work:

```
https://storage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4
https://commondatastorage.googleapis.com/gtv-videos-library/sample/Sintel.mp4
https://media.w3.org/2010/05/sintel/trailer.mp4
```

### To Test:
1. Copy one of the URLs above
2. Paste in "Video URL" field in admin
3. Click "Save Video"
4. Go to home page
5. Should see video playing!

## 🔍 Debug Checklist:

- [ ] Video URL starts with `https://` (not http://)
- [ ] Video URL is publicly accessible (test in browser)
- [ ] Settings table exists in Supabase
- [ ] hero_video row exists in settings table
- [ ] hero_video_url column has a value
- [ ] Browser console shows "Setting video source to: ..."
- [ ] No RLS policy errors in console
- [ ] Page is refreshed (F5) after uploading video
- [ ] Video element exists in index.html (id="heroVideo")
- [ ] modern-ecommerce.js is loaded

## 📱 Common Issues & Solutions:

### Issue: "No video URL found in settings"
**Solution**: 
- Video URL wasn't saved to database
- Check if settings table exists
- Check if key='hero_video' row exists
- Try uploading again

### Issue: "Error fetching video URL: ..."
**Solution**:
- Settings table has RLS policy blocking read
- Run STORAGE_RLS_FIX_SIMPLE.sql again
- Check RLS policies on settings table

### Issue: Video saves but doesn't show
**Solution**:
- Refresh the page (F5)
- Clear browser cache (Ctrl+Shift+Delete)
- Check if video URL is actually in database
- Try different video URL

### Issue: You get logged out
**Solution**: ✅ Fixed in latest admin.js
- No more automatic page reload
- Just wait for success message
- Manually refresh home page when ready

## 🚀 After Successfully Uploading:

Your website visitors will see:
1. **Hero section** with background video playing
2. **Video loops** automatically
3. **Video is muted** (no sound)
4. **Video is responsive** on all devices
5. **Fallback gradient** if video doesn't load

## 📞 If Still Not Working:

Check these in order:

1. **Browser Console**: F12 → Console tab → Look for errors
2. **Database**: Supabase → settings table → Check hero_video_url value
3. **Video URL**: Open URL in new browser tab → Does it play?
4. **Policies**: Run STORAGE_RLS_FIX_SIMPLE.sql again
5. **Cache**: Clear browser cache (Ctrl+Shift+Delete)
6. **Try test URL**: Use one of the test URLs from above

## 📋 Video Requirements Reminder:

- Format: MP4, WebM, or OGG
- Size: 1-5 MB (smaller is faster)
- Resolution: 1920x1080 recommended
- Duration: 30-60 seconds ideal
- Must be publicly accessible (https://)
