# 🎨 Visual Step-by-Step Setup Guide

## 📸 Screenshots & Visual Flow

### Step 1: Open Supabase Dashboard

```
🌐 Browser URL:
┌─────────────────────────────────────────────────────┐
│ https://app.supabase.com                            │
└─────────────────────────────────────────────────────┘

📋 What you should see:
┌─────────────────────────────┐
│   SUPABASE DASHBOARD        │
│   ───────────────────────── │
│   Your Project Name         │
│   ✓ Connected               │
│                             │
│   [SQL Editor] [Tables]     │
│   [Storage]   [Auth]        │
└─────────────────────────────┘
```

---

### Step 2: Click SQL Editor

```
LEFT SIDEBAR:
┌──────────────────────┐
│ 📊 Dashboard         │
│ 🗂️  Tables            │
│ 💻 SQL Editor    ← HERE
│ 📁 Storage           │
│ 🔐 Authentication    │
│ ⚙️  Settings          │
└──────────────────────┘
```

---

### Step 3: Click New Query

```
┌─────────────────────────────────────────┐
│ SQL Editor                              │
│ [New Query] [Run] [Format]             │
│                                        │
│ ┌──────────────────────────────────┐  │
│ │  (Empty editor)                  │  │
│ └──────────────────────────────────┘  │
└─────────────────────────────────────────┘

Click **[New Query]** button
```

---

### Step 4: Paste SQL Code

```
AFTER CLICKING NEW QUERY:
┌─────────────────────────────────────────┐
│ SQL Editor                              │
│ [New Query] [Run] [Format]             │
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ DROP TABLE IF EXISTS order_items │  │
│ │ DROP TABLE IF EXISTS orders...   │  │
│ │ CREATE TABLE orders (            │  │
│ │   id BIGSERIAL PRIMARY KEY,      │  │
│ │   ...all the SQL code...         │  │
│ └──────────────────────────────────┘  │
└─────────────────────────────────────────┘

← Paste code (Ctrl+V)
```

---

### Step 5: Click RUN

```
┌─────────────────────────────────────────┐
│ SQL Editor                              │
│ [New Query] [Run ← CLICK] [Format]     │
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ (Your SQL code)                  │  │
│ └──────────────────────────────────┘  │
└─────────────────────────────────────────┘

Wait 5-10 seconds...
```

---

### Step 6: See Success ✅

```
AFTER RUNNING:
┌─────────────────────────────────────────┐
│ SQL Editor                              │
│                                        │
│ ✅ Success! Queries executed successfully
│                                        │
│ Execution time: 2.34s                 │
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ DROP TABLE IF EXISTS order_items │  │
│ │ (Your SQL code)                  │  │
│ └──────────────────────────────────┘  │
└─────────────────────────────────────────┘

🎉 GREEN CHECKMARK = SUCCESS!
```

---

### Step 7: Verify Tables in Sidebar

```
LEFT SIDEBAR NOW SHOWS:
┌──────────────────────────┐
│ 🗂️  Tables                │
│   ├─ orders          ✅  │
│   ├─ order_items     ✅  │
│   ├─ admin_settings  ✅  │
│   └─ (other tables)      │
└──────────────────────────┘

All 3 tables created! ✅
```

---

### Step 8: Test Payment Page

```
PAYMENT PAGE WORKFLOW:

1️⃣ Add Product → Payment Page
   ┌─────────────────┐
   │ Quantity: 1     │
   │ Price: ₹1500.00 │
   │ [Add to Cart]   │
   └─────────────────┘

2️⃣ Fill Delivery Form
   ┌─────────────────────────┐
   │ Name: John Doe          │
   │ Email: john@example.com │
   │ Phone: 9841234567       │
   │ Address: Kathmandu      │
   │ City: Nepal             │
   │ Zip: 44600              │
   │ Delivery: 2026-01-15    │
   │ Notes: (optional)       │
   └─────────────────────────┘

3️⃣ Select Payment Method
   ◉ eSewa          ← Shows QR Code
   ○ Khalti         ← Shows QR Code
   ○ Bank Transfer  ← Shows QR Code

4️⃣ QR Code Appears ✅
   ┌──────────────────┐
   │   📱 QR CODE     │
   │   (image here)   │
   └──────────────────┘

5️⃣ Transaction Details
   ┌────────────────────────┐
   │ Transaction Code:      │
   │ [TXN-123456________]   │
   │                        │
   │ Upload Screenshot:     │
   │ [📁 Choose File]       │
   │ [✓ Preview shown]      │
   └────────────────────────┘

6️⃣ Place Order
   ┌──────────────────────┐
   │ Subtotal: ₹1500.00   │
   │ Delivery: ₹50.00     │
   │ Total: ₹1550.00      │
   │                      │
   │ [Place Order & Pay]  │ ← Click
   └──────────────────────┘

7️⃣ Success Message ✅
   ┌────────────────────┐
   │ ✅ ORDER PLACED!   │
   │ Order: ORD-1735... │
   │                    │
   │ Redirecting...     │
   └────────────────────┘
```

---

### Step 9: Check Console

```
PRESS F12 (Developer Tools)

Console tab should show:
✅ "Order inserted successfully"
✅ "Items inserted successfully"
✅ "Order process completed successfully"

(All green = working!)
```

---

### Step 10: Verify in Supabase

```
GO BACK TO SUPABASE:

Click "orders" table:
┌──────────────────────────────┐
│ orders                       │
├──────┬──────┬────────┬──────┤
│ ID   │ Order│Customer│Amount│
├──────┼──────┼────────┼──────┤
│ 1    │ORD-17│ John   │1550  │
└──────┴──────┴────────┴──────┘

✅ Order saved!

Click "order_items" table:
┌──────────────────────────┐
│ order_items              │
├──┬───┬────────┬───┬─────┤
│ID│OID│Product │Qty│Price│
├──┼───┼────────┼───┼─────┤
│1 │ 1 │ Shirt  │ 1 │1500 │
└──┴───┴────────┴───┴─────┘

✅ Items saved!
```

---

## ✅ Success Checklist

- [ ] Green checkmark after SQL Run
- [ ] 3 tables visible in sidebar
- [ ] QR code shows on payment page
- [ ] Order appears in orders table
- [ ] Items appear in order_items table
- [ ] Console shows success messages

---

## 🐛 Troubleshooting Visuals

### Issue: Red Error
```
❌ ERROR: Syntax error at position 45

FIX: Copy entire SQL again, paste fresh
```

### Issue: QR Not Showing
```
📱 "QR Code Not Available"

This is OK during testing.
Add QR URLs to admin_settings later.
```

### Issue: Order Not in Table
```
❌ Placed order but nothing in table

FIX: Click [Refresh] on table
     Wait 5 seconds
     Check console for errors
```

---

**Time: 5-10 minutes**  
**Difficulty: Copy & Paste**  
**Result: Working Payment System** 🚀
