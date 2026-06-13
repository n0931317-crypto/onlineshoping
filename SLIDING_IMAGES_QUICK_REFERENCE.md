# Sliding Images - Quick Reference Card

## 🚀 3-Step Setup (10 Minutes)

### Step 1: Database (2 min)
```
Supabase → SQL Editor
↓
Copy: CREATE_SLIDING_IMAGES_TABLE.sql
↓
Paste & Execute
```

### Step 2: Storage (1 min)
```
Supabase → Storage
↓
Create Bucket: sliding-images
↓
Make it PUBLIC (uncheck private)
↓
Set policy: SELECT (public read)
```

### Step 3: Add Slides (5 min each)
```
Admin Panel → Hero Slider
↓
Click "Add Sliding Image"
↓
Fill form:
  • Display Order: 1, 2, 3...
  • Image: Upload or paste URL
  • Title: (optional)
  • Description: (optional)
  • Link: (optional)
  • Status: Active
↓
Save
```

---

## 📊 Admin Functions Quick Guide

| Action | Steps |
|--------|-------|
| **Add Slide** | Hero Slider → Add Sliding Image → Fill form → Save |
| **Edit Slide** | Hero Slider → Find slide → Edit → Update → Save |
| **Delete Slide** | Hero Slider → Find slide → Delete → Confirm |
| **Reorder Slides** | Edit slide → Change display_order → Save |
| **Hide Slide** | Edit slide → Status: Inactive → Save |
| **Show Slide** | Edit slide → Status: Active → Save |

---

## 🎯 Slider Behavior

### Home Page
- ✅ Loads active slides from database
- ✅ Sorted by display_order (1, 2, 3...)
- ✅ Auto-rotates every 5 seconds
- ✅ Manual controls (← →)
- ✅ Responsive (mobile, tablet, desktop)

### Updates
- ✅ Immediate (no cache delay)
- ✅ All devices auto-refresh
- ✅ Smooth transitions

---

## 🔑 Key Fields

| Field | Purpose | Required |
|-------|---------|----------|
| Display Order | Controls slide order (1=first) | ✅ Yes |
| Image URL | Background image | ✅ Yes |
| Title | Main heading | ❌ Optional |
| Description | Subheading | ❌ Optional |
| Link URL | Click to navigate | ❌ Optional |
| Status | Active/Inactive | ✅ Yes |

---

## 🎨 Customization

### Change Auto-Rotate Speed
File: `modern-ecommerce.js` line ~125
```javascript
5000  // = 5 seconds
3000  // = 3 seconds
10000 // = 10 seconds
```

### Change Slider Height
File: `modern-premium-styles.css`
```css
.hero-slider-wrapper {
    min-height: 350px;  /* Change this */
}
```

---

## ⚙️ Technical Details

### Database
- Table: `sliding_images`
- Storage: `sliding-images` bucket
- RLS: Public read, admin write

### JavaScript
- Load: `loadSlidingImages()`
- Init: `initHeroSlider()`
- Update: `updateHeroSlide()`

### Admin
- Add: `openSlidingImageModal()`
- Save: `handleSlidingImageSubmit()`
- Delete: `deleteSlidingImageConfirm()`

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| No slides showing | 1. Run SQL 2. Check is_active=true 3. Refresh page |
| Images broken | 1. Create bucket 2. Make PUBLIC 3. Check URLs |
| Won't upload | 1. Check bucket exists 2. Is PUBLIC? 3. Permissions? |
| Not auto-rotating | 1. Check console 2. Verify JS loaded 3. Refresh |

---

## 📱 Image Recommendations

- **Size:** 1920 x 350 pixels
- **Format:** JPG, PNG, or WebP
- **Compression:** Optimize before upload
- **Upload method:** Direct upload or URL

---

## 🎯 Sample Slides

```
Slide 1:
  Display Order: 1
  Title: Summer Collection
  Description: Discover latest fabrics
  Status: Active

Slide 2:
  Display Order: 2
  Title: New Arrivals
  Description: Check trending styles
  Status: Active

Slide 3:
  Display Order: 3
  Title: Special Offers
  Description: Limited time discounts
  Status: Active
```

---

## 📁 Files Modified

- ✅ `admin.html` - Hero Slider section + modal
- ✅ `admin.js` - Management functions
- ✅ `index.html` - Dynamic slider
- ✅ `modern-ecommerce.js` - Database loading
- ✅ `CREATE_SLIDING_IMAGES_TABLE.sql` - Database setup

---

## ✅ Verification Checklist

After setup, verify:
- [ ] SQL executed (no errors)
- [ ] Bucket created (PUBLIC)
- [ ] Bucket policy set
- [ ] Slide added in admin
- [ ] Slide appears on home page
- [ ] Click arrows to navigate
- [ ] Auto-rotates every 5 seconds
- [ ] Images load correctly

---

## 💡 Pro Tips

1. **Naming:** Use display_order 1, 2, 3 for clarity
2. **Images:** Compress before upload for speed
3. **Text:** Keep titles short (fits mobile)
4. **Links:** Use #shop or external URLs
5. **Test:** Always verify on mobile
6. **Speed:** Adjust 5000ms for faster/slower rotation

---

## 📞 Quick Access

**Admin Panel:** `admin.html` → Hero Slider (sidebar)
**Database:** Supabase → `sliding_images` table
**Storage:** Supabase → `sliding-images` bucket
**Docs:** See `SLIDING_IMAGES_SETUP_GUIDE.md`

---

## 🎉 Ready to Go!

✅ All implemented and ready!

Just:
1. Run SQL
2. Create bucket
3. Add slides
4. Done!

Slider auto-handles rest 🚀

