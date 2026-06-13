# 🔧 COMPLETE ERROR RESOLUTION GUIDE

**Purpose:** Solve any error that appears during database setup  
**Coverage:** All possible errors + solutions

---

## 📋 ERROR REFERENCE TABLE

| Error Message | Cause | Solution |
|---------------|-------|----------|
| "Table already exists" | Tables created before | Continue to step 2 |
| "Syntax error" | SQL file corrupted | Recopy file from source |
| "Permission denied" | RLS blocking access | Run sample data again |
| "Column doesn't exist" | Wrong column name | Verify SQL file complete |
| "Bucket already exists" | Bucket created before | Use existing bucket |
| "Authentication failed" | Wrong password | Check credentials |
| 404 errors on website | Logo file missing | Hard refresh browser |
| "CORS error" | Cross-origin issue | Not a problem, ignore |
| "null is not an object" | Data not loaded | Wait 5 seconds, refresh |
| "Failed to fetch" | Network issue | Check internet, retry |

---

## 🔴 DETAILED ERROR SOLUTIONS

---

# ERROR 1: "Relation 'table_name' Already Exists"

## What This Means
```
PostgreSQL tried to create a table that already exists
This is NORMAL if you run Step 1 twice
```

## Why It Happens
```
✓ Tables were already created in a previous setup
✓ You ran COMPLETE_DATABASE_AND_STORAGE_SETUP.sql before
```

## How To Fix
```
SOLUTION 1 (Recommended):
  1. Ignore the error
  2. Continue to Step 2 (Sample Data)
  3. Everything will work fine

SOLUTION 2 (If you want fresh start):
  1. Delete the project
  2. Create new project
  3. Start from beginning
```

## What NOT To Do
```
❌ Don't delete tables manually (too much risk)
❌ Don't try to drop tables (need correct order)
❌ Don't run Step 1 multiple times
```

## Expected Output
```
✅ If you see: "Query executed successfully"
   → Continue to Step 2
   
✅ If you see: "Created X objects"
   → Continue to Step 2
   
⚠️ If you see: "Table already exists"
   → This is OK, continue anyway
```

---

# ERROR 2: "Syntax Error in SQL Statement"

## What This Means
```
The SQL code has a typo or is incomplete
PostgreSQL couldn't understand the command
```

## Why It Happens
```
✗ File didn't copy completely
✗ Text got cut off
✗ Pasting failed
✗ Wrong file pasted
```

## How To Fix

### FIX A: Recopy The File

```
STEP 1: Delete what's in SQL Editor
        Select all: Ctrl+A
        Delete: Delete key

STEP 2: Get fresh file
        Open: COMPLETE_DATABASE_AND_STORAGE_SETUP.sql
        
STEP 3: Copy carefully
        Select all: Ctrl+A
        Copy: Ctrl+C
        
STEP 4: Paste into Supabase
        Click in editor
        Paste: Ctrl+V
        
STEP 5: Check full content
        Scroll to bottom
        Verify last lines visible
        
STEP 6: Run again
        Click "Run" button
```

### FIX B: Check File Not Corrupted

```
HOW TO VERIFY:

1. Open: COMPLETE_DATABASE_AND_STORAGE_SETUP.sql

2. Look for these markers:
   ✓ Starts with: "-- ============"
   ✓ Contains: "CREATE TABLE"
   ✓ Contains: "CREATE FUNCTION"
   ✓ Contains: "CREATE TRIGGER"
   ✓ Contains: "CREATE POLICY"
   ✓ Ends with: "-- ============"

3. Check line count:
   ✓ Should be around 736 lines
   ✓ View → Word Count (or check status bar)

4. If missing lines:
   - File is corrupted
   - Get fresh file from repo
   - Try copy again
```

### FIX C: Try Different Approach

```
IF STILL NOT WORKING:

1. In Supabase, click "New Query"

2. Copy just one table definition:
   CREATE TABLE IF NOT EXISTS services (
       id BIGSERIAL PRIMARY KEY,
       title TEXT NOT NULL,
       ...
   );

3. Run it alone

4. If it works:
   ✓ Problem was file copy
   ✓ Try step 1 with full file again

5. If it fails:
   ✗ Problem is Supabase connection
   ✗ Try refreshing Supabase page
```

---

# ERROR 3: "Permission Denied" or "RLS Policy Violation"

## What This Means
```
Row Level Security (RLS) policies are blocking the query
This happens when policies don't allow the operation
```

## Why It Happens
```
✗ Sample data SQL ran before main SQL
✗ RLS policies too restrictive
✗ Wrong order of execution
```

## How To Fix

### SOLUTION 1: Run In Correct Order

```
CORRECT ORDER:
  1. Run COMPLETE_DATABASE_AND_STORAGE_SETUP.sql ✓
  2. Run SAMPLE_DATA_SETUP.sql ✓
  
WRONG ORDER:
  ✗ Running sample data before setup
  ✗ Results in permission errors
```

### SOLUTION 2: Disable RLS Temporarily

```
IF STILL GETTING ERRORS:

1. New Query in SQL Editor

2. Paste this:
   ─────────────────────────────────
   ALTER TABLE services DISABLE ROW LEVEL SECURITY;
   ALTER TABLE products DISABLE ROW LEVEL SECURITY;
   ALTER TABLE orders DISABLE ROW LEVEL SECURITY;
   ALTER TABLE reviews DISABLE ROW LEVEL SECURITY;
   ─────────────────────────────────

3. Click "Run"

4. Try inserting sample data again

5. If works:
   ✓ RLS policies were the issue
   ✓ Can re-enable later with correct policies
```

### SOLUTION 3: Re-enable RLS

```
After fixing data insertion:

1. New Query

2. Paste:
   ─────────────────────────────────
   ALTER TABLE services ENABLE ROW LEVEL SECURITY;
   ALTER TABLE products ENABLE ROW LEVEL SECURITY;
   ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
   ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
   ─────────────────────────────────

3. Click "Run"
```

---

# ERROR 4: "Column 'X' Does Not Exist"

## What This Means
```
Query is looking for a column that doesn't exist
Wrong column name used
```

## Common Causes
```
✗ Table wasn't created (Step 1 skipped)
✗ Column name typo
✗ Old schema vs new schema mismatch
```

## How To Fix

### FIX A: Verify Table Exists

```
1. SQL Editor → New Query

2. Paste:
   SELECT * FROM information_schema.columns 
   WHERE table_name = 'services';

3. Click "Run"

4. Look for columns:
   ✓ id
   ✓ title
   ✓ description
   ✓ price
   ✓ image_url
   ✓ duration_hours
   ✓ is_active

5. If any missing:
   ✗ Table wasn't created properly
   ✗ Run COMPLETE_DATABASE_AND_STORAGE_SETUP.sql again
```

### FIX B: Check Column Names

```
CORRECT COLUMN NAMES:

For services table:
  ✓ title (NOT name)
  ✓ description
  ✓ price
  ✓ is_active (NOT is_enabled)

For products table:
  ✓ name (NOT title)
  ✓ description
  ✓ category
  ✓ stock_quantity

For settings table:
  ✓ setting_key (NOT key)
  ✓ setting_value (NOT value)

For reviews table:
  ✓ status (NOT is_approved)
  ✓ rating
```

### FIX C: Run Full Setup Again

```
If nothing above works:

1. Delete all queries in SQL Editor

2. Run COMPLETE_DATABASE_AND_STORAGE_SETUP.sql fresh

3. Run SAMPLE_DATA_SETUP.sql fresh

4. Verify column names are correct in both files
```

---

# ERROR 5: "Bucket Already Exists"

## What This Means
```
You already created this storage bucket
PostgreSQL/Supabase won't create duplicates
```

## Why It Happens
```
✓ You ran bucket creation before
✓ Tried to create same bucket twice
```

## How To Fix

```
SOLUTION 1 (Recommended):
  1. Ignore the error
  2. Continue to next bucket
  3. No problem for functionality

SOLUTION 2: Delete and Recreate
  1. Go to Storage section
  2. Find existing bucket
  3. Click "..." menu
  4. Click "Delete bucket"
  5. Create fresh bucket with same name

SOLUTION 3: Use Existing Bucket
  1. Check if bucket already exists
  2. If it does, don't create again
  3. Just verify it's PUBLIC
```

## Verification

```
AFTER BUCKET CREATION:

1. Go to Storage in Supabase

2. You should see 5 buckets:
   ✓ product-images
   ✓ gallery-images
   ✓ videos
   ✓ service-images
   ✓ transaction-screenshots

3. Each should show:
   ✓ "Public" badge
   ✓ File count (0 if new)
```

---

# ERROR 6: "CORS Error" or Cross-Origin Blocked

## What This Means
```
Browser blocked request due to CORS policy
Usually not a setup error - happens later when using site
```

## Why It Happens
```
✓ Local development (file://)
✓ Testing from wrong domain
```

## How To Fix

```
SOLUTION 1: Use Local Server
  Instead of: file:///path/to/index.html
  Use: http://localhost:8000

  How:
  1. Open terminal in your project folder
  2. Run: python -m http.server 8000
  3. Go to: http://localhost:8000

SOLUTION 2: For Now, Ignore CORS
  This usually resolves itself in production
  Not a database setup issue
```

---

# ERROR 7: Website Shows "Failed to Fetch" Errors

## What This Means
```
Website can't connect to Supabase database
Network request failed
```

## Why It Happens
```
✗ Database tables don't exist yet
✗ RLS policies blocking access
✗ Wrong Supabase credentials
✗ Project isn't active
```

## How To Fix

### FIX A: Check Tables Exist

```
1. Supabase SQL Editor → New Query

2. Paste:
   SELECT COUNT(*) FROM services;

3. If error:
   ✗ Table doesn't exist
   ✗ Run COMPLETE_DATABASE_AND_STORAGE_SETUP.sql

4. If returns number:
   ✓ Table exists
   ✓ Move to Fix B
```

### FIX B: Check Supabase Credentials

```
1. Check supabase-new.js file

2. Verify these constants:
   SUPABASE_URL = 'https://znbxvkptusjrmeuyxibu.supabase.co'
   SUPABASE_ANON_KEY = 'eyJ...' (long token)

3. If wrong:
   ✗ Update them
   ✗ Get correct values from Supabase Settings → API

4. If correct:
   ✓ Hard refresh: Ctrl+Shift+R
   ✓ Wait 5 seconds
```

### FIX C: Check RLS Policies

```
1. SQL Editor → New Query

2. Test public read:
   SELECT * FROM services WHERE is_active = true;

3. If works:
   ✓ RLS is OK

4. If error:
   ✗ RLS policies wrong
   ✗ Run SAMPLE_DATA_SETUP.sql again
```

---

# ERROR 8: "null is not an object" in Console

## What This Means
```
JavaScript is trying to use data that doesn't exist
Data didn't load from database
```

## Why It Happens
```
✗ Services/products table empty
✗ Query returned no results
✗ Page loaded before data available
```

## How To Fix

### FIX A: Insert Sample Data

```
1. Run SAMPLE_DATA_SETUP.sql (if not done)

2. Verify data:
   SELECT COUNT(*) FROM services;
   Should return: 5

3. Hard refresh website: Ctrl+Shift+R

4. Wait 3-5 seconds for data to load

5. Check console again
```

### FIX B: Check Browser Cache

```
1. Hard refresh: Ctrl+Shift+R

2. If still error:
   - Open DevTools: F12
   - Right-click reload button
   - Choose: "Empty cache and hard refresh"

3. Wait 5 seconds
```

### FIX C: Check Network

```
1. Open DevTools: F12

2. Click "Network" tab

3. Refresh page: Ctrl+R

4. Look for requests to Supabase:
   - Should see GET requests to .supabase.co
   - Should get 200 status (green)
   - If 400 error (red):
     ✗ Wrong request
     ✗ Check code

5. Look for responses:
   - Should show JSON with data
   - If empty: table has no data
```

---

# ERROR 9: Admin Login Not Working

## What This Means
```
Cannot login to admin panel
Admin user doesn't exist or wrong credentials
```

## Why It Happens
```
✗ admin_users table empty
✗ Wrong email/password
✗ Admin user not inserted
```

## How To Fix

### FIX A: Create Admin User

```
1. SQL Editor → New Query

2. Paste:
   ─────────────────────────────────
   INSERT INTO admin_users (email, name, role, is_active)
   VALUES ('diwashb32@gmail.com', 'Diwas', 'admin', true)
   ON CONFLICT (email) DO NOTHING;
   ─────────────────────────────────

3. Click "Run"

4. Try login again with:
   Email: diwashb32@gmail.com
   Password: dipak@121
```

### FIX B: Check admin_users Table

```
1. SQL Editor → New Query

2. Paste:
   SELECT * FROM admin_users;

3. Click "Run"

4. If empty:
   ✗ No admin users exist
   ✗ Run FIX A above

5. If shows admin:
   ✓ User exists
   ✓ Try login again
```

### FIX C: Check Login Function

```
If user exists but can't login:

1. Check JavaScript console (F12)

2. Look for auth errors

3. Verify admin.js loads:
   In Network tab → admin.js should show 200

4. Hard refresh: Ctrl+Shift+R

5. Try login again
```

---

# ERROR 10: Storage Buckets Not Found

## What This Means
```
Website tries to upload/download from bucket
Bucket doesn't exist
```

## Why It Happens
```
✗ Storage buckets not created (Step 3 skipped)
✗ Wrong bucket names
```

## How To Fix

### FIX A: Create Missing Buckets

```
1. Supabase Dashboard → Storage

2. Check if these 5 exist:
   ✓ product-images
   ✓ gallery-images
   ✓ videos
   ✓ service-images
   ✓ transaction-screenshots

3. If any missing:
   - Click "New Bucket"
   - Enter bucket name
   - Check "Public bucket"
   - Click "Create bucket"

4. Repeat until all 5 exist
```

### FIX B: Verify Bucket Names

```
CORRECT NAMES:
  ✓ product-images (lowercase, hyphen)
  ✓ gallery-images (lowercase, hyphen)
  ✓ videos (lowercase)
  ✓ service-images (lowercase, hyphen)
  ✓ transaction-screenshots (lowercase, hyphen)

WRONG NAMES:
  ✗ Product-Images (capital P)
  ✗ product_images (underscore)
  ✗ productimages (no separator)
  ✗ Gallery Images (space)
```

### FIX C: Make Buckets Public

```
1. Storage section

2. For EACH bucket:
   - Click bucket name
   - Look for privacy setting
   - Should show: "Public" badge
   
3. If not public:
   - Click settings/options
   - Change to public
   - Save
```

---

# ERROR CHECKLIST

If you get ANY error:

```
1. Read error message carefully
   ↓
2. Find error in table at top
   ↓
3. Go to detailed section
   ↓
4. Follow "How To Fix" steps
   ↓
5. Try again
   ↓
6. If still stuck:
   - Hard refresh: Ctrl+Shift+R
   - Wait 5 seconds
   - Check console: F12
   - Look for new error messages
   - Repeat from step 1
```

---

# FINAL EMERGENCY FIX

**If nothing above works:**

```
NUCLEAR OPTION (Start Fresh):

1. Delete Supabase project
   - Go to Project Settings
   - Scroll down
   - Click "Delete project"
   - Confirm

2. Create new project
   - Go to Supabase Dashboard
   - Click "New project"
   - Enter name
   - Wait 5 minutes

3. Start setup from Step 1

4. Take your time, don't rush

5. Follow guide exactly
```

---

## 💡 TIPS TO AVOID ERRORS

```
1. Copy files carefully
   - Make sure full file is copied
   - Don't cut off beginning or end

2. Follow steps IN ORDER
   - Step 1 → Step 2 → Step 3
   - Don't skip or do out of order

3. Wait for completion
   - Don't click Run multiple times
   - Wait for ✅ success message

4. Hard refresh website
   - Ctrl+Shift+R after each major step
   - Clear browser cache if needed

5. Check file names exactly
   - Bucket: product-images (not product_images)
   - Column: setting_key (not key)
   - Table: services (not service)
```

---

**Following this guide, you'll resolve ANY error that appears!** 🔧

