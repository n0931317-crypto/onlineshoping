# 📊 Settings & Payment QR System - Visual Guide

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          NEPO ONLINE STORES                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────────┐                    ┌──────────────────┐           │
│  │   Admin Panel    │                    │  Payment Page    │           │
│  │  (Protected)     │                    │   (Public)       │           │
│  │                  │                    │                  │           │
│  │ - Settings       │                    │ - Show QR codes  │           │
│  │ - Save Hours     │◄───────────────────│ - Instructions   │           │
│  │ - Save Contact   │   admin_settings   │ - Contact Info   │           │
│  │ - Save Social    │    (RLS: Auth)     │                  │           │
│  │ - Upload QRs     │                    │                  │           │
│  └──────────────────┘                    └──────────────────┘           │
│           │                                       ▲                      │
│           │                                       │                      │
│           ▼                                       │                      │
│  ┌──────────────────┐         ┌──────────────────┴────────────┐        │
│  │   Supabase DB    │         │   Supabase Storage            │        │
│  │                  │         │                               │        │
│  │ admin_settings   │────────▶│ payment-qr-images (Public)    │        │
│  │ (RLS: Auth only) │         │                               │        │
│  │                  │         │ - esewa-qr.jpg               │        │
│  │ payment_qr_      │         │ - khalti-qr.jpg              │        │
│  │ images           │         │ - bank-qr.jpg                │        │
│  │ (RLS: Public     │         │                               │        │
│  │  view + Auth     │         │ URLs:                         │        │
│  │  upload)         │         │ https://...public/...qr.jpg   │        │
│  │                  │         │                               │        │
│  └──────────────────┘         └───────────────────────────────┘        │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow: Saving Settings

```
┌─────────────────┐
│  Admin Panel    │
│  Settings Form  │
└────────┬────────┘
         │
         │ User clicks "Save"
         ▼
┌─────────────────────────────┐
│  saveContactInfo(e)         │
│                             │
│ 1. Get form values          │
│ 2. Validate inputs          │
│ 3. Call saveSetting()       │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│  saveSetting(key, value)    │
│                             │
│ 1. Validate data            │
│ 2. Try UPDATE existing      │
│ 3. If not found, INSERT     │
│ 4. FETCH back to verify     │
│ 5. Compare data integrity   │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│  Supabase Database          │
│                             │
│  admin_settings table:      │
│  ┌─────────────────────┐   │
│  │ setting_key: phone  │   │
│  │ setting_value: {...}│   │
│  │ updated_at: now     │   │
│  └─────────────────────┘   │
└────────┬────────────────────┘
         │
         │ Fetch back to verify
         ▼
┌─────────────────────────────┐
│  Verify in admin.js         │
│                             │
│ - Data matches input? YES   │
│ - Show ✅ success message   │
│ - Log to console            │
│ - Update UI                 │
└─────────────────────────────┘
```

---

## Data Flow: Uploading QR Code

```
┌──────────────────────┐
│  Admin Panel         │
│  Drag/Drop QR Image  │
└─────────┬────────────┘
          │
          ▼
┌──────────────────────────────┐
│  handleQRDrop() or           │
│  handleQRSelect()            │
│                              │
│ 1. Get file from input       │
│ 2. Validate file is image    │
│ 3. Show preview              │
└──────────┬───────────────────┘
           │
           │ User clicks "Save [Method] QR"
           ▼
┌──────────────────────────────┐
│  savePaymentQR(method)       │
│                              │
│ 1. Get file from qrFileStore │
│ 2. Create unique filename    │
│ 3. Upload to storage bucket  │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────────┐
│  Supabase Storage                │
│                                  │
│  Bucket: payment-qr-images       │
│  ┌────────────────────────────┐ │
│  │ esewa-qr-1735000000.jpg    │ │
│  │ [uploaded file data]       │ │
│  └────────────────────────────┘ │
│  Public URL:                     │
│  https://...storage/public/...   │
└──────────┬───────────────────────┘
           │
           │ Get public URL
           ▼
┌──────────────────────────────┐
│  Save Metadata               │
│  to payment_qr_images table  │
│                              │
│  ┌─────────────────────────┐│
│  │ payment_method: esewa   ││
│  │ file_path: https://...  ││
│  │ is_active: true         ││
│  │ updated_at: now         ││
│  └─────────────────────────┘│
└──────────┬───────────────────┘
           │
           │ Fetch back to verify
           ▼
┌──────────────────────────────┐
│  Verify Upload Success       │
│                              │
│ - File in storage? ✅       │
│ - Data in table? ✅         │
│ - Show ✅ success message    │
│ - Update UI with image       │
│ - Clear file store           │
└──────────────────────────────┘
```

---

## Data Flow: Displaying QRs on Payment Page

```
┌──────────────────────┐
│  payment.html Loads  │
└─────────┬────────────┘
          │
          │ DOMContentLoaded
          ▼
┌──────────────────────────────┐
│  loadPaymentQRs()            │
│                              │
│ 1. Query Supabase            │
│    payment_qr_images table   │
│ 2. Filter: is_active = true  │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────────┐
│  Supabase Database               │
│                                  │
│  SELECT * FROM payment_qr_images │
│  WHERE is_active = true          │
│                                  │
│  Results:                        │
│  ┌─────────────────────────────┐│
│  │ esewa: https://...esewa.jpg ││
│  │ khalti: https://...khalti.jpg││
│  │ bank: https://...bank.jpg   ││
│  └─────────────────────────────┘│
└──────────┬───────────────────────┘
           │
           │ For each QR
           ▼
┌──────────────────────────────┐
│  Update HTML                 │
│                              │
│  ┌─────────────────────────┐ │
│  │ <img src="https://..."/> │ │
│  │ in esewa-qr div          │ │
│  └─────────────────────────┘ │
│                              │
│  ┌─────────────────────────┐ │
│  │ <img src="https://..."/> │ │
│  │ in khalti-qr div         │ │
│  └─────────────────────────┘ │
│                              │
│  ┌─────────────────────────┐ │
│  │ <img src="https://..."/> │ │
│  │ in bank-qr div           │ │
│  └─────────────────────────┘ │
└──────────┬───────────────────┘
           │
           ▼
┌──────────────────────────────┐
│  Payment Page Displayed      │
│                              │
│  [eSewa QR] [Khalti QR]      │
│      [Bank QR]               │
│                              │
│  With instructions under     │
│  each QR code                │
└──────────────────────────────┘
```

---

## Database Schema

```
┌─────────────────────────────────────────┐
│        admin_settings Table             │
├─────────────────────────────────────────┤
│ id          │ BIGSERIAL PK             │
│ setting_key │ VARCHAR(255) UNIQUE      │
│             │ business_hours           │
│             │ contact_info             │
│             │ admin_settings           │
│             │ payment_methods          │
│ setting_     │ JSONB                    │
│ value       │ {JSON data}              │
│ created_at  │ TIMESTAMP                │
│ updated_at  │ TIMESTAMP                │
└─────────────────────────────────────────┘

Example Row:
┌─────────────────────────────────────────┐
│ id: 1                                   │
│ setting_key: "contact_info"             │
│ setting_value:                          │
│ {                                       │
│   "phone": "033590207",                 │
│   "email": "shop@example.com",          │
│   "address": "Khaireni, Gulmi"          │
│ }                                       │
│ created_at: 2025-01-05 10:00:00         │
│ updated_at: 2025-01-05 10:30:00         │
└─────────────────────────────────────────┘


┌──────────────────────────────────────┐
│   payment_qr_images Table            │
├──────────────────────────────────────┤
│ id              │ BIGSERIAL PK       │
│ payment_method  │ VARCHAR(50)        │
│                 │ UNIQUE             │
│                 │ (esewa, khalti,    │
│                 │  bank)             │
│ file_path       │ TEXT               │
│                 │ (public URL)       │
│ bucket_name     │ TEXT               │
│ description     │ TEXT               │
│ is_active       │ BOOLEAN            │
│ created_at      │ TIMESTAMP          │
│ updated_at      │ TIMESTAMP          │
│ created_by      │ UUID → auth.users  │
└──────────────────────────────────────┘

Example Row:
┌──────────────────────────────────────┐
│ id: 1                                │
│ payment_method: "esewa"              │
│ file_path:                           │
│ https://...storage/.../esewa.jpg     │
│ bucket_name: "payment-qr-images"     │
│ description: "eSewa payment QR"      │
│ is_active: true                      │
│ created_at: 2025-01-05 10:00:00      │
│ updated_at: 2025-01-05 10:30:00      │
│ created_by: 123e4567-e89b...         │
└──────────────────────────────────────┘
```

---

## RLS Policies Diagram

```
┌─────────────────────────────────────────────────────────┐
│           admin_settings Table RLS                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  SELECT  ✅  auth.role() = 'authenticated'             │
│  INSERT  ✅  auth.role() = 'authenticated'             │
│  UPDATE  ✅  auth.role() = 'authenticated'             │
│  DELETE  ✅  auth.role() = 'authenticated'             │
│                                                         │
│  Anonymous User → ❌ BLOCKED                           │
│  Authenticated → ✅ ALLOWED                            │
│                                                         │
└─────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│        payment_qr_images Table RLS                       │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  SELECT  ✅  is_active = true                           │
│             (PUBLIC - anyone can view)                  │
│                                                          │
│  INSERT  ✅  auth.role() = 'authenticated'              │
│             (Authenticated admin only)                  │
│                                                          │
│  UPDATE  ✅  auth.role() = 'authenticated'              │
│             (Authenticated admin only)                  │
│                                                          │
│  DELETE  ✅  auth.role() = 'authenticated'              │
│             (Authenticated admin only)                  │
│                                                          │
│  Anonymous → ✅ Can VIEW active QRs                     │
│  Anonymous → ❌ Cannot INSERT/UPDATE/DELETE             │
│  Authenticated → ✅ Full access                         │
│                                                          │
└──────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│      payment-qr-images Storage Bucket                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Public Bucket: ✅ YES                                 │
│                                                         │
│  Anyone → ✅ Can READ/DOWNLOAD files                   │
│  Admin → ✅ Can UPLOAD/DELETE files                    │
│                                                         │
│  Files:                                                 │
│  ├─ esewa-qr-1735000000.jpg (public URL)              │
│  ├─ khalti-qr-1735000001.jpg (public URL)             │
│  └─ bank-qr-1735000002.jpg (public URL)               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## User Flows

### Admin: Save Settings

```
Admin Panel
    │
    ▼
Settings Page
    │
    ├─► Business Hours
    │       │ Change time
    │       │ Click "Save Hours"
    │       ▼
    │   ✅ "Business hours saved successfully!"
    │
    ├─► Contact Information
    │       │ Change phone/email/address
    │       │ Click "Update Contact"
    │       ▼
    │   ✅ "Contact information saved successfully!"
    │
    ├─► Admin Settings
    │       │ Change business name / social URLs
    │       │ Click "Save Settings"
    │       ▼
    │   ✅ "Settings saved successfully!"
    │
    └─► Payment QR Codes
            │
            ├─ eSewa
            │   │ Drag/Drop QR image
            │   │ See preview
            │   │ Click "Save eSewa QR"
            │   ▼
            │   ✅ "eSewa QR code saved and verified!"
            │
            ├─ Khalti
            │   │ Drag/Drop QR image
            │   │ See preview
            │   │ Click "Save Khalti QR"
            │   ▼
            │   ✅ "Khalti QR code saved and verified!"
            │
            └─ Bank
                │ Drag/Drop QR image
                │ See preview
                │ Click "Save Bank QR"
                ▼
                ✅ "Bank QR code saved and verified!"
```

### Customer: View Payment QRs

```
Customer
    │
    ▼
Payment Page
    │
    ├─► eSewa Section
    │   │ See QR code
    │   │ Read instructions
    │   │ Scan with app
    │   ▼
    │   Payment Complete ✅
    │
    ├─► Khalti Section
    │   │ See QR code
    │   │ Read instructions
    │   │ Scan with app
    │   ▼
    │   Payment Complete ✅
    │
    └─► Bank Transfer Section
        │ See QR code
        │ Read bank details
        │ Transfer money
        ▼
        Payment Complete ✅
```

---

## Component Structure

```
├─ Admin Panel (admin.html / admin.js)
│  │
│  └─ Settings Section
│     │
│     ├─ Business Hours Card
│     │  ├─ Input: Opening Time
│     │  ├─ Input: Closing Time
│     │  └─ Button: Save Hours
│     │
│     ├─ Contact Information Card
│     │  ├─ Input: Phone
│     │  ├─ Input: Email
│     │  ├─ Textarea: Address
│     │  └─ Button: Update Contact
│     │
│     ├─ Admin Settings Card
│     │  ├─ Input: Business Name
│     │  ├─ Input: Instagram URL
│     │  ├─ Input: Facebook URL
│     │  └─ Button: Save Settings
│     │
│     └─ Payment QR Codes Card
│        │
│        ├─ eSewa Payment Card
│        │  ├─ Drop Zone
│        │  ├─ Image Preview
│        │  ├─ Upload Button
│        │  ├─ Save Button
│        │  └─ Delete Button
│        │
│        ├─ Khalti Payment Card
│        │  ├─ Drop Zone
│        │  ├─ Image Preview
│        │  ├─ Upload Button
│        │  ├─ Save Button
│        │  └─ Delete Button
│        │
│        └─ Bank Payment Card
│           ├─ Drop Zone
│           ├─ Image Preview
│           ├─ Upload Button
│           ├─ Save Button
│           └─ Delete Button
│
└─ Payment Page (payment.html)
   │
   ├─ Header
   │
   ├─ Payment Methods Grid
   │  │
   │  ├─ eSewa Payment
   │  │  ├─ Icon
   │  │  ├─ QR Code Image
   │  │  └─ Instructions
   │  │
   │  ├─ Khalti Payment
   │  │  ├─ Icon
   │  │  ├─ QR Code Image
   │  │  └─ Instructions
   │  │
   │  └─ Bank Transfer
   │     ├─ Icon
   │     ├─ QR Code Image
   │     ├─ Bank Details
   │     └─ Instructions
   │
   ├─ Security Notice
   │
   └─ Footer (with Contact Info)
```

---

**All diagrams and flows are now documented for reference!** 📊
