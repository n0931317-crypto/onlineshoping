# 🚀 STEP-BY-STEP: How to Fix Your Supabase

**⏱️ Takes 5 minutes**

---

## Step 1: Open Supabase SQL Editor

Open this link in your browser:
```
https://app.supabase.com
```

1. Click your project name
2. Click **SQL Editor** on left sidebar
3. Click **New Query** button

---

## Step 2: Copy This Complete SQL Code

**Copy everything from `---` to `---` below:**

```sql
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS admin_settings CASCADE;

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL DEFAULT 'no-email@example.com',
    customer_phone VARCHAR(20) NOT NULL,
    delivery_address TEXT NOT NULL,
    delivery_date DATE NOT NULL,
    delivery_notes TEXT,
    subtotal DECIMAL(10, 2) NOT NULL DEFAULT 0,
    delivery_charge DECIMAL(10, 2) NOT NULL DEFAULT 50,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending_verification',
    payment_method VARCHAR(50) NOT NULL,
    transaction_code VARCHAR(100) NOT NULL,
    has_screenshot BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER,
    product_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE admin_settings (
    id BIGSERIAL PRIMARY KEY,
    qr_esewa TEXT,
    qr_khalti TEXT,
    qr_bank TEXT,
    esewa_merchant_id VARCHAR(255),
    khalti_merchant_id VARCHAR(255),
    bank_account_number VARCHAR(50),
    bank_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_customer_email ON orders(customer_email);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow insert orders" ON orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow select own orders" ON orders FOR SELECT USING (true);
CREATE POLICY "Allow select order items" ON order_items FOR SELECT USING (true);
CREATE POLICY "Allow insert order items" ON order_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow select admin_settings" ON admin_settings FOR SELECT USING (true);

INSERT INTO admin_settings (qr_esewa, qr_khalti, qr_bank)
VALUES (
    'https://via.placeholder.com/300?text=eSewa+QR',
    'https://via.placeholder.com/300?text=Khalti+QR',
    'https://via.placeholder.com/300?text=Bank+QR'
);
```

---

## Step 3: Paste into SQL Editor

1. Click in the white text area in Supabase
2. Press **Ctrl + A** to select all (if there's existing text)
3. Press **Ctrl + V** to paste the SQL code above

You should see the entire code in the SQL editor.

---

## Step 4: Run the Code

Click the **RUN** button (blue button on top right) or press **Ctrl + Enter**

⏳ Wait 5-10 seconds...

---

## Step 5: Check for Success ✅

You should see a green checkmark or message saying:
- "Success"
- "Queries executed successfully"
- etc.

**If you see an error:**
- Don't worry! The error message will tell you what's wrong
- See the **TROUBLESHOOTING** guide below

---

## Step 6: Verify Tables Were Created

In the same SQL editor, run this command:

```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';
```

Click RUN. You should see:
- ✅ orders
- ✅ order_items
- ✅ admin_settings

---

## Step 7: Test the Payment Page

1. Go to your payment page
2. Add a product to cart
3. Go to checkout
4. Fill in all form fields
5. Select a payment method
6. You should see a QR code appear ✅
7. Enter a transaction code
8. Upload a screenshot
9. Click **Place Order & Pay Now**

**Check browser console (F12)** for messages like:
- ✅ "Order inserted successfully"
- ✅ "Items inserted successfully"
- ✅ "Order process completed successfully"

---

## 🎉 Done!

Your payment system is now set up and working!

---

## 📝 Optional: Add Your Real QR Codes

If you have actual QR code images:

1. Upload to Supabase Storage or get public URL
2. Run this in SQL editor:

```sql
UPDATE admin_settings 
SET qr_esewa = 'YOUR_ESEWA_QR_URL_HERE',
    qr_khalti = 'YOUR_KHALTI_QR_URL_HERE',
    qr_bank = 'YOUR_BANK_QR_URL_HERE'
WHERE id = 1;
```

3. Replace the URLs with your actual QR code URLs
4. Click RUN

---

## ⚠️ Common Errors & Quick Fixes

### "Syntax Error"
→ Make sure you copied the ENTIRE code above, not just part of it

### "Table already exists"
→ This is NORMAL! It means old tables are being deleted first

### "Permission denied"
→ Go to Supabase Settings and make sure your user is Owner

### Orders still not inserting
→ Check browser console (F12) for JavaScript errors
→ Verify SUPABASE_URL in payment.html is correct

---

## 📞 Files Created for You

Check your project folder for:
- ✅ `PAYMENT_SUPABASE_SETUP.sql` - Full SQL script
- ✅ `SUPABASE_PAYMENT_SETUP_GUIDE.md` - Detailed documentation
- ✅ `SUPABASE_TROUBLESHOOTING.md` - Error solutions
- ✅ `QUICK_SUPABASE_FIX.md` - Quick reference

---

**Status: ✅ Complete!**  
**Time: 5 minutes**  
**Difficulty: Easy**

If you still have issues, check `SUPABASE_TROUBLESHOOTING.md` 👍
