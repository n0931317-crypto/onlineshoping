# ⚡ Quick Steps to Fix Supabase (Copy-Paste Instructions)

## Step 1️⃣: Open Supabase SQL Editor

1. Go to: **https://app.supabase.com**
2. Click your project
3. Click **SQL Editor** (left sidebar)
4. Click **New Query** button

---

## Step 2️⃣: Copy the SQL Code

**Copy everything below (from -- to the last line):**

```sql
-- DROP EXISTING TABLES
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS admin_settings CASCADE;

-- CREATE ORDERS TABLE
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

-- CREATE ORDER_ITEMS TABLE
CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER,
    product_name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- CREATE ADMIN_SETTINGS TABLE
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

-- CREATE INDEXES
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_customer_email ON orders(customer_email);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

-- ENABLE RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_settings ENABLE ROW LEVEL SECURITY;

-- CREATE RLS POLICIES
CREATE POLICY "Allow insert orders" ON orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow select own orders" ON orders FOR SELECT USING (true);
CREATE POLICY "Allow select order items" ON order_items FOR SELECT USING (true);
CREATE POLICY "Allow insert order items" ON order_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow select admin_settings" ON admin_settings FOR SELECT USING (true);

-- INSERT SAMPLE DATA
INSERT INTO admin_settings (qr_esewa, qr_khalti, qr_bank)
VALUES (
    'https://via.placeholder.com/300?text=eSewa+QR',
    'https://via.placeholder.com/300?text=Khalti+QR',
    'https://via.placeholder.com/300?text=Bank+QR'
);
```

---

## Step 3️⃣: Paste into Supabase

1. Click in the SQL editor text area
2. **Paste** the code (Ctrl+V)
3. Click **RUN** button (or press Ctrl+Enter)

⏳ **Wait 5-10 seconds** for it to complete...

---

## Step 4️⃣: Verify Success ✅

If you see green checkmark ✅, the tables were created successfully!

To double-check, run this in a new query:

```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('orders', 'order_items', 'admin_settings');
```

You should see 3 rows:
- orders
- order_items
- admin_settings

---

## Step 5️⃣: Upload QR Codes (Optional)

If you have QR code images, run:

```sql
UPDATE admin_settings 
SET qr_esewa = '[YOUR_QRCODE_URL_HERE]',
    qr_khalti = '[YOUR_QRCODE_URL_HERE]',
    qr_bank = '[YOUR_QRCODE_URL_HERE]'
WHERE id = 1;
```

Replace `[YOUR_QRCODE_URL_HERE]` with your actual QR code URLs.

---

## ✅ Done! Now Test

1. Go back to the **payment page** (index.html → Add to cart → Go to payment)
2. Fill in the form
3. Click **Place Order & Pay Now**
4. Check the **browser console** (F12) - you should see:
   - ✅ Order inserted successfully
   - ✅ Items inserted successfully

---

## 🔍 View Your Orders

To see placed orders, run in Supabase SQL Editor:

```sql
SELECT * FROM orders ORDER BY created_at DESC;
```

To see order items:

```sql
SELECT * FROM order_items;
```

---

## ⚠️ Common Issues & Fixes

### "Syntax Error" - Copy entire SQL again, ensure no line breaks in middle

### "Permission denied" - Your Supabase user needs admin access

### "Table already exists" - Normal! The DROP TABLE statement removes old ones first

### Orders still not inserting - Check:
1. Browser console (F12) for JavaScript errors
2. Supabase project URL and API key in payment.html are correct
3. RLS policies are set to allow public INSERT

---

## 📞 Need More Help?

Check files in your project:
- `PAYMENT_SUPABASE_SETUP.sql` - Full SQL script
- `SUPABASE_PAYMENT_SETUP_GUIDE.md` - Detailed guide
- `payment.html` - Payment page code

Good luck! 🚀
