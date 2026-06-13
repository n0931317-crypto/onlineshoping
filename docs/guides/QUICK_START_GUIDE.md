# 🚀 QUICK START GUIDE - Database & Storage Setup

## ⚡ 5-Minute Setup (Fast Track)

### Step 1: Run the Main SQL (2 minutes)
1. Open Supabase Dashboard → **SQL Editor** → **New Query**
2. Open file: `COMPLETE_DATABASE_AND_STORAGE_SETUP.sql`
3. Copy **ALL** the SQL code
4. Paste into Supabase SQL Editor
5. Click **RUN** (or Ctrl+Enter)
6. ✅ Wait for completion

### Step 2: Create Storage Buckets (3 minutes)
1. Go to Supabase Dashboard → **Storage**
2. Click **"Create new bucket"**
3. Create these 9 buckets (toggle PUBLIC ON for each):
   - `product-images`
   - `product-images-slot-1`
   - `product-images-slot-2`
   - `product-images-slot-3`
   - `product-images-slot-4`
   - `gallery-images`
   - `videos`
   - `transaction-screenshots`
   - `service-images`

### ✅ Done!

---

## 📋 What You Got

### 13 Database Tables
```
✅ admin_users        - Admin accounts
✅ services           - Services offered
✅ products           - Product catalog
✅ product_images     - Product images (4 per product)
✅ reviews            - Product reviews & ratings
✅ review_helpful_votes - Helpful votes on reviews
✅ appointments       - Service bookings
✅ gallery            - Gallery images
✅ home_video         - Promo videos
✅ payment_configuration - Payment method details
✅ orders             - Customer orders
✅ order_items        - Products in orders
✅ settings           - App settings
```

### 9 Storage Buckets (All Public)
```
✅ product-images
✅ product-images-slot-1 to slot-4 (4 separate slots)
✅ gallery-images
✅ videos
✅ transaction-screenshots
✅ service-images
```

### Features Included
```
✅ Automatic order number generation
✅ Automatic timestamps on all updates
✅ Product review statistics (auto-calculated)
✅ Helpful votes tracking
✅ Row Level Security (RLS) on all tables
✅ Performance indexes
✅ Admin order management
✅ Multiple payment methods support
```

---

## 🔍 Quick Verification

### Verify Tables Created (30 seconds)
Run in SQL Editor:
```sql
SELECT COUNT(*) as table_count 
FROM information_schema.tables 
WHERE table_schema = 'public';
```
**Expected: 13**

### Verify Buckets Created (30 seconds)
Run in SQL Editor:
```sql
SELECT id FROM storage.buckets ORDER BY id;
```
**Expected: 9 buckets listed**

### Test Order Number Generation (10 seconds)
```sql
SELECT generate_order_number();
```
**Expected: ORD-20240115103045-4829 (format)**

---

## 🧪 Quick Test Data

### Add Test Product (30 seconds)
```sql
INSERT INTO products (name, description, price, stock_quantity, category)
VALUES ('Test Product', 'A great test product', 999.99, 50, 'Test');
```

### Add Test Review (30 seconds)
```sql
INSERT INTO reviews (product_id, customer_name, customer_email, rating, review_title, review_text, status)
VALUES (1, 'John Doe', 'john@example.com', 5, 'Excellent!', 'Very satisfied', 'approved');
```

### Add Test Order (30 seconds)
```sql
INSERT INTO orders (customer_name, customer_email, customer_phone, total_amount, street_address, city)
VALUES ('Jane Doe', 'jane@example.com', '9841234567', 5999.99, '123 Main St', 'Kathmandu');
```

### View Results
```sql
SELECT * FROM products LIMIT 1;
SELECT * FROM reviews WHERE status = 'approved';
SELECT order_number FROM orders ORDER BY id DESC LIMIT 1;
SELECT average_rating, reviews_count FROM products WHERE id = 1;
```

---

## 🔐 Security Notes

- ✅ RLS enabled on all tables
- ✅ Public data accessible to anyone
- ✅ Sensitive operations protected
- ✅ Admin operations require authentication

**Important:** Update Supabase credentials in your JavaScript files!

---

## 📂 Files Created for You

1. **COMPLETE_DATABASE_AND_STORAGE_SETUP.sql** (Main setup - 600+ lines)
   - All table definitions
   - All functions
   - All triggers
   - All RLS policies
   - Sample data

2. **DATABASE_SETUP_GUIDE.md** (Complete guide)
   - Detailed setup instructions
   - Schema documentation
   - Function descriptions
   - Troubleshooting

3. **SQL_QUICK_REFERENCE.sql** (Cheat sheet)
   - Common SQL queries
   - CRUD operations
   - Analytics queries
   - Maintenance scripts

4. **STORAGE_BUCKETS_SETUP.sql** (Storage guide)
   - Bucket creation
   - RLS policies for storage
   - Usage examples
   - JavaScript snippets

5. **SETUP_CHECKLIST.md** (Verification checklist)
   - Step-by-step verification
   - Testing procedures
   - Pre-launch checklist
   - Troubleshooting guide

---

## 🎯 Next Steps

### 1. Update Your Application
```javascript
// In supabase-new.js or similar:
const SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE';

// Initialize Supabase
const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
```

Get credentials from:
- Supabase Dashboard → Settings → API → Project URL & Anon Key

### 2. Test Each Feature
- [ ] Product display working
- [ ] Reviews system working
- [ ] Orders placing working
- [ ] Admin panel working
- [ ] Image uploads working

### 3. Upload Images
- Use product management to upload images
- They'll go to the appropriate bucket automatically
- Or upload directly to buckets via dashboard

### 4. Configure Payment Methods
Update the `payment_configuration` table:
```sql
UPDATE payment_configuration 
SET 
  esewa_number = 'YOUR_NUMBER',
  esewa_name = 'YOUR_NAME',
  esewa_active = true
WHERE id = 1;
```

### 5. Go Live!
- Test everything thoroughly
- Set up backups
- Monitor logs
- Celebrate! 🎉

---

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Tables not created | Re-run SQL script, check for errors |
| Buckets not showing | Refresh page, verify PUBLIC toggle ON |
| Images not uploading | Check bucket name, verify file size < 50MB |
| Reviews not showing | Check status = 'approved', verify RLS |
| Orders not saving | Check order_number trigger, verify RLS |
| Permission denied | Enable RLS policies, check JWT token |

---

## 📊 Database Schema Summary

```
Products
├── id (primary key)
├── name, description, price
├── stock_quantity, category
├── reviews_count, average_rating (auto)
└── timestamps (created_at, updated_at)

Product Images (up to 4 per product)
├── id (primary key)
├── product_id (foreign key)
├── image_url, image_order
└── bucket_name

Reviews
├── id (primary key)
├── product_id (foreign key)
├── customer_name, email, rating (1-5)
├── review_title, review_text
├── status (pending/approved/rejected)
└── helpful_count

Orders
├── id (primary key)
├── order_number (auto-generated)
├── customer info (name, email, phone)
├── address info (street, city, etc)
├── payment info (method, transaction code)
├── total_amount, status
└── timestamps

Order Items
├── id (primary key)
├── order_id (foreign key)
├── product_id (foreign key)
├── product_name, quantity, price
└── subtotal
```

---

## 💾 Storage Structure

```
Buckets
├── product-images (main product images)
├── product-images-slot-1 (product image 1)
├── product-images-slot-2 (product image 2)
├── product-images-slot-3 (product image 3)
├── product-images-slot-4 (product image 4)
├── gallery-images (gallery images)
├── videos (promotional videos)
├── transaction-screenshots (payment proofs)
└── service-images (service images)

All buckets: PUBLIC access, 50MB limit (videos: 100MB)
```

---

## 🎓 Learning Path

1. **Beginner**: Follow the 5-Minute Setup above
2. **Intermediate**: Read DATABASE_SETUP_GUIDE.md
3. **Advanced**: Study the SQL code in COMPLETE_DATABASE_AND_STORAGE_SETUP.sql
4. **Expert**: Customize tables and add new features as needed

---

## 📞 Quick Links

- **Supabase Docs**: https://supabase.com/docs
- **PostgreSQL Docs**: https://www.postgresql.org/docs/
- **SQL Cheat Sheet**: Use SQL_QUICK_REFERENCE.sql

---

## ✨ Key Features Explained

### Auto-Generated Order Numbers
```
Format: ORD-20240115103045-4829
- ORD: prefix
- 20240115103045: timestamp
- 4829: random 4 digits
```

### Review Statistics
- Automatically updates when reviews change
- Average rating calculated from approved reviews only
- Review count updated automatically
- Query: `SELECT average_rating, reviews_count FROM products`

### Helpful Votes
- Track which reviews are most helpful
- One vote per user per review (unique constraint)
- Anonymous voting supported

### Payment Methods
- Support for eSewa
- Support for Khalti
- Support for Bank Transfer
- Can activate/deactivate any method

### Row Level Security
- Everyone can read public data
- Only authenticated users can upload
- Admins can manage all content
- Reviews filtered by status

---

## ⏱️ Time Estimates

| Task | Time |
|------|------|
| Run SQL setup | 1-2 minutes |
| Create buckets | 2-3 minutes |
| Add test data | 2-3 minutes |
| Verify setup | 2-3 minutes |
| Update JS files | 5-10 minutes |
| Test all features | 10-15 minutes |
| **Total** | **20-35 minutes** |

---

## 🏁 Completion Checklist

- [ ] SQL script executed successfully
- [ ] All 13 tables created
- [ ] All 9 buckets created and PUBLIC
- [ ] Sample data inserted
- [ ] Order number generation tested
- [ ] Review stats working
- [ ] Supabase credentials updated in code
- [ ] All HTML/JS files updated
- [ ] Features tested in browser
- [ ] No console errors
- [ ] Ready to launch!

---

## 🎉 You're All Set!

Your complete database infrastructure is ready. Now you can:
- ✅ Manage products with multiple images
- ✅ Process orders with payment tracking
- ✅ Manage customer reviews and ratings
- ✅ Book service appointments
- ✅ Upload files to cloud storage
- ✅ Manage everything from admin panel

**Questions?** Check DATABASE_SETUP_GUIDE.md or SETUP_CHECKLIST.md

**Good luck! 🚀**

---

**Last Updated:** January 3, 2026
**Version:** 1.0
**Status:** Production Ready ✅
