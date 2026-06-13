# How to Set Up & Manage Hero Video Background

## Quick Start (5 minutes)

### Step 1: Create Settings Table in Supabase

Go to your Supabase Project → SQL Editor and run:

```sql
-- Create settings table if it doesn't exist
CREATE TABLE IF NOT EXISTS settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT UNIQUE NOT NULL,
  hero_video_url TEXT,
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Allow public read" ON settings
  FOR SELECT USING (true);

-- Create policy for authenticated admin write access
CREATE POLICY "Allow admin write" ON settings
  FOR INSERT, UPDATE, DELETE 
  USING (auth.role() = 'authenticated');

-- Insert hero video setting (default empty)
INSERT INTO settings (key, hero_video_url, description)
VALUES (
  'hero_video',
  '',
  'Hero section background video URL'
) ON CONFLICT (key) DO NOTHING;
```

### Step 2: Upload Video to Supabase Storage

1. Go to Supabase → Storage
2. Create a new bucket called `hero-videos`
3. Upload your video file
4. Copy the public URL

**Video Requirements:**
- Format: MP4 (best browser compatibility)
- Size: Optimized (1-5 MB)
- Duration: 30-60 seconds
- Resolution: 1920x1080 or higher
- Aspect ratio: 16:9

### Step 3: Update Video URL in Admin Panel

Create a simple admin form or directly insert:

```sql
UPDATE settings 
SET hero_video_url = 'https://your-supabase-url/storage/v1/object/public/hero-videos/your-video.mp4'
WHERE key = 'hero_video';
```

## Video Optimization Tips

### Compress Video Using FFmpeg

```bash
# Install FFmpeg first, then run:
ffmpeg -i original-video.mp4 -c:v libx264 -crf 28 -c:a aac -b:a 128k output-video.mp4
```

**Settings Explained:**
- `-c:v libx264`: Use H.264 codec
- `-crf 28`: Quality (18-28, lower = better, higher = smaller file)
- `-c:a aac`: Audio codec
- `-b:a 128k`: Audio bitrate

### Recommended Compression Settings

For **Hero Videos** (1-5 MB):
```bash
ffmpeg -i video.mp4 -c:v libx264 -crf 28 -s 1920x1080 -c:a aac -b:a 96k hero-video.mp4
```

## Add to Admin Dashboard (Optional)

To allow admins to change video URL through admin panel, add this to `admin.html`:

```html
<!-- Add to Admin Dashboard -->
<div class="admin-section">
    <h3>Hero Video Management</h3>
    <div class="form-group">
        <label for="heroVideoUrl">Hero Video URL:</label>
        <input type="text" id="heroVideoUrl" placeholder="Paste video URL here">
        <button onclick="updateHeroVideo()">Update Video</button>
    </div>
    <div id="videoPreview">
        <video id="previewVideo" width="300" controls></video>
    </div>
</div>
```

Add to `admin.js`:

```javascript
async function loadHeroVideo() {
    try {
        const { data } = await client
            .from('settings')
            .select('hero_video_url')
            .eq('key', 'hero_video')
            .single();
        
        if (data && data.hero_video_url) {
            document.getElementById('heroVideoUrl').value = data.hero_video_url;
            document.getElementById('previewVideo').src = data.hero_video_url;
        }
    } catch (error) {
        console.error('Error loading hero video:', error);
    }
}

async function updateHeroVideo() {
    const url = document.getElementById('heroVideoUrl').value;
    
    if (!url) {
        alert('Please enter a video URL');
        return;
    }
    
    try {
        const { error } = await client
            .from('settings')
            .update({ hero_video_url: url })
            .eq('key', 'hero_video');
        
        if (error) throw error;
        
        alert('✓ Hero video updated successfully!');
        document.getElementById('previewVideo').src = url;
    } catch (error) {
        alert('Error updating video: ' + error.message);
    }
}

// Call on page load
loadHeroVideo();
```

## Video Fallback (No Video Setup)

If you don't set up a video, the hero section uses:
- Gradient background overlay
- Pattern background texture
- Works perfectly without video

## Multiple Videos (Advanced)

To support multiple hero videos for different seasons:

```sql
-- Add more videos
INSERT INTO settings (key, hero_video_url, description)
VALUES 
  ('hero_video_summer', 'https://...', 'Summer collection video'),
  ('hero_video_winter', 'https://...', 'Winter collection video'),
  ('hero_video_sale', 'https://...', 'Sale event video');
```

Update JavaScript:

```javascript
async function loadHeroVideo() {
    try {
        const season = getCurrentSeason(); // Your function
        const key = `hero_video_${season}`;
        
        const { data } = await client
            .from('settings')
            .select('hero_video_url')
            .eq('key', key)
            .single();
        
        if (data && data.hero_video_url) {
            const videoElement = document.getElementById('heroVideo');
            videoElement.src = data.hero_video_url;
            videoElement.style.display = 'block';
        }
    } catch (error) {
        console.log('Using default background');
    }
}

function getCurrentSeason() {
    const month = new Date().getMonth();
    if (month >= 2 && month <= 4) return 'spring';
    if (month >= 5 && month <= 7) return 'summer';
    if (month >= 8 && month <= 10) return 'fall';
    return 'winter';
}
```

## Troubleshooting

### Video Not Playing
**Problem**: Video doesn't show on homepage
**Solution**: 
1. Check browser console (F12)
2. Verify video URL is public in Supabase Storage
3. Test video URL in browser directly
4. Check video format (MP4 recommended)
5. Ensure settings table exists and has correct key

### Video Freezes or Stutters
**Problem**: Video playback is choppy
**Solution**:
1. Compress video more (increase crf value)
2. Reduce resolution
3. Use smaller file size (< 3 MB)

### Audio Issues
**Problem**: No sound or audio problems
**Solution**:
1. Use muted attribute (already in code)
2. Remove audio from video entirely
3. Test audio codec compatibility

## Browser Compatibility

| Browser | Support | Notes |
|---------|---------|-------|
| Chrome  | ✅ Full | All features work |
| Firefox | ✅ Full | All features work |
| Safari  | ✅ Full | Requires muted attribute |
| Edge    | ✅ Full | All features work |
| IE 11   | ⚠️ Limited | No video, shows fallback |

## Performance Optimization

### CDN Recommendations
- **Cloudflare**: Free tier for Supabase
- **Bunny CDN**: Affordable video delivery
- **AWS CloudFront**: Enterprise solution

### Load Times
- **Video < 2 MB**: ~1 second load
- **Video 2-5 MB**: ~2-3 seconds load
- **Video > 5 MB**: May slow page load

### Caching
Videos are cached by browser automatically. To clear cache:
```bash
# In browser DevTools → Network → Right-click → Clear Browser Cache
```

## Alternative Methods

### Method 1: Direct MP4 Upload to Storage
```sql
-- Just store the URL
UPDATE settings SET hero_video_url = 'https://storage.../video.mp4' WHERE key = 'hero_video';
```

### Method 2: YouTube/Vimeo Embed
```javascript
// Modify modern-ecommerce.js loadHeroVideo function
async function loadHeroVideo() {
    // Use YouTube URL or Vimeo
    const videoElement = document.getElementById('heroVideo');
    videoElement.innerHTML = `
        <iframe src="https://www.youtube.com/embed/VIDEO_ID?autoplay=1&loop=1&mute=1" 
                width="100%" height="100%"></iframe>
    `;
}
```

### Method 3: GIF Fallback
```html
<!-- In index.html hero section -->
<video id="heroVideo" autoplay muted loop style="display:none;"></video>
<!-- Fallback GIF if video doesn't load -->
<style>
    .hero::before {
        background-image: url('hero-fallback.gif');
        background-size: cover;
        background-position: center;
    }
</style>
```

## Best Practices Checklist

- [ ] Video is optimized (< 5 MB)
- [ ] Video format is MP4
- [ ] Video URL is public in storage
- [ ] Settings table exists in database
- [ ] Hero video key exists in settings
- [ ] Video has fallback (gradient background)
- [ ] Video plays on desktop
- [ ] Video plays on mobile
- [ ] Video is muted (no audio issues)
- [ ] Video loops seamlessly
- [ ] No console errors

## Quick Reference

**Current Settings:**
- Video Element ID: `heroVideo`
- Database Table: `settings`
- Database Key: `hero_video`
- Database Column: `hero_video_url`
- Load Function: `loadHeroVideo()` in modern-ecommerce.js

**To Change Video:**
```sql
UPDATE settings 
SET hero_video_url = 'NEW_VIDEO_URL' 
WHERE key = 'hero_video';
```

## Support

If you need help:
1. Check browser console for errors
2. Verify video URL is accessible
3. Test video in browser directly
4. Check Supabase settings table
5. Review database permissions

Happy video hosting! 🎬
