## Fix RLS Policy Errors for Services, Products & Product Images

### The Problem
You're getting errors when trying to upload/manage:
- Services: `Error: "new row violates row-level security policy for table 'services'"`
- Products: `Error: "new row violates row-level security policy for table 'products'"`
- Product Images: `Error: "new row violates row-level security policy for table 'product_images'"`

This happens because **Row Level Security (RLS)** is enabled on the tables but doesn't have policies allowing INSERT/UPDATE/DELETE operations.

### The Solution

#### Step 1: Copy the SQL Script
Open the file: **`FIX_RLS_POLICIES_FOR_ADMIN.sql`**

#### Step 2: Run in Supabase
1. Go to https://app.supabase.com
2. Select your project
3. Navigate to **SQL Editor** (left sidebar)
4. Click **New Query**
5. Copy ALL the contents from `FIX_RLS_POLICIES_FOR_ADMIN.sql`
6. Paste into the SQL editor
7. Click **RUN** button

#### Step 3: Verify Success
You should see output showing:
- ✅ Services Policies created
- ✅ Products Policies created  
- ✅ Gallery Policies created
- ✅ Reviews Policies created

### What Gets Fixed
The script creates RLS policies allowing:

**For Services Table:**
- ✅ INSERT - Add new services
- ✅ UPDATE - Edit existing services
- ✅ DELETE - Remove services
- ✅ SELECT - View all services

**For Products Table:**
- ✅ INSERT - Add new products
- ✅ UPDATE - Edit existing products
- ✅ DELETE - Remove products
- ✅ SELECT - View all products

**For Product Images Table:**
- ✅ INSERT - Upload product images
- ✅ UPDATE - Replace/update product images
- ✅ DELETE - Remove product images
- ✅ SELECT - View all product images

**For Gallery & Reviews:**
- ✅ Full INSERT/UPDATE/DELETE/SELECT access

### After Running the SQL

**Clear your browser cache:**
- Press `Ctrl + Shift + Delete` (or `Cmd + Shift + Delete` on Mac)
- Select "Cookies and other site data"
- Clear cache

**Then try uploading services/products again** - it should work!

### If You Still Get Errors
1. Check the browser console (F12) for the exact error
2. Verify the SQL ran successfully in Supabase
3. Ensure you're on the correct Supabase project
4. Try logging out and back in

### Troubleshooting

**Error: Policy already exists**
- The script uses `DROP POLICY IF EXISTS` to handle this
- It's safe to run multiple times

**RLS Still Blocking Access**
- Wait 30 seconds for changes to propagate
- Hard refresh the browser (Ctrl+F5)
- Check that policies show in SQL Editor when queried

**Still Can't Insert**
- Verify RLS is enabled: `SELECT tablename, rowsecurity FROM pg_tables WHERE tablename IN ('services', 'products')`
- All should show `t` (true) for rowsecurity
