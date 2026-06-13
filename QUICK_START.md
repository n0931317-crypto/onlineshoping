# Nepo Online stores - Quick Start Checklist

## 🚀 Get Started in 15 Minutes

Complete these steps in order to launch your Nepo Online stores e-commerce platform.

---

## ✅ STEP 1: Database Setup (5 minutes)

### Action Items:
- [ ] Open Supabase Dashboard: https://app.supabase.com
- [ ] Select your project
- [ ] Go to SQL Editor
- [ ] Copy & paste entire content from: **SUNLIGHT_TRADERS_COMPLETE_DATABASE_SETUP.sql**
- [ ] Click "Run" button
- [ ] Wait for completion message ✅
- [ ] Verify tables created (check "Tables" section on left)

### Expected Result:
- 12 tables created
- Admin user created (admin@sunlighttradersco.in / admin123)
- All RLS policies enabled

---

## ✅ STEP 2: Sample Data Setup (2 minutes)

### Action Items:
- [ ] In same SQL Editor, copy & paste: **SUNLIGHT_TRADERS_SAMPLE_DATA.sql**
- [ ] Click "Run" button
- [ ] Wait for completion message ✅

### Expected Result:
- 5 collections added (Sarees, Suits, Lehengas, Boots, Readymade)
- 5 sample products inserted
- 5 customer reviews added
- Payment methods configured
- Business settings saved

---

## ✅ STEP 3: Storage Buckets (3 minutes)

### Manual Setup (Easiest):
1. [ ] In Supabase Dashboard, go to **Storage**
2. [ ] Click **"New Bucket"**
3. [ ] Create these buckets (set **Public**):
   - [ ] product-images
   - [ ] gallery-images
   - [ ] logo
   - [ ] videos
4. [ ] Create this bucket (set **Private**):
   - [ ] admin-uploads

### Alternative - SQL Setup:
- [ ] Copy & paste: **SUNLIGHT_TRADERS_STORAGE_SETUP.sql**
- [ ] Run in SQL Editor

---

## ✅ STEP 4: Get Your ANON_KEY (2 minutes)

### CRITICAL - This fixes all errors!

1. [ ] In Supabase Dashboard, go to **Settings** → **API**
2. [ ] Find the **anon** key (starts with `eyJhbGc...`)
3. [ ] Copy it completely

### Update Website:
1. [ ] Open file: `b:\sunr\supabase-new.js`
2. [ ] Find line: `const ANON_KEY = '...`
3. [ ] Replace entire key value with your copied key
4. [ ] Save file (Ctrl+S)
5. [ ] Refresh website in browser

---

## ✅ STEP 5: Test Everything (3 minutes)

### On Homepage (index.html):
- [ ] Page loads without errors
- [ ] "Nepo Online stores" title visible
- [ ] Collections section shows all 5 categories
- [ ] Featured items show 5 products with images
- [ ] Gallery displays fashion photos
- [ ] Check browser console (F12) - no red errors

### Admin Panel:
- [ ] Open admin.html
- [ ] Login with: admin@sunlighttradersco.in / admin123
- [ ] Dashboard shows:
  - [ ] Total Collections: 5
  - [ ] Total Products: 5
  - [ ] Today's Appointments: 0
- [ ] Click each section to verify:
  - [ ] Manage Collections - see 5 collections
  - [ ] Manage Products - see 5 products
  - [ ] Manage Orders - empty (no orders yet)
  - [ ] Manage Reviews - see 5 reviews

---

## 📝 Key Information

### Admin Login:
```
Email: admin@sunlighttradersco.in
Password: admin123
```

### Your Project URLs:
```
Website: file:///b:/sunr/index.html
Admin: file:///b:/sunr/admin.html
Supabase: https://gqzajmxtkfnvfceokwip.supabase.co
Dashboard: https://app.supabase.com
```

### Business Info (Configured):
```
Name: Nepo Online stores
Email: info@sunlighttradersco.in
Categories: Sarees, Ladies Suits, Lehengas, Boots, Readymade Clothes
Currency: INR (₹)
```

---

## 📁 File Locations

| File | Purpose | Location |
|------|---------|----------|
| SUNLIGHT_TRADERS_COMPLETE_DATABASE_SETUP.sql | Create database | b:\sunr\ |
| SUNLIGHT_TRADERS_SAMPLE_DATA.sql | Insert sample data | b:\sunr\ |
| SUNLIGHT_TRADERS_STORAGE_SETUP.sql | Create storage buckets | b:\sunr\ |
| supabase-new.js | Database connection | b:\sunr\ |
| index.html | Homepage | b:\sunr\ |
| admin.html | Admin dashboard | b:\sunr\ |
| SUNLIGHT_TRADERS_SETUP_GUIDE.md | Complete guide | b:\sunr\ |

---

## 🎨 Collections & Products Included

### 5 Collections:
1. **Sarees** - Traditional and modern designs (₹2,500)
2. **Ladies Suits** - Designer suits (₹3,000)
3. **Lehengas** - Wedding lehengas (₹4,500)
4. **Boots & Shoes** - Premium footwear (₹2,000)
5. **Readymade Clothes** - Everyday wear (₹1,500)

### 5 Sample Products:
1. Cotton Saree - Blue (₹2,500)
2. Silk Saree - Red (₹5,000)
3. Designer Suit - Green (₹3,500)
4. Cotton Suit - Yellow (₹2,500)
5. Bridal Lehenga - Gold (₹8,000)

---

## ⚠️ Common Issues & Fixes

### Products Not Showing on Homepage?
**Fix:**
1. Check ANON_KEY is updated correctly
2. Open browser console (F12)
3. Look for error messages
4. Refresh page

### Admin Panel Won't Login?
**Fix:**
1. Email must be exactly: `admin@sunlighttradersco.in`
2. Password: `admin123`
3. Clear browser cache
4. Try in incognito mode

### Images Not Uploading?
**Fix:**
1. Ensure buckets are set to "Public"
2. File size less than 5MB
3. Supported formats: JPG, PNG, WebP
4. Check admin panel → Manage Product Images

### ERR_NAME_NOT_RESOLVED Errors?
**Fix:**
1. ANON_KEY not updated
2. Wrong project URL
3. Browser cache issue
4. Follow Step 4 again carefully

---

## 📞 Need Help?

### Check These First:
1. Browser Console (F12) for error messages
2. Supabase Logs (Dashboard → Logs)
3. Network tab (F12 → Network) for failed requests
4. Read: SUNLIGHT_TRADERS_SETUP_GUIDE.md

### Verify Setup:
```sql
-- Run in Supabase SQL Editor to verify:

SELECT 'admin_users' as table_name, COUNT(*) as count FROM admin_users
UNION ALL SELECT 'services', COUNT(*) FROM services
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews;
```

Expected result: All counts should be greater than 0

---

## 🎉 Next Steps After Launch

### 1. Upload Real Images:
- [ ] Replace sample product images
- [ ] Upload real clothing photos
- [ ] Add gallery images
- [ ] Upload logo

### 2. Configure Payment:
- [ ] Get Razorpay API keys
- [ ] Add to admin panel
- [ ] Test payment flow

### 3. Setup Email:
- [ ] Create EmailJS account
- [ ] Add credentials to payment.js
- [ ] Test contact form

### 4. Update Business Info:
- [ ] Change phone number
- [ ] Add business address
- [ ] Update email address
- [ ] Add social media links

### 5. Customize Content:
- [ ] Update About page
- [ ] Add company story
- [ ] Upload team photos
- [ ] Update contact information

---

## ✨ Features Ready to Use

- ✅ Product catalog with up to 4 images per item
- ✅ Auto-rotating product image carousel
- ✅ Customer reviews & ratings
- ✅ Shopping cart (JavaScript)
- ✅ Order management system
- ✅ Admin dashboard with full controls
- ✅ Payment integration (ready for Razorpay)
- ✅ Order tracking
- ✅ Customer inquiries form
- ✅ Gallery showcase
- ✅ Mobile responsive design
- ✅ Row Level Security (RLS) enabled

---

## 💡 Pro Tips

1. **Organize Products:** Group similar items in same collection
2. **Images Matter:** Use high-quality photos (1000x1000px)
3. **Pricing:** Keep prices consistent with market
4. **Reviews:** Encourage customers to leave reviews
5. **Updates:** Regularly add new products to collections
6. **Mobile:** Test on phone before going live
7. **Backup:** Regularly backup your database
8. **Security:** Change admin password regularly

---

## 📊 Dashboard Stats

After setup, your admin dashboard will show:

```
┌─────────────────────────────────┐
│  Today's Appointments: 0         │
│  Total Collections: 5            │
│  Total Products: 5               │
│  Today's Revenue: ₹0             │
└─────────────────────────────────┘
```

These update automatically as customers use the website.

---

## 🚀 Ready to Launch!

You now have a complete, fully-functional e-commerce platform for Nepo Online stores!

**What You Get:**
- ✅ Professional website
- ✅ Admin dashboard
- ✅ Product management
- ✅ Order tracking
- ✅ Customer reviews
- ✅ Secure authentication
- ✅ Payment ready
- ✅ Mobile responsive

**Time to:** Make your clothing business a success! 👗👠

---

**Questions?** Check SUNLIGHT_TRADERS_SETUP_GUIDE.md for detailed instructions.
