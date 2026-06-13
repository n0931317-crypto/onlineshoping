# Complete Payment QR & Admin Settings Setup Guide

## 📋 Overview

This guide covers:
1. Creating the `admin_settings` table for storing business settings
2. Creating the `payment_qr_images` bucket and table for payment QRs
3. Uploading payment QR codes through the admin panel
4. Displaying payment QRs on the payment page

---

## 🔧 Step 1: Create Admin Settings Table

The admin settings table stores contact information, business hours, and other admin settings.

### Execute SQL in Supabase SQL Editor:

**Go to:** Supabase Dashboard → SQL Editor → New Query

**Copy and paste:**
```sql
-- ============================================================
-- CREATE ADMIN_SETTINGS TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.admin_settings (
    id BIGSERIAL PRIMARY KEY,
    setting_key VARCHAR(255) UNIQUE NOT NULL,
    setting_value JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_admin_settings_key ON public.admin_settings(setting_key);

-- Enable RLS
ALTER TABLE public.admin_settings ENABLE ROW LEVEL SECURITY;

-- Create RLS policies - Allow authenticated admin users only
CREATE POLICY "Only authenticated users can view admin settings" 
    ON public.admin_settings 
    FOR SELECT 
    USING (auth.role() = 'authenticated');

CREATE POLICY "Only authenticated users can insert admin settings" 
    ON public.admin_settings 
    FOR INSERT 
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Only authenticated users can update admin settings" 
    ON public.admin_settings 
    FOR UPDATE 
    USING (auth.role() = 'authenticated') 
    WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Only authenticated users can delete admin settings" 
    ON public.admin_settings 
    FOR DELETE 
    USING (auth.role() = 'authenticated');

-- INSERT INITIAL SETTINGS
INSERT INTO public.admin_settings (setting_key, setting_value) VALUES
('business_hours', '{"opening":"09:00","closing":"19:00"}'),
('contact_info', '{"phone":"033590207","email":"contact@example.com","address":"Khaireni, Gulmi, Nepal"}'),
('admin_settings', '{"businessName":"Nepo Online stores & Cosmetic Center","instagramUrl":"","facebookUrl":""}'),
('payment_methods', '{"esewa":true,"khalti":true,"bank":true}')
ON CONFLICT (setting_key) DO NOTHING;
```

**Click "Run"** to execute.

✅ **Expected Result:** 
```
Query executed successfully (7 rows affected)
```

---

## 🪣 Step 2: Create Payment QR Storage Bucket

The payment bucket stores the actual QR code images.

### In Supabase Dashboard:

1. **Go to:** Storage → Buckets
2. **Click:** "Create a new bucket"
3. **Set:**
   - Name: `payment-qr-images`
   - Public/Private: **Public** (so customers can see QRs)
4. **Click:** "Create bucket"

---

## 💾 Step 3: Create Payment QR Metadata Table

This table tracks which QR codes are uploaded for each payment method.

### Execute SQL in Supabase SQL Editor:

```sql
-- ============================================================
-- CREATE PAYMENT_QR_IMAGES TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS public.payment_qr_images (
    id BIGSERIAL PRIMARY KEY,
    payment_method VARCHAR(50) NOT NULL, -- 'esewa', 'khalti', 'bank'
    file_path TEXT NOT NULL,
    bucket_name TEXT DEFAULT 'payment-qr-images',
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    UNIQUE(payment_method)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_payment_qr_method ON public.payment_qr_images(payment_method);
CREATE INDEX IF NOT EXISTS idx_payment_qr_active ON public.payment_qr_images(is_active);

-- Enable RLS
ALTER TABLE public.payment_qr_images ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Public can view active payment QR images
CREATE POLICY "Anyone can view active payment QR images" 
    ON public.payment_qr_images 
    FOR SELECT 
    USING (is_active = true);

-- Only authenticated users can insert
CREATE POLICY "Only authenticated users can insert payment QR images" 
    ON public.payment_qr_images 
    FOR INSERT 
    WITH CHECK (auth.role() = 'authenticated');

-- Only authenticated users can update
CREATE POLICY "Only authenticated users can update payment QR images" 
    ON public.payment_qr_images 
    FOR UPDATE 
    USING (auth.role() = 'authenticated') 
    WITH CHECK (auth.role() = 'authenticated');

-- Only authenticated users can delete
CREATE POLICY "Only authenticated users can delete payment QR images" 
    ON public.payment_qr_images 
    FOR DELETE 
    USING (auth.role() = 'authenticated');

-- INSERT PLACEHOLDER RECORDS
INSERT INTO public.payment_qr_images (payment_method, file_path, description, is_active) VALUES
('esewa', '', 'eSewa payment QR code', false),
('khalti', '', 'Khalti payment QR code', false),
('bank', '', 'Bank transfer details QR code', false)
ON CONFLICT (payment_method) DO NOTHING;
```

**Click "Run"** to execute.

✅ **Expected Result:**
```
Query executed successfully (3 rows affected)
```

---

## 🎯 Step 4: Upload Payment QR Codes in Admin Panel

Now you can upload the actual QR code images.

### In Admin Panel:

1. **Login** to admin panel (http://yoursite.com/admin.html)
2. **Click** "Settings" in the sidebar
3. **Scroll to** "Payment QR Codes" section
4. **For each payment method (eSewa, Khalti, Bank):**
   - Drag & drop QR image OR click "Upload [Method] QR"
   - You'll see a preview
   - Click "Save [Method] QR" button
   - Wait for "✅ [Method] QR code saved and verified successfully!" message

### Expected Console Output (F12):
```
📸 QR preview loaded for esewa
📝 Saving eSewa QR code...
📤 Uploading esewa-qr-1735000000000.jpg to payment-qr-images bucket
🔗 Public URL: https://ygmoggtfyrnpkwtasut.supabase.co/storage/v1/object/public/payment-qr-images/esewa-qr-1735000000000.jpg
✅ eSewa QR verified in database
```

---

## ✅ Step 5: Verify Everything Works

### Check Admin Panel Settings:

1. Save any admin setting (Business Hours, Contact Info, etc.)
2. You should see: **"✅ [Setting] saved successfully! Your changes are now stored."**
3. If error, console (F12) shows exact error code

### Check Payment Page:

1. Visit **http://yoursite.com/payment.html**
2. You should see your QR codes displayed for each payment method
3. If QR not showing, check console (F12) for errors

---

## 🔒 Security Policies Explained

### `admin_settings` Table:
- ✅ Authenticated users can read/write/update/delete
- ❌ Anonymous users cannot access
- **Use Case:** Admin panel settings only

### `payment_qr_images` Table:
- ✅ **Anyone** can view active QR codes (needed for payment page)
- ✅ Authenticated users can upload/update/delete
- ❌ Anonymous users cannot upload
- **Use Case:** Public QR display + Admin uploads

### `payment-qr-images` Storage Bucket:
- ✅ **Public** bucket (customers can see QRs)
- ✅ Admin can upload files
- **Use Case:** Store actual QR images

---

## 📱 API Functions in admin.js

### `savePaymentQR(method)`
- Uploads QR image to storage bucket
- Saves metadata to database
- Verifies upload success
- Shows success/error message to user

```javascript
await savePaymentQR('esewa');  // Upload eSewa QR
await savePaymentQR('khalti'); // Upload Khalti QR
await savePaymentQR('bank');   // Upload Bank QR
```

### `deletePaymentQR(method)`
- Deletes QR from storage bucket
- Deletes metadata from database
- Clears preview from UI

```javascript
await deletePaymentQR('esewa');  // Delete eSewa QR
```

### `loadPaymentQRs()`
- Called on admin panel startup
- Fetches all active QR codes from database
- Displays in admin settings page
- Runs automatically

### `handleQRDrop(event, method)` / `handleQRSelect(event, method)`
- Drag & drop file support
- Preview before saving
- Stores file temporarily in `qrFileStore` object

---

## 🚨 Common Errors & Fixes

### Error: "Could not find the table 'public.admin_settings'"
**Fix:** Run Step 1 SQL to create the table

### Error: "Could not find the table 'public.payment_qr_images'"
**Fix:** Run Step 3 SQL to create the table

### Error: "Storage bucket 'payment-qr-images' not found"
**Fix:** Create the bucket in Supabase Storage (Step 2)

### Error: "Failed to save setting - no data returned"
**Fix:** Check RLS policies on admin_settings table

### Error: "Upload failed: ERR_STORAGE_UNKNOWN"
**Fix:** 
- Make sure bucket is created and public
- Check bucket name matches exactly: `payment-qr-images`
- Ensure you're authenticated (logged in to admin)

### QR codes not showing on payment page
**Fixes:**
1. Check payment.html is using correct Supabase credentials
2. Verify `payment_qr_images` table has records with `is_active = true`
3. Check browser console (F12) for network errors
4. Make sure bucket is public

---

## 📊 Database Schema Summary

```sql
-- admin_settings table
┌────────────────────────────────────────────┐
│ admin_settings                             │
├────────────────────────────────────────────┤
│ id              BIGSERIAL PRIMARY KEY      │
│ setting_key     VARCHAR(255) UNIQUE       │
│ setting_value   JSONB                      │
│ created_at      TIMESTAMP                  │
│ updated_at      TIMESTAMP                  │
└────────────────────────────────────────────┘

-- payment_qr_images table
┌────────────────────────────────────────────┐
│ payment_qr_images                          │
├────────────────────────────────────────────┤
│ id              BIGSERIAL PRIMARY KEY      │
│ payment_method  VARCHAR(50) UNIQUE        │
│ file_path       TEXT                       │
│ bucket_name     TEXT                       │
│ description     TEXT                       │
│ is_active       BOOLEAN                    │
│ created_at      TIMESTAMP                  │
│ updated_at      TIMESTAMP                  │
│ created_by      UUID (FK auth.users)      │
└────────────────────────────────────────────┘
```

---

## 🎬 Complete Setup Checklist

- [ ] Create `admin_settings` table (Step 1 SQL)
- [ ] Create `payment-qr-images` storage bucket (Step 2)
- [ ] Create `payment_qr_images` table (Step 3 SQL)
- [ ] Login to admin panel
- [ ] Upload eSewa QR code
- [ ] Upload Khalti QR code
- [ ] Upload Bank QR code
- [ ] Save admin settings (Business Hours, Contact Info, etc.)
- [ ] Visit payment.html to verify QRs display
- [ ] Test on different browsers/devices

---

## 📞 Testing Payment Settings

### Test Business Hours Save:
1. Go to Admin → Settings → Business Hours
2. Change opening/closing times
3. Click "Save Hours"
4. Console should show: `✅ Business hours verified in database`

### Test Contact Info Save:
1. Go to Admin → Settings → Contact Information
2. Change phone/email/address
3. Click "Update Contact"
4. Console should show: `✅ Contact info verified in database`

### Test Admin Settings Save:
1. Go to Admin → Settings → Admin Settings
2. Change business name / social URLs
3. Click "Save Settings"
4. Console should show: `✅ Admin settings verified in database`

### Test Payment QR Upload:
1. Go to Admin → Settings → Payment QR Codes
2. Upload eSewa QR code image
3. Click "Save eSewa QR"
4. Console should show: `✅ eSewa QR verified in database`
5. Visit payment.html to see QR displayed

---

## 🔗 File References

- **Admin Panel:** `/admin.html` - Settings section with payment QR upload
- **Admin Script:** `/admin.js` - Functions for QR upload/management
- **Admin Styles:** `/admin.css` - Payment QR section styling
- **Payment Page:** `/payment.html` - Display payment methods with QRs
- **SQL Setup Files:**
  - `SETUP_ADMIN_SETTINGS_TABLE.sql` - Create admin_settings table
  - `SETUP_PAYMENT_QR_BUCKET.sql` - Create payment_qr_images table

---

## 💡 Pro Tips

1. **QR Code Format:** Use PNG or JPG images (transparent backgrounds recommended)
2. **Size:** Keep images under 1MB for fast loading
3. **Testing:** Upload a test QR code first before production
4. **Backup:** Save original QR code files locally
5. **Update:** You can always replace QR codes by uploading new ones
6. **Verification:** Always check console (F12) for success/error messages

---

**Setup Complete!** Your payment system is now ready. 🎉
