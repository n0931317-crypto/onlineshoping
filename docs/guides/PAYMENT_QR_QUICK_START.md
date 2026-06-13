# ⚡ Quick Payment QR Setup - 5 Minutes

## Step 1: Create Tables (SQL) ⏱️ 1 min

**Supabase → SQL Editor → New Query:**

```sql
-- Admin Settings Table
CREATE TABLE IF NOT EXISTS public.admin_settings (
    id BIGSERIAL PRIMARY KEY,
    setting_key VARCHAR(255) UNIQUE NOT NULL,
    setting_value JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admin_settings_key ON public.admin_settings(setting_key);
ALTER TABLE public.admin_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_select" ON public.admin_settings FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "admin_insert" ON public.admin_settings FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "admin_update" ON public.admin_settings FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "admin_delete" ON public.admin_settings FOR DELETE USING (auth.role() = 'authenticated');

INSERT INTO public.admin_settings (setting_key, setting_value) VALUES
('business_hours', '{"opening":"09:00","closing":"19:00"}'),
('contact_info', '{"phone":"033590207","email":"contact@example.com","address":"Khaireni, Gulmi, Nepal"}'),
('admin_settings', '{"businessName":"Nepo Online stores & Cosmetic Center","instagramUrl":"","facebookUrl":""}')
ON CONFLICT (setting_key) DO NOTHING;

-- Payment QR Images Table
CREATE TABLE IF NOT EXISTS public.payment_qr_images (
    id BIGSERIAL PRIMARY KEY,
    payment_method VARCHAR(50) NOT NULL,
    file_path TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(payment_method)
);

CREATE INDEX IF NOT EXISTS idx_payment_qr_method ON public.payment_qr_images(payment_method);
ALTER TABLE public.payment_qr_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "qr_public_view" ON public.payment_qr_images FOR SELECT USING (is_active = true);
CREATE POLICY "qr_auth_insert" ON public.payment_qr_images FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "qr_auth_update" ON public.payment_qr_images FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "qr_auth_delete" ON public.payment_qr_images FOR DELETE USING (auth.role() = 'authenticated');

INSERT INTO public.payment_qr_images (payment_method, file_path, is_active) VALUES
('esewa', '', false),
('khalti', '', false),
('bank', '', false)
ON CONFLICT (payment_method) DO NOTHING;
```

**Click Run** ✅

---

## Step 2: Create Storage Bucket ⏱️ 1 min

**Supabase → Storage → Create Bucket:**
- Name: `payment-qr-images`
- Public: **YES**
- Click Create ✅

---

## Step 3: Upload QR Codes ⏱️ 2 min

**Admin Panel → Settings → Payment QR Codes:**

1. **eSewa:** Drag/drop QR → Click "Save eSewa QR"
2. **Khalti:** Drag/drop QR → Click "Save Khalti QR"
3. **Bank:** Drag/drop QR → Click "Save Bank QR"

Wait for green ✅ success messages.

---

## Step 4: Verify ⏱️ 1 min

1. **Admin Settings:** Save any setting → Should see ✅ message
2. **Payment Page:** Visit payment.html → Should see all QR codes

---

## 📋 What Files Were Updated

| File | Changes |
|------|---------|
| `admin.html` | Added Payment QR Upload section |
| `admin.js` | Added QR upload/delete functions |
| `admin.css` | Added Payment QR styling |
| `payment.html` | Added Payment QR display |

---

## 🎯 Success Indicators

✅ Admin settings save shows "✅ [Setting] saved successfully!"  
✅ Payment QRs upload shows "✅ [Method] QR saved and verified!"  
✅ Payment page displays all QR codes  
✅ Console (F12) shows green checkmarks  

---

## ❌ If Something Goes Wrong

| Error | Fix |
|-------|-----|
| "Could not find table" | Run Step 1 SQL again |
| "Storage bucket not found" | Create bucket in Step 2 |
| Settings won't save | Check RLS policies on admin_settings table |
| QRs won't upload | Make sure bucket is public |
| QRs not showing on payment.html | Check payment_qr_images table has data |

---

## 💾 Files Created

- `SETUP_ADMIN_SETTINGS_TABLE.sql` - Create admin_settings table
- `SETUP_PAYMENT_QR_BUCKET.sql` - Create payment_qr_images table
- `PAYMENT_QR_COMPLETE_SETUP.md` - Detailed setup guide
- This file - Quick reference

---

**That's it! Your payment system is ready.** 🚀
