# Nepo Online stores - Complete Setup Guide

## 📋 Overview
This guide will help you set up the complete Nepo Online stores e-commerce platform for selling clothing and fashion items (sarees, ladies suits, lehengas, boots, readymade clothes).

---

## ✅ Step 1: Database Setup

### Files Needed:
1. **SUNLIGHT_TRADERS_COMPLETE_DATABASE_SETUP.sql** - Creates all tables, functions, triggers, and RLS policies
2. **SUNLIGHT_TRADERS_SAMPLE_DATA.sql** - Inserts sample clothing products and data

### How to Execute:

1. **Open Supabase Dashboard**
   - Go to https://app.supabase.com
   - Select your project (gqzajmxtkfnvfceokwip)
   - Click on "SQL Editor"

2. **Run Database Setup**
   - Copy all content from `SUNLIGHT_TRADERS_COMPLETE_DATABASE_SETUP.sql`
   - Paste into SQL Editor
   - Click "Run"
   - Wait for completion ✅

3. **Run Sample Data**
   - Copy all content from `SUNLIGHT_TRADERS_SAMPLE_DATA.sql`
   - Paste into SQL Editor
   - Click "Run"
   - Wait for completion ✅

### Tables Created:
- ✅ `admin_users` - Admin login credentials
- ✅ `services` - Clothing collections (Sarees, Suits, Lehengas, Boots, Readymade)
- ✅ `products` - Individual clothing items
- ✅ `product_images` - Up to 4 images per product (carousel)
- ✅ `orders` - Customer orders
- ✅ `order_items` - Items in each order
- ✅ `reviews` - Customer product reviews
- ✅ `appointments` - Customer inquiries/appointments
- ✅ `gallery` - Fashion showcase gallery
- ✅ `home_video` - Homepage video
- ✅ `payment_configuration` - Payment method settings
- ✅ `settings` - Business settings

---

## ✅ Step 2: Storage Buckets Setup

### Buckets to Create (in Supabase):

1. **product-images** - Product photos for carousel
2. **gallery-images** - Gallery showcase images
3. **videos** - Video files
4. **logo** - Company logo
5. **admin-uploads** - Admin panel uploads

### Create Each Bucket:
1. In Supabase, go to "Storage"
2. Click "New Bucket"
3. Name: `product-images`
4. Set to Public (for images to be visible)
5. Repeat for other buckets

---

## ✅ Step 3: Update Supabase Connection

### Critical Step - Fix API Errors:

1. **Get Your ANON_KEY:**
   - In Supabase dashboard
   - Go to Settings → API
   - Copy the `anon` key (starts with `eyJhbGc...`)

2. **Update supabase-new.js:**
   - Open `b:\sunr\supabase-new.js`
   - Find: `const ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';`
   - Replace with your real ANON_KEY
   - Save file

3. **Refresh Website:**
   - Open website in browser
   - Check browser console (F12)
   - Errors should be resolved ✅

---

## ✅ Step 4: Admin Panel Login

### Default Admin Credentials:
- **Email:** admin@sunlighttradersco.in
- **Password:** admin123

### How to Login:
1. Go to `admin.html`
2. Enter credentials above
3. Click "Login"
4. Access all admin features

### Change Password (Recommended):
- After login, update credentials in Supabase `admin_users` table

---

## 📦 Collections (Clothing Categories)

### Pre-populated Collections:
1. **Sarees** - Traditional and modern sarees (₹2,500)
2. **Ladies Suits** - Designer suits (₹3,000)
3. **Lehengas** - Wedding & party lehengas (₹4,500)
4. **Boots & Shoes** - Premium footwear (₹2,000)
5. **Readymade Clothes** - Everyday garments (₹1,500)

### Manage Collections:
- Admin Panel → Manage Collections
- Add/Edit/Delete collections
- Set prices and descriptions

---

## 🛍️ Products Setup

### Sample Products Included:
1. Cotton Saree - Blue (₹2,500)
2. Silk Saree - Red (₹5,000)
3. Designer Suit - Green (₹3,500)
4. Cotton Suit - Yellow (₹2,500)
5. Bridal Lehenga - Gold (₹8,000)

### Add More Products:
1. Admin Panel → Manage Products
2. Click "Add New Product"
3. Fill in details:
   - Product Name
   - Description
   - Price
   - Category (Sarees, Suits, etc.)
   - Stock Quantity

### Upload Product Images:
1. Admin Panel → Manage Product Images
2. Select product
3. Upload up to 4 images
4. Images auto-rotate every 7 seconds on product page

---

## 🎨 Gallery Setup

### Update Gallery Images:
1. Admin Panel → Manage Gallery
2. Add fashion photography
3. Organize by category:
   - Sarees
   - Ladies Suits
   - Lehengas
   - Boots & Shoes
   - Readymade Clothes

### Upload Locations:
- Store images in `/gallery-images/` folder
- Update image URLs in admin panel

---

## 💳 Payment Setup

### Configure Payment Methods:
1. Admin Panel → Payments
2. Enable/disable methods:
   - Razorpay (online payments)
   - UPI (digital payments)
   - Bank Transfer
   - Cash on Delivery (COD)

### Razorpay Integration:
1. Get API keys from Razorpay dashboard
2. Update in Supabase `payment_configuration` table
3. Or update via Admin Panel → Payment Settings

---

## 📱 Website Pages

### Main Pages:
- **index.html** - Homepage with products & collections
- **product-details.html** - Individual product details
- **orders.html** - Customer order history
- **track.html** - Order tracking
- **payment.html** - Checkout & payment
- **admin.html** - Admin login & dashboard
- **about.html** - About Nepo Online stores
- **shipping.html** - Shipping policy
- **contact** - Contact form (on homepage)

---

## 🔧 Admin Panel Features

### Dashboard:
- Today's appointments count
- Total collections count
- Total products count
- Today's revenue
- Recent orders & reviews

### Manage Collections:
- Add/Edit/Delete clothing collections
- Set prices and descriptions
- Upload collection images

### Manage Products:
- Add/Edit/Delete individual items
- Set stock quantities
- Manage product categories
- Update prices

### Manage Product Images:
- Upload up to 4 images per product
- Auto-rotating carousel preview
- Drag to reorder images

### Manage Orders:
- View all customer orders
- Filter by status:
  - Pending
  - Confirmed
  - Processing
  - Shipped
  - Delivered
  - Cancelled
- Update order status
- Add tracking numbers

### Manage Reviews:
- View customer reviews
- Rate products
- Approve/delete reviews

### Manage Gallery:
- Upload fashion showcase images
- Organize by category
- Set display order

### Payment Settings:
- Configure payment methods
- Add API keys
- Enable/disable payment options

### Settings:
- Business name
- Email & phone
- Address & location
- Tax rate
- Delivery charges
- Business description

---

## 🗺️ Google Map Integration

### Add Your Store Location:
1. Open `index.html`
2. Find the map embed in Contact section
3. Replace the iframe `src` with your Google Maps embed code
4. Steps to get embed code:
   - Go to Google Maps
   - Search your store location
   - Click "Share" → "Embed a map"
   - Copy the iframe code

---

## 📧 Email Configuration

### Contact Form & Notifications:
- Currently using EmailJS for email delivery
- Update EmailJS credentials in `payment.js` and `script.js`
- Get free account at: https://www.emailjs.com/

### Setup Steps:
1. Create EmailJS account
2. Get Service ID and Template ID
3. Update in JavaScript files
4. Test contact form submission

---

## 🔒 Security Notes

### Important:
- ✅ Row Level Security (RLS) enabled on all tables
- ✅ Public read access for products, reviews, gallery
- ✅ Authenticated write access for orders, reviews
- ✅ Admin-only access to sensitive tables
- ✅ Never share ANON_KEY publicly
- ✅ Use environment variables for sensitive data

---

## 📊 Verification Checklist

After setup, verify everything works:

- [ ] Database tables created (check Supabase Tables)
- [ ] Sample data inserted (5 products visible)
- [ ] Admin login works (admin@sunlighttradersco.in / admin123)
- [ ] Products display on homepage
- [ ] Product carousel works (4 images rotate)
- [ ] Gallery shows clothing photos
- [ ] Orders can be placed
- [ ] Admin panel shows dashboard stats
- [ ] Contact form submits
- [ ] No console errors (F12 → Console)

---

## 🆘 Troubleshooting

### Products Not Showing?
- Check ANON_KEY is correct in `supabase-new.js`
- Check browser console for errors (F12)
- Verify `SUNLIGHT_TRADERS_COMPLETE_DATABASE_SETUP.sql` ran successfully

### Admin Panel Won't Login?
- Verify email: `admin@sunlighttradersco.in`
- Verify password: `admin123`
- Check `admin_users` table has an entry
- Clear browser cache and try again

### Images Not Uploading?
- Verify storage buckets exist in Supabase
- Check bucket permissions (set to Public)
- Verify file size is under limit
- Check browser console for upload errors

### Emails Not Sending?
- Verify EmailJS credentials
- Check Service ID and Template ID
- Test with test email first
- Check spam folder

### Payment Not Working?
- Verify Razorpay API keys are correct
- Check payment gateway is enabled
- Test with test card details first
- Check browser console for payment errors

---

## 📞 Quick Reference

### Important URLs:
- **Supabase Dashboard:** https://app.supabase.com
- **Website:** http://localhost/sunr/index.html
- **Admin Panel:** http://localhost/sunr/admin.html
- **Database Project:** gqzajmxtkfnvfceokwip.supabase.co

### Important Files:
- `supabase-new.js` - Database connection (needs ANON_KEY)
- `admin.html` - Admin dashboard
- `index.html` - Homepage
- `SUNLIGHT_TRADERS_COMPLETE_DATABASE_SETUP.sql` - Database tables
- `SUNLIGHT_TRADERS_SAMPLE_DATA.sql` - Sample products

### Important Tables:
- `admin_users` - Admin credentials
- `services` - Collections
- `products` - Individual items
- `orders` - Customer orders
- `reviews` - Product reviews
- `settings` - Business info

---

## 🎉 You're All Set!

Your Nepo Online stores e-commerce platform is ready to go! 

**Next Steps:**
1. ✅ Run database setup SQL
2. ✅ Create storage buckets
3. ✅ Update ANON_KEY
4. ✅ Login to admin panel
5. ✅ Upload real product images
6. ✅ Configure payment methods
7. ✅ Test all features
8. ✅ Go live!

Good luck with your clothing business! 🚀
