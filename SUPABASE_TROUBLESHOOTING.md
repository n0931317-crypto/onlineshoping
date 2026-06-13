# 🐛 Supabase Payment Setup - Troubleshooting Guide

## 📋 Table of Contents
1. [Installation Issues](#installation-issues)
2. [Data Type Errors](#data-type-errors)
3. [Order Insert Failures](#order-insert-failures)
4. [QR Code Problems](#qr-code-problems)
5. [Permission Errors](#permission-errors)

---

## 🔴 Installation Issues

### Problem: "Syntax error" when running SQL

**Causes:**
- Copied partial SQL code
- Extra quotes or special characters
- Line breaks in the middle of statements

**Solutions:**
1. Copy the ENTIRE SQL from `PAYMENT_SUPABASE_SETUP.sql`
2. Make sure there are NO line breaks in table definitions
3. Paste into a fresh SQL query
4. Run step by step if needed

### Problem: "Table already exists"

**This is NORMAL!** The SQL includes:
```sql
DROP TABLE IF EXISTS orders CASCADE;
```

This removes old tables before creating new ones. The error message is expected.

---

## 🟡 Data Type Errors

### Problem: "Type error: cannot insert TEXT into DECIMAL field"

**Why it happens:** 
Sending prices as strings instead of numbers

**Solution:**
The updated payment.html now uses `parseFloat()` for all amounts:
```javascript
subtotal: parseFloat(orderData.subtotal).toFixed(2),
total_amount: parseFloat(orderData.total_amount).toFixed(2)
```

### Problem: "Invalid date format"

**Why it happens:**
Sending full ISO timestamp `2026-01-10T04:20:00.000Z` instead of date

**Solution:**
The updated payment.html now converts to `YYYY-MM-DD`:
```javascript
const isoDate = dateObj.toISOString().split('T')[0];
```

### Problem: "Boolean column received 'yes' or 'no'"

**Why it happens:**
Sending string `'yes'` instead of boolean `true`

**Solution:**
Updated to use proper boolean:
```javascript
has_screenshot: orderData.has_screenshot ? true : false
```

---

## 🔴 Order Insert Failures

### Problem: "Order insert error: details: TypeError"

**Debug Steps:**

**Step 1:** Check browser console (F12)
Look for:
- What column is causing the error?
- What type was sent?
- What type was expected?

**Step 2:** Run this query to check table schema:
```sql
\d orders
```

**Step 3:** Compare with payment.html line 1020+:
```javascript
const orderToInsert = {
    order_number: String(orderData.order_number).trim(),
    customer_name: String(orderData.customer_name).trim(),
    customer_email: String(orderData.customer_email || 'no-email').trim(),
    customer_phone: String(orderData.customer_phone).trim(),
    delivery_address: String(orderData.delivery_address).trim(),
    delivery_date: orderData.delivery_date,  // YYYY-MM-DD only
    delivery_notes: String(orderData.delivery_notes || '').trim(),
    subtotal: parseFloat(orderData.subtotal) || 0,
    delivery_charge: parseFloat(orderData.delivery_charge) || 50,
    total_amount: parseFloat(orderData.total_amount),
    status: 'pending_verification',
    payment_method: String(orderData.payment_method).toLowerCase().trim(),
    transaction_code: String(orderData.transaction_code).trim(),
    has_screenshot: orderData.has_screenshot ? true : false
};
```

**Step 3:** If still failing, manually test:
```sql
INSERT INTO orders (
    order_number, customer_name, customer_email, customer_phone,
    delivery_address, delivery_date, delivery_notes, subtotal,
    delivery_charge, total_amount, status, payment_method,
    transaction_code, has_screenshot
) VALUES (
    'TEST-12345', 'John Doe', 'john@example.com', '9841234567',
    'Kathmandu, Nepal', '2026-01-15', 'Test notes', 1450.00,
    50.00, 1500.00, 'pending_verification', 'esewa',
    'TXN-123456', true
);
```

If this works, the issue is data format in payment.html.

---

## 🟡 QR Code Problems

### Problem: "QR code not loading" message appears

**Causes:**
1. No QR codes configured in admin_settings
2. Invalid QR code URL
3. Database can't be reached

**Solutions:**

**Step 1:** Check if admin_settings has data:
```sql
SELECT * FROM admin_settings;
```

Should show 3 columns with URLs:
- qr_esewa
- qr_khalti
- qr_bank

**Step 2:** If empty or null, insert sample QR codes:
```sql
UPDATE admin_settings 
SET qr_esewa = 'https://via.placeholder.com/300?text=eSewa',
    qr_khalti = 'https://via.placeholder.com/300?text=Khalti',
    qr_bank = 'https://via.placeholder.com/300?text=Bank'
WHERE id = 1;
```

**Step 3:** If you have real QR codes, upload to Supabase Storage:
1. Go to Supabase Dashboard → Storage
2. Create bucket called `qr-codes`
3. Upload your QR images
4. Get public URL for each
5. Update admin_settings:
```sql
UPDATE admin_settings 
SET qr_esewa = 'https://your-project.supabase.co/storage/v1/object/public/qr-codes/esewa.png'
WHERE id = 1;
```

---

## 🔴 Permission Errors

### Problem: "Permission denied" when inserting orders

**Cause:** RLS policies not set correctly

**Solution:** Run these commands:

```sql
-- Enable RLS on all tables
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

-- Create policies (delete old ones first if they exist)
DROP POLICY IF EXISTS "Allow insert orders" ON orders;
DROP POLICY IF EXISTS "Allow select own orders" ON orders;
DROP POLICY IF EXISTS "Allow select order items" ON order_items;
DROP POLICY IF EXISTS "Allow insert order items" ON order_items;
DROP POLICY IF EXISTS "Allow select admin_settings" ON admin_settings;

-- Create new policies
CREATE POLICY "Allow insert orders" ON orders
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Allow select own orders" ON orders
    FOR SELECT
    USING (true);

CREATE POLICY "Allow select order items" ON order_items
    FOR SELECT
    USING (true);

CREATE POLICY "Allow insert order items" ON order_items
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Allow select admin_settings" ON admin_settings
    FOR SELECT
    USING (true);
```

### Problem: "Insufficient privileges" error

**Cause:** Your Supabase user is not the owner

**Solution:**
1. Go to Supabase Dashboard
2. Click your project
3. Go to Settings → Users
4. Ensure your user has "Owner" role
5. If not, ask the owner to grant access

---

## ✅ Verification Checklist

Before testing the payment page, verify:

- [ ] All 3 tables exist (orders, order_items, admin_settings)
- [ ] admin_settings has at least one row
- [ ] RLS policies are created
- [ ] You can manually insert test data into orders table
- [ ] payment.html has correct Supabase URL and API key
- [ ] Browser console shows no JavaScript errors

---

## 🧪 Full Test Procedure

1. **Test Database Insert:**
   ```sql
   INSERT INTO orders (order_number, customer_name, customer_email, 
       customer_phone, delivery_address, delivery_date, total_amount,
       status, payment_method, transaction_code, has_screenshot)
   VALUES ('TEST-001', 'Test User', 'test@example.com', '9841234567',
       'Test Address', '2026-01-15', 1500.00, 'pending_verification',
       'esewa', 'TXN-TEST', false);
   ```

2. **Test QR Code Query:**
   ```sql
   SELECT qr_esewa, qr_khalti, qr_bank FROM admin_settings LIMIT 1;
   ```
   Should return 3 URLs or placeholder images.

3. **Test Payment Page:**
   - Open payment.html
   - Add item to cart
   - Go to checkout
   - Select payment method (should show QR)
   - Enter transaction code
   - Upload screenshot
   - Click "Place Order"
   - Check browser console for success message

4. **Verify Order in Database:**
   ```sql
   SELECT * FROM orders WHERE status = 'pending_verification' LIMIT 1;
   ```

---

## 📞 If Still Having Issues

1. **Check Supabase Logs:**
   - Project → Logs
   - Look for error messages

2. **Check Browser Console:**
   - F12 → Console tab
   - Look for JavaScript errors

3. **Verify Configuration:**
   - Open payment.html
   - Check line ~622 for SUPABASE_URL
   - Verify it matches your project URL

4. **Test Network:**
   - Network tab (F12) → Look for failed requests
   - Check if Supabase is responding

---

## 🎯 Quick Fixes Summary

| Error | Fix |
|-------|-----|
| Syntax error in SQL | Copy entire script, paste in fresh query |
| Table doesn't exist | Run entire PAYMENT_SUPABASE_SETUP.sql |
| Type error on insert | Check data types in payment.html match table schema |
| QR code missing | Insert sample QR URLs in admin_settings |
| Permission denied | Create RLS policies from Troubleshooting guide |
| Orders not appearing | Check RLS policies allow INSERT |
| Date format error | Ensure payment.html sends YYYY-MM-DD format |

---

**Last Updated:** January 5, 2026  
**Status:** ✅ Complete Payment System Setup
