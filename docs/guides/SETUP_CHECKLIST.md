# Complete Website Setup Checklist

## 📋 Database Setup

### Step 1: Create All Tables
- [ ] Copy entire SQL from `COMPLETE_DATABASE_AND_STORAGE_SETUP.sql`
- [ ] Go to Supabase Dashboard → SQL Editor
- [ ] Paste SQL code
- [ ] Click "Run"
- [ ] Verify all tables created successfully

### Step 2: Verify Table Creation
Run verification query in SQL Editor:
```sql
SELECT COUNT(*) as table_count FROM information_schema.tables 
WHERE table_schema = 'public';
```
Expected result: **13 tables**

### Step 3: Check All Required Tables Exist
- [ ] admin_users
- [ ] services
- [ ] products
- [ ] product_images
- [ ] reviews
- [ ] review_helpful_votes
- [ ] appointments
- [ ] gallery
- [ ] home_video
- [ ] payment_configuration
- [ ] orders
- [ ] order_items
- [ ] settings

---

## 🗄️ Storage Bucket Setup

### Method 1: Dashboard Setup (Recommended)

Go to Supabase Dashboard → Storage → Create new bucket

Create these buckets (in order):

- [ ] **product-images**
  - Name: `product-images`
  - Public: ✅ ON
  - Click "Create"

- [ ] **product-images-slot-1**
  - Name: `product-images-slot-1`
  - Public: ✅ ON
  - Click "Create"

- [ ] **product-images-slot-2**
  - Name: `product-images-slot-2`
  - Public: ✅ ON
  - Click "Create"

- [ ] **product-images-slot-3**
  - Name: `product-images-slot-3`
  - Public: ✅ ON
  - Click "Create"

- [ ] **product-images-slot-4**
  - Name: `product-images-slot-4`
  - Public: ✅ ON
  - Click "Create"

- [ ] **gallery-images**
  - Name: `gallery-images`
  - Public: ✅ ON
  - Click "Create"

- [ ] **videos**
  - Name: `videos`
  - Public: ✅ ON
  - Click "Create"

- [ ] **transaction-screenshots**
  - Name: `transaction-screenshots`
  - Public: ✅ ON
  - Click "Create"

- [ ] **service-images**
  - Name: `service-images`
  - Public: ✅ ON
  - Click "Create"

### Method 2: SQL Setup (Alternative)

- [ ] Copy SQL from `STORAGE_BUCKETS_SETUP.sql`
- [ ] Paste in Supabase SQL Editor
- [ ] Run the SQL commands
- [ ] Verify buckets created using verification query

### Verify Bucket Creation
Run this in SQL Editor:
```sql
SELECT id as bucket_name, public FROM storage.buckets 
ORDER BY id;
```
Expected result: **9 buckets**, all with `public = true`

---

## 🔐 Row Level Security (RLS)

### Verify RLS is Enabled
- [ ] All tables have RLS policies in place (included in main SQL)
- [ ] Check: Supabase Dashboard → Database → Tables → Each table → RLS toggle

### Policies Applied For:
- [ ] admin_users - Admin only
- [ ] products - Public READ
- [ ] services - Public READ
- [ ] product_images - Public READ (active only)
- [ ] reviews - Public READ (approved only), Anyone can INSERT
- [ ] review_helpful_votes - Public READ, Anyone can INSERT
- [ ] appointments - Anyone can INSERT and READ
- [ ] gallery - Public READ (active only)
- [ ] home_video - Public READ (active only)
- [ ] payment_configuration - Public READ (active only)
- [ ] orders - Anyone can INSERT, READ, UPDATE
- [ ] order_items - Anyone can INSERT, READ
- [ ] settings - Public READ (active only)

---

## 📝 Sample Data Setup

### Insert Sample Payment Configuration
Run in SQL Editor:
```sql
INSERT INTO payment_configuration (
    esewa_number, esewa_name, esewa_active,
    khalti_number, khalti_name, khalti_active,
    bank_name, bank_account, bank_holder, bank_code, bank_active,
    is_active
) VALUES (
    '033590207', 'Sunlights', true,
    '033590207', 'Sunlights', true,
    'NIC ASIA BANK', '1234567890123456', 'Sunlights', 'NICAASIA', true,
    true
) ON CONFLICT DO NOTHING;
```
- [ ] Verified: Payment config inserted

### Insert Sample Service
- [ ] Sample service inserted (included in main SQL)
- [ ] Verify: SELECT COUNT(*) FROM services;

### Insert Sample Product
- [ ] Sample product inserted (included in main SQL)
- [ ] Verify: SELECT COUNT(*) FROM products;

---

## 🔧 Functions & Triggers

### Verify Functions Created
- [ ] generate_order_number() - Generates unique order numbers
- [ ] trigger_update_timestamp() - Updates timestamp on every update
- [ ] update_order_status() - Updates order status and notes
- [ ] get_order_details() - Retrieves complete order details
- [ ] update_product_reviews_stats() - Updates review stats

### Verify Triggers Created
- [ ] trg_set_order_number - Auto-generates order number
- [ ] trg_update_*_timestamp - Auto-updates timestamps on all tables
- [ ] trigger_update_product_reviews_stats - Auto-updates product review stats

### Test Functions
```sql
-- Test order number generation
SELECT generate_order_number();

-- Test order status update (use actual order ID)
-- SELECT update_order_status(1, 'confirmed', 'Test');

-- Test order details retrieval (use actual order ID)
-- SELECT * FROM get_order_details(1);
```
- [ ] Order number generation working
- [ ] All functions callable

---

## 🌐 Application Configuration

### Update JavaScript Files

#### File: supabase-new.js (or similar)
- [ ] Update SUPABASE_URL to your actual URL
- [ ] Update SUPABASE_ANON_KEY to your actual key
- [ ] Verify Supabase client initialization

Find these in Supabase Dashboard:
- Settings → API → Project URL
- Settings → API → Anon Public Key

```javascript
// Example (replace with your actual credentials)
const SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE';
```

#### File: payment.html / payment.js
- [ ] Update payment methods with correct details
- [ ] Verify eSewa, Khalti, Bank details match payment_configuration table
- [ ] Test payment flow

#### File: product-details.html
- [ ] Initialize reviews section: `initializeReviews(productId)`
- [ ] Verify review form working
- [ ] Test submitting a review

#### File: admin-sunlight.html (or admin.html)
- [ ] Verify admin can view pending orders
- [ ] Verify admin can update order status
- [ ] Verify admin can see all reviews

### Check All HTML/JS Files Updated
- [ ] index.html - Homepage and products loading
- [ ] product-details.html - Product display and reviews
- [ ] about.html - Services display
- [ ] admin.html - Admin panel
- [ ] payment.html - Payment gateway
- [ ] orders.html - Order tracking
- [ ] track.html - Order status tracking
- [ ] script.js - Main app logic
- [ ] admin.js - Admin functions

---

## 🧪 Testing Checklist

### Product Management
- [ ] Can view all products
- [ ] Can see product details
- [ ] Product images display correctly
- [ ] Product reviews show (if approved)
- [ ] Average rating calculated correctly

### Orders
- [ ] Can create new order
- [ ] Order number auto-generates
- [ ] Can add items to order
- [ ] Total amount calculated
- [ ] Can upload transaction screenshot
- [ ] Can view order status
- [ ] Can track order by phone/email

### Reviews
- [ ] Can submit review
- [ ] Review shows as pending initially
- [ ] Admin can approve/reject review
- [ ] Approved reviews visible to all
- [ ] Rating stars display
- [ ] Helpful votes working
- [ ] Product average rating updates

### Appointments
- [ ] Can book appointment
- [ ] Can select service
- [ ] Can select date and time
- [ ] Admin receives appointment notification

### Gallery
- [ ] Gallery images display
- [ ] Images ordered correctly
- [ ] Can upload to gallery

### Services
- [ ] Services display correctly
- [ ] Can book service appointment
- [ ] Service details visible

### Payment Methods
- [ ] eSewa details showing (if enabled)
- [ ] Khalti details showing (if enabled)
- [ ] Bank details showing (if enabled)
- [ ] Can select payment method

### Admin Panel
- [ ] Can login to admin panel
- [ ] Can view all orders
- [ ] Can update order status
- [ ] Can add/edit products
- [ ] Can add/edit services
- [ ] Can view pending orders
- [ ] Can view all reviews
- [ ] Can approve/reject reviews

---

## 🚀 Pre-Launch Checklist

### Database & Tables
- [ ] All 13 tables created
- [ ] All indexes created
- [ ] All functions created
- [ ] All triggers created
- [ ] All RLS policies set
- [ ] Sample data inserted

### Storage
- [ ] All 9 buckets created
- [ ] All buckets set to PUBLIC
- [ ] RLS policies set on buckets
- [ ] Can upload files successfully

### Application
- [ ] Supabase credentials updated
- [ ] All HTML/JS files updated
- [ ] All features tested
- [ ] No console errors
- [ ] Responsive design verified
- [ ] All links working

### Admin Features
- [ ] Admin login working
- [ ] Admin can manage products
- [ ] Admin can manage orders
- [ ] Admin can manage reviews
- [ ] Admin can manage services
- [ ] Admin can manage settings

### Security
- [ ] RLS policies working correctly
- [ ] Public data truly public
- [ ] Sensitive data protected
- [ ] No hardcoded credentials
- [ ] HTTPS enabled
- [ ] CORS properly configured

### Performance
- [ ] Database queries optimized
- [ ] Images optimized
- [ ] Page load time < 3 seconds
- [ ] Search working fast
- [ ] Pagination working (if needed)

### Mobile
- [ ] Mobile responsive design
- [ ] Touch buttons properly sized
- [ ] Forms work on mobile
- [ ] Images load on mobile
- [ ] No horizontal scroll

---

## 📊 Database Optimization

### Indexes
- [ ] Verify all indexes created:
  - products.created_at
  - products.is_active
  - products.category
  - orders.created_at
  - orders.status
  - reviews.product_id
  - reviews.status
  - appointments.date
  - gallery.display_order

### Query Performance
Run these to check performance:
```sql
-- Check table sizes
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check row counts
SELECT 
    tablename,
    n_live_tup as row_count
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY n_live_tup DESC;
```

- [ ] Verified table sizes reasonable
- [ ] Verified row counts reasonable
- [ ] No missing indexes

---

## 🔄 Backup & Maintenance

### Supabase Backups
- [ ] Enable automatic backups in Supabase settings
- [ ] Set backup frequency (daily recommended)
- [ ] Test backup restoration

### Manual Backup
- [ ] Schedule regular SQL exports
- [ ] Store backups securely
- [ ] Document backup procedure

### Maintenance Schedule
- [ ] Weekly: Check error logs
- [ ] Weekly: Verify all features working
- [ ] Monthly: Review analytics
- [ ] Monthly: Optimize database (VACUUM)
- [ ] Quarterly: Security audit

---

## 📚 Documentation

### Documentation Created
- [ ] DATABASE_SETUP_GUIDE.md - Complete setup guide
- [ ] COMPLETE_DATABASE_AND_STORAGE_SETUP.sql - Full SQL
- [ ] SQL_QUICK_REFERENCE.sql - Common queries
- [ ] STORAGE_BUCKETS_SETUP.sql - Storage setup
- [ ] This checklist - Setup verification

### Additional Documentation to Create
- [ ] API documentation (if needed)
- [ ] User manual
- [ ] Admin manual
- [ ] Troubleshooting guide
- [ ] Deployment guide

---

## 🆘 Troubleshooting

### Common Issues & Solutions

**Issue: "Permission denied" error**
- Solution: Check RLS policies are correct
- Solution: Verify bucket is public
- Solution: Run RLS setup section again

**Issue: "Table does not exist"**
- Solution: Re-run entire SQL setup script
- Solution: Check table name spelling
- Solution: Verify schema is 'public'

**Issue: Images not uploading**
- Solution: Verify bucket name matches exactly
- Solution: Check bucket is public
- Solution: Verify file size within limits
- Solution: Check CORS settings

**Issue: Reviews not showing**
- Solution: Verify status = 'approved'
- Solution: Check RLS policies
- Solution: Verify product_id exists

**Issue: Orders not saving**
- Solution: Check order_number trigger
- Solution: Verify RLS policies allow INSERT
- Solution: Check timestamp trigger

**Issue: Payment configuration not loading**
- Solution: Verify is_active = true
- Solution: Check RLS policies
- Solution: Verify data inserted

---

## ✅ Final Verification

### Run These Tests

1. **Test Product Creation**
```sql
INSERT INTO products (name, description, price, stock_quantity, category)
VALUES ('Test Product', 'Test Description', 999.99, 10, 'Test')
RETURNING id;
```

2. **Test Order Creation**
```sql
INSERT INTO orders (customer_name, customer_email, customer_phone, total_amount, street_address, city)
VALUES ('Test', 'test@example.com', '9841234567', 999.99, '123 St', 'City')
RETURNING order_number;
```

3. **Test Review Creation & Stats Update**
```sql
INSERT INTO reviews (product_id, customer_name, customer_email, rating, review_title, review_text, status)
VALUES (1, 'Tester', 'test@example.com', 5, 'Great!', 'Very good product', 'approved');

SELECT average_rating, reviews_count FROM products WHERE id = 1;
```

4. **Verify Timestamp Trigger**
```sql
UPDATE products SET name = 'Updated' WHERE id = 1;
SELECT updated_at FROM products WHERE id = 1;
```

5. **Verify Order Number Generation**
```sql
SELECT order_number FROM orders ORDER BY id DESC LIMIT 1;
```

- [ ] All tests passed
- [ ] All functions working
- [ ] All triggers firing

---

## 🎉 Launch Readiness

- [ ] All checklist items completed
- [ ] All tests passing
- [ ] No console errors
- [ ] All features tested manually
- [ ] Database backed up
- [ ] Security verified
- [ ] Performance optimized
- [ ] Documentation complete

---

## 📞 Support Resources

- Supabase Documentation: https://supabase.com/docs
- PostgreSQL Documentation: https://www.postgresql.org/docs/
- Storage Best Practices: https://supabase.com/docs/guides/storage

---

## 📅 Maintenance Schedule

After launch, maintain the following:

**Daily:**
- Monitor error logs
- Check for failed orders/appointments

**Weekly:**
- Verify all features working
- Check database performance
- Review pending reviews

**Monthly:**
- Analyze usage statistics
- Optimize database queries
- Update analytics
- Review security logs

**Quarterly:**
- Full system audit
- Backup verification
- Security assessment
- Performance review

---

**Setup completed on: ___________**

**Verified by: ___________**

**Notes: ____________________________________________________________**

