# 🔧 Supabase Payment System Setup Guide

## 📋 Overview

This guide will help you set up the database tables for the payment system in Supabase.

---

## ⚡ Quick Setup (Recommended)

### Step 1: Open Supabase SQL Editor
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **SQL Editor** (left sidebar)
4. Click **New Query**

### Step 2: Copy and Run the SQL
1. Open the file: `PAYMENT_SUPABASE_SETUP.sql`
2. Copy ALL the SQL code
3. Paste it into the Supabase SQL Editor
4. Click **Run** button (or press Ctrl+Enter)

✅ All tables will be created automatically!

---

## 📊 Database Schema

### **orders** Table
Stores all customer orders

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key (auto-increment) |
| order_number | VARCHAR(50) | Unique order ID (e.g., ORD-1735989382000) |
| customer_name | VARCHAR(255) | Customer's full name |
| customer_email | VARCHAR(255) | Customer's email |
| customer_phone | VARCHAR(20) | Customer's phone number |
| delivery_address | TEXT | Full delivery address |
| delivery_date | DATE | Delivery date (YYYY-MM-DD format) |
| delivery_notes | TEXT | Special instructions |
| subtotal | DECIMAL(10,2) | Order subtotal (before delivery charge) |
| delivery_charge | DECIMAL(10,2) | Delivery fee (default: 50) |
| total_amount | DECIMAL(10,2) | Total order amount |
| status | VARCHAR(50) | Order status (pending_verification, confirmed, shipped, delivered) |
| payment_method | VARCHAR(50) | Payment method (esewa, khalti, bank) |
| transaction_code | VARCHAR(100) | Transaction ID/Reference number |
| has_screenshot | BOOLEAN | Whether payment screenshot was uploaded |
| created_at | TIMESTAMP | Order creation time |
| updated_at | TIMESTAMP | Last update time |

### **order_items** Table
Stores individual items in each order

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| order_id | BIGINT | Foreign key to orders table |
| product_id | INTEGER | Product ID (can be null) |
| product_name | VARCHAR(255) | Product name |
| quantity | INTEGER | Quantity ordered |
| price | DECIMAL(10,2) | Price per unit |
| created_at | TIMESTAMP | Creation time |

### **admin_settings** Table
Stores QR codes and payment configuration

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| qr_esewa | TEXT | eSewa QR code URL or base64 |
| qr_khalti | TEXT | Khalti QR code URL or base64 |
| qr_bank | TEXT | Bank transfer QR code URL or base64 |
| esewa_merchant_id | VARCHAR(255) | eSewa merchant ID |
| khalti_merchant_id | VARCHAR(255) | Khalti merchant ID |
| bank_account_number | VARCHAR(50) | Bank account for transfers |
| bank_name | VARCHAR(255) | Bank name |
| created_at | TIMESTAMP | Creation time |
| updated_at | TIMESTAMP | Last update time |

---

## 🔑 Key Features of This Setup

✅ **Proper Data Types**
- Decimal fields for currency (not strings)
- DATE type for dates (not full timestamps)
- BOOLEAN for yes/no fields
- VARCHAR with proper length limits

✅ **Referential Integrity**
- Foreign key relationship between orders and order_items
- CASCADE delete to clean up items when order is deleted

✅ **Automatic Timestamps**
- `created_at` and `updated_at` fields automatically set
- Helps track when orders were placed

✅ **Indexes for Performance**
- Indexes on frequently searched columns:
  - order_number (for quick lookup)
  - customer_email (for customer queries)
  - status (for admin filtering)
  - created_at (for date range queries)

✅ **Row Level Security (RLS)**
- Tables have RLS enabled
- Policies allow public insert/select (for checkout)
- Can be restricted later for admin-only access

---

## 🚀 How to Use in Admin Panel

### Upload QR Codes
```sql
UPDATE admin_settings 
SET qr_esewa = 'https://your-storage-url/qr-esewa.png',
    qr_khalti = 'https://your-storage-url/qr-khalti.png',
    qr_bank = 'https://your-storage-url/qr-bank.png'
WHERE id = 1;
```

### View All Orders
```sql
SELECT * FROM orders 
ORDER BY created_at DESC;
```

### View Orders by Status
```sql
SELECT * FROM orders 
WHERE status = 'pending_verification'
ORDER BY created_at DESC;
```

### View Order Details with Items
```sql
SELECT 
    o.order_number,
    o.customer_name,
    o.total_amount,
    o.payment_method,
    o.status,
    oi.product_name,
    oi.quantity,
    oi.price
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.order_number = 'ORD-1735989382000'
ORDER BY o.created_at DESC;
```

### Update Order Status
```sql
UPDATE orders 
SET status = 'confirmed'
WHERE order_number = 'ORD-1735989382000';
```

---

## ✅ Testing the Setup

After creating the tables, test by:

1. **Place an order** on the payment page
2. **Check the database** - you should see:
   - New row in `orders` table
   - Multiple rows in `order_items` table

3. **View the data** in Supabase:
   - Go to SQL Editor
   - Run: `SELECT * FROM orders;`
   - Run: `SELECT * FROM order_items;`

---

## 🔧 Troubleshooting

### Issue: "Syntax Error" when running SQL
**Solution**: Make sure you copied the ENTIRE file, including all comments and statements.

### Issue: "Table already exists" error
**Solution**: The DROP TABLE statements at the beginning will remove old tables. This is intentional.

### Issue: "Permission denied" error
**Solution**: Make sure you're logged in as the Supabase project owner. RLS policies are set to allow public access for now.

### Issue: Orders not appearing
**Solution**: 
1. Check browser console for JavaScript errors
2. Verify Supabase project URL and API key are correct
3. Ensure orders table has the correct schema

---

## 📝 Data Type Mapping

| JavaScript Type | Database Type | Example |
|-----------------|---------------|---------|
| `"string"` | VARCHAR | `'ORD-123456'` |
| `123` (number) | INTEGER or DECIMAL | `1500.00` |
| `true/false` | BOOLEAN | `true` |
| `"2026-01-10"` | DATE | `'2026-01-10'` |
| `null` | NULL | `null` |

---

## 🎯 Next Steps

1. ✅ Run the SQL script above
2. ✅ Verify tables exist in Supabase
3. ✅ Test placing an order
4. ✅ Check admin panel to view orders
5. ✅ Update QR codes in admin_settings
6. ✅ Configure payment methods in admin panel

---

## 💡 Important Notes

- ⚠️ **Backup First**: If you have existing data, back it up before dropping tables
- 🔒 **RLS Policies**: Currently set to public access. Restrict later for security
- 💰 **Currency**: All amounts stored as DECIMAL(10,2) - supports up to 99,999,999.99
- 📅 **Dates**: Stored as DATE type (YYYY-MM-DD), not full timestamps

---

## 📞 Need Help?

If you encounter issues:
1. Check the browser console (F12) for JavaScript errors
2. Check Supabase logs (Project → Logs)
3. Verify the SQL was run successfully
4. Ensure all table names match the payment.html code

---

**Created**: January 5, 2026  
**Version**: 1.0  
**Tested**: ✅ Payment system with eSewa, Khalti, Bank Transfer
