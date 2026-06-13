## 🔧 QR Upload Error Fix - Step by Step

I've found and fixed several issues in the code. Here's what to do:

### STEP 1: Fix the Database Table (Critical)

Your payment_qr_images table might not exist or doesn't have the right structure.

**Go to Supabase → SQL Editor and run the SQL script:**
- Copy the entire content from `FIX_QR_TABLE_SCHEMA.sql`
- Paste it into Supabase SQL Editor
- Click "Run" button
- Wait for it to complete

This will:
✅ Create the table if it doesn't exist
✅ Add proper columns (id, payment_method, file_path, is_active, timestamps)
✅ Enable Row Level Security
✅ Create permissive RLS policies (anyone can read, insert, update, delete)

### STEP 2: Verify the Table

After running the SQL, verify it worked:

1. In Supabase, go to **Tables**
2. Look for `payment_qr_images` table
3. Click it and check the columns:
   - `id` - bigint (primary key)
   - `payment_method` - varchar (UNIQUE)
   - `file_path` - text (can store base64)
   - `is_active` - boolean
   - `created_at` - timestamp
   - `updated_at` - timestamp

### STEP 3: Test the Upload

1. Open Admin Panel in your browser
2. Click **Payment Settings** tab
3. Select a QR code image (esewa/khalti/bank)
4. Click **Upload QR Code**
5. **If it fails**, open Developer Console (F12) and look for error

### STEP 4: Debugging if Still Fails

If you still get an error after Step 1-3:

**Open browser Developer Console (F12) and:**
1. Click the **Console** tab
2. Try uploading QR again
3. Look for red error messages
4. Copy the exact error and share with me

The error will tell me what's wrong. Possible errors:
- `relation "payment_qr_images" does not exist` → Table creation failed
- `permission denied` → RLS policies didn't apply
- `invalid input syntax` → Column type mismatch
- Other → Something different

### Code Changes Made

I improved the savePaymentQR function in admin.js to:
✅ Better error logging (console shows exactly what's failing)
✅ Check if record exists before insert/update
✅ Validate return data
✅ Use `.single()` for single-row queries
✅ Add detailed console messages for debugging

### Summary

**If it works after Step 1:**
- ✅ Upload QR codes from Admin Panel
- ✅ QR displays on Payment page
- ✅ Customers see the QR when they reach payment
- ✅ Problem solved!

**If it still fails after Step 1:**
- Go to Step 4
- Get the exact error message
- Share with me and I'll fix the specific issue
