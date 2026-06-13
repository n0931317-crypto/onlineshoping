# 🔧 Admin Panel - Order Status Update Setup

## The Problem

Your admin panel shows errors when trying to update order status:
- ❌ "Failed to load resource: net::ERR_NAME_NOT_RESOLVED"
- ❌ "Failed to load resource: status of 400"
- ❌ "Error updating order status: Object"

## Root Causes

1. **Missing RLS Policies** - Tables don't have UPDATE/DELETE permissions
2. **Missing Columns** - `admin_notes` and `confirmed_by_admin` columns missing
3. **Wrong Supabase URL** - (Already fixed in payment.html)

## Solution - 3 Steps

### Step 1: Run the SQL Setup (2 minutes)

**Go to:** https://app.supabase.com → Your Project → SQL Editor

**Copy and Paste:** The entire content from `ADMIN_COMPLETE_SETUP.sql`

**Click:** [RUN] button

**You should see:**
```
✅ Orders table created
✅ Order items table created
✅ Admin settings table created
✅ All 8 RLS policies created
✅ Indexes created
```

### Step 2: Verify Tables in Supabase (1 minute)

1. Go to **Tables** in left sidebar
2. Click **orders** table
3. Verify these columns exist:
   - ✅ `id`
   - ✅ `order_number`
   - ✅ `customer_name`
   - ✅ `customer_email`
   - ✅ `customer_phone`
   - ✅ `delivery_address`
   - ✅ `delivery_date`
   - ✅ `subtotal`
   - ✅ `delivery_charge`
   - ✅ `total_amount`
   - ✅ `status` (this is what gets updated)
   - ✅ `payment_method`
   - ✅ `transaction_code`
   - ✅ `has_screenshot`
   - ✅ `admin_notes` (NEW - for admin comments)
   - ✅ `confirmed_by_admin` (NEW - tracks if admin verified)
   - ✅ `created_at`
   - ✅ `updated_at`

4. Click **admin_settings** table
5. Verify columns:
   - ✅ `qr_esewa`
   - ✅ `qr_khalti`
   - ✅ `qr_bank`
   - ✅ `delivery_charge`

### Step 3: Test Admin Panel (5 minutes)

1. **Go to:** Your admin panel
2. **Log in** with credentials:
   - Email: `diwashb32@gmail.com`
   - Password: `dipak@121`

3. **Find an order** in the list
4. **Click:** "View Details" button
5. **Click:** "Update Status" button
6. **Change status** to "Verified"
7. **Add notes** (optional): "Order verified by admin"
8. **Click:** "Update Status" button

**Expected Result:**
- ✅ No console errors
- ✅ Success notification appears
- ✅ Order status changes in database
- ✅ Order reappears in list with new status

## What Each Column Does

### Status Updates
The admin can change these statuses:
- `pending_verification` → `verified` (Customer paid, order confirmed)
- `verified` → `processing` (Getting items ready)
- `processing` → `shipped` (Order on the way)
- `shipped` → `delivered` (Customer received)

### Admin Columns
- **admin_notes**: Comments about the order (why verified, delays, etc.)
- **confirmed_by_admin**: `true` when admin manually checks & updates

## Troubleshooting

### Error: "Column admin_notes does not exist"
**Solution:** Run `ADMIN_COMPLETE_SETUP.sql` again - the new columns are added there.

### Error: "No UPDATE permissions"
**Solution:** The RLS policies are in `ADMIN_COMPLETE_SETUP.sql`. Re-run to add them.

### Error: "Invalid JWT token"
**Solution:** The credentials are in `supabase-new.js`. They should be:
```javascript
const SUPABASE_URL = 'https://yngmogqtfyrnpkwtasut.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InluZ21vZ3F0ZnlybnBrd3Rhc3V0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc0NDI5MzEsImV4cCI6MjA4MzAxODkzMX0.y3rW8dq9prOg3-hAJeXUjcBZluRTD9LfUhyiOa5s2C4';
```

### Error: "Failed to fetch"
**Solution:** Check browser console (F12):
1. Go to **Console** tab
2. Look for error messages
3. Check if `✅ Supabase client initialized successfully` appears
4. If not, refresh page and wait 2 seconds

## How It Works

### When Admin Clicks "Update Status"

```
1. Admin selects new status (e.g., "Verified")
2. Admin types notes (optional)
3. Clicks "Update Status" button
   ↓
4. JavaScript calls submitStatusUpdate()
   ↓
5. Function sends UPDATE query to Supabase:
   UPDATE orders
   SET status = 'verified',
       admin_notes = '...',
       confirmed_by_admin = true,
       updated_at = NOW()
   WHERE id = [orderId]
   ↓
6. Supabase checks RLS policies:
   "Allow update orders" → Allows? YES ✅
   ↓
7. Database updates successfully
   ↓
8. Admin panel shows success message
   ↓
9. Order list refreshes with new status
```

## Database Diagram

```
┌─────────────────────────────────────┐
│         ADMIN LOGIN                 │
│                                     │
│ Email: diwashb32@gmail.com         │
│ Password: dipak@121                │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│     LOAD ORDERS FROM SUPABASE       │
│                                     │
│ SELECT * FROM orders                │
│ WHERE status IN (                   │
│   'pending_verification',           │
│   'verified',                       │
│   'processing',                     │
│   'shipped',                        │
│   'delivered'                       │
│ )                                   │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│    DISPLAY ORDER IN ADMIN PANEL     │
│                                     │
│ Order #ORD-1767600305080            │
│ Name: dipak                         │
│ Email: askld@gmail.com              │
│ Status: Pending  [View Details]     │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│   CLICK "View Details" BUTTON       │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│  SHOW ORDER MODAL WITH ALL INFO     │
│                                     │
│ Order #ORD-1767600305080            │
│ Customer: dipak (93298023...)        │
│ Address: dkjsal, flkakd, 1231        │
│ Total: Rs. 14596.00                 │
│ Status: Pending                     │
│                                     │
│ [Update Status] [Close]             │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│  CLICK "Update Status" BUTTON       │
└────────────┬────────────────────────┘
             │
             ↓
┌──────────────────────────────────────┐
│  SHOW STATUS UPDATE DIALOG           │
│                                      │
│  New Status: [Dropdown ▼]            │
│    - Verified                        │
│    - Processing                      │
│    - Shipped                         │
│    - Delivered                       │
│                                      │
│  Admin Notes:                        │
│  [Text area for comments...]         │
│                                      │
│  [Cancel]  [Update Status ✓]        │
└──────────────┬──────────────────────┘
               │
               ↓
┌──────────────────────────────────────┐
│  CLICK "Update Status" BUTTON        │
│                                      │
│  JavaScript runs:                    │
│  submitStatusUpdate(orderId)         │
└──────────────┬──────────────────────┘
               │
               ↓
┌──────────────────────────────────────┐
│  SUPABASE UPDATE QUERY               │
│                                      │
│  const { error } = await client      │
│    .from('orders')                   │
│    .update({                         │
│      status: 'verified',             │
│      admin_notes: '...',             │
│      confirmed_by_admin: true,       │
│      updated_at: NOW()               │
│    })                                │
│    .eq('id', orderId)                │
└──────────────┬──────────────────────┘
               │
               ↓
┌──────────────────────────────────────┐
│  SUPABASE CHECKS RLS POLICIES        │
│                                      │
│  "Allow update orders" policy:       │
│  FOR UPDATE USING (true)             │
│  WITH CHECK (true)                   │
│                                      │
│  Result: ✅ ALLOWED                  │
└──────────────┬──────────────────────┘
               │
               ↓
┌──────────────────────────────────────┐
│  DATABASE UPDATES                    │
│                                      │
│  UPDATE orders SET                   │
│    status = 'verified',              │
│    admin_notes = '...',              │
│    confirmed_by_admin = true,        │
│    updated_at = '2026-01-05 ...'     │
│  WHERE id = 1234567                  │
│                                      │
│  Result: ✅ 1 row updated            │
└──────────────┬──────────────────────┘
               │
               ↓
┌──────────────────────────────────────┐
│  SHOW SUCCESS MESSAGE                │
│                                      │
│  "Order status updated successfully" │
│  ✅                                   │
│                                      │
│  (Auto-dismiss in 3 seconds)        │
└──────────────┬──────────────────────┘
               │
               ↓
┌──────────────────────────────────────┐
│  RELOAD ORDERS LIST                  │
│                                      │
│  Order now shows: Status: Verified   │
│  Updated by admin                    │
│                                      │
│  Admin can update again or view      │
│  another order                       │
└──────────────────────────────────────┘
```

## RLS Policies Explained

The SQL creates 8 RLS policies:

### Orders Table (4 policies)
1. **Allow insert orders** - Customers can place orders from checkout
2. **Allow select orders** - Anyone can view orders
3. **Allow update orders** - Admin can update status/notes
4. **Allow delete orders** - Admin can delete if needed

### Order Items Table (4 policies)
1. **Allow insert order items** - Items added with order
2. **Allow select order items** - Anyone can view items
3. **Allow update order items** - Can modify items if needed
4. **Allow delete order items** - Can remove items if needed

### Admin Settings Table (3 policies)
1. **Allow select admin settings** - Everyone sees QR codes on payment page
2. **Allow insert admin settings** - Initial setup
3. **Allow update admin settings** - Admin can update QR codes

## Next Steps After Setup

### 1. Test Order Update
- [ ] Place test order from payment page
- [ ] Go to admin panel
- [ ] Update order status to "Verified"
- [ ] Confirm success message appears

### 2. Configure Payment Methods
- [ ] Upload real QR codes in admin panel
- [ ] Add merchant IDs for eSewa/Khalti
- [ ] Test payment page shows correct QR codes

### 3. Monitor Orders
- [ ] Check orders appear with correct data
- [ ] Verify status updates work smoothly
- [ ] Check admin notes save correctly

### 4. Setup Notifications (Optional)
- [ ] Configure email notifications
- [ ] Test order confirmation emails
- [ ] Setup status update emails

## Commands Quick Reference

### Check if Supabase is initialized
```javascript
// Open F12 Console in admin panel, paste this:
console.log('Supabase Client:', window.supabaseClient);
console.log('Supabase Status:', window.supabaseClient ? '✅ Ready' : '❌ Not ready');
```

### Check RLS Policies
```sql
-- Run in Supabase SQL Editor:
SELECT tablename, policyname, permissive
FROM pg_policies
WHERE tablename IN ('orders', 'order_items', 'admin_settings')
ORDER BY tablename, policyname;
```

### Check Table Columns
```sql
-- Run in Supabase SQL Editor:
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'orders'
ORDER BY ordinal_position;
```

## Success Checklist

- [ ] `ADMIN_COMPLETE_SETUP.sql` runs without errors
- [ ] 3 tables exist: orders, order_items, admin_settings
- [ ] 8 RLS policies created
- [ ] 5 indexes created
- [ ] Admin login works
- [ ] Order list loads
- [ ] Can click "View Details"
- [ ] Can click "Update Status"
- [ ] Status changes successfully
- [ ] Admin notes save
- [ ] No console errors (F12)

---

## 🎯 Summary

Your admin panel needs the SQL setup to add:
1. ✅ UPDATE permissions for order status changes
2. ✅ New columns for admin_notes and confirmed_by_admin
3. ✅ RLS policies to allow these operations

**Run `ADMIN_COMPLETE_SETUP.sql` and your admin panel will work perfectly!**

