-- ============================================================================
-- SUPABASE ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
-- Add these policies to your Supabase dashboard or execute in SQL Editor
-- 
-- Structure:
-- 1. Development/Testing policies (permissive, for quick testing)
-- 2. Production policies (restrictive, requires authentication)
-- 3. Admin policies (for authenticated admin users)
--
-- IMPORTANT: Review security settings before going to production!
-- ============================================================================

-- ============================================================================
-- STEP 1: Enable RLS on all relevant tables
-- ============================================================================

ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- SECTION A: DEVELOPMENT POLICIES (Testing Only!)
-- ============================================================================
-- WARNING: These are permissive for testing. DO NOT use in production!

-- Products: Public Read (for testing)
CREATE POLICY "dev_products_public_read" ON products
FOR SELECT USING (true);

-- Products: Public Insert (for testing)
CREATE POLICY "dev_products_public_insert" ON products
FOR INSERT WITH CHECK (true);

-- Products: Public Update (for testing)
CREATE POLICY "dev_products_public_update" ON products
FOR UPDATE USING (true) WITH CHECK (true);

-- Products: Public Delete (for testing)
CREATE POLICY "dev_products_public_delete" ON products
FOR DELETE USING (true);

-- Order Items: Public All (for testing)
CREATE POLICY "dev_order_items_public_read" ON order_items
FOR SELECT USING (true);

CREATE POLICY "dev_order_items_public_write" ON order_items
FOR INSERT WITH CHECK (true);

CREATE POLICY "dev_order_items_public_update" ON order_items
FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "dev_order_items_public_delete" ON order_items
FOR DELETE USING (true);

-- ============================================================================
-- SECTION B: PRODUCTION POLICIES (Secure)
-- ============================================================================
-- Uncomment and customize these for production
-- Replace 'your-admin-role' and user validation with actual auth logic

/*

-- Drop development policies first
DROP POLICY IF EXISTS "dev_products_public_read" ON products;
DROP POLICY IF EXISTS "dev_products_public_insert" ON products;
DROP POLICY IF EXISTS "dev_products_public_update" ON products;
DROP POLICY IF EXISTS "dev_products_public_delete" ON products;
DROP POLICY IF EXISTS "dev_order_items_public_read" ON order_items;
DROP POLICY IF EXISTS "dev_order_items_public_write" ON order_items;
DROP POLICY IF EXISTS "dev_order_items_public_update" ON order_items;
DROP POLICY IF EXISTS "dev_order_items_public_delete" ON order_items;

-- PRODUCTS TABLE POLICIES

-- 1. Products: Authenticated users can read published products
CREATE POLICY "products_authenticated_read" ON products
FOR SELECT
USING (
    auth.uid() IS NOT NULL
    AND status = 'Active'  -- Only published products
);

-- 2. Products: Only authenticated admin users can insert
CREATE POLICY "products_admin_insert" ON products
FOR INSERT
WITH CHECK (
    auth.uid() IS NOT NULL
    AND EXISTS (
        SELECT 1 FROM user_roles 
        WHERE user_id = auth.uid() 
        AND role = 'admin'
    )
);

-- 3. Products: Only admin can update their own products
CREATE POLICY "products_admin_update" ON products
FOR UPDATE
USING (
    auth.uid() IS NOT NULL
    AND EXISTS (
        SELECT 1 FROM user_roles 
        WHERE user_id = auth.uid() 
        AND role = 'admin'
    )
)
WITH CHECK (
    auth.uid() IS NOT NULL
    AND EXISTS (
        SELECT 1 FROM user_roles 
        WHERE user_id = auth.uid() 
        AND role = 'admin'
    )
);

-- 4. Products: Only admin can delete
CREATE POLICY "products_admin_delete" ON products
FOR DELETE
USING (
    auth.uid() IS NOT NULL
    AND EXISTS (
        SELECT 1 FROM user_roles 
        WHERE user_id = auth.uid() 
        AND role = 'admin'
    )
);

-- ORDER ITEMS TABLE POLICIES

-- 5. Order items: Authenticated users can read their own orders
CREATE POLICY "order_items_read_own" ON order_items
FOR SELECT
USING (
    auth.uid() IS NOT NULL
    AND order_id IN (
        SELECT id FROM orders WHERE user_id = auth.uid()
    )
);

-- 6. Order items: Admin can read all order items
CREATE POLICY "order_items_admin_read_all" ON order_items
FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM user_roles 
        WHERE user_id = auth.uid() 
        AND role = 'admin'
    )
);

-- 7. Order items: Only admin can insert
CREATE POLICY "order_items_admin_insert" ON order_items
FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM user_roles 
        WHERE user_id = auth.uid() 
        AND role = 'admin'
    )
);

-- 8. Order items: Only admin can delete
CREATE POLICY "order_items_admin_delete" ON order_items
FOR DELETE
USING (
    EXISTS (
        SELECT 1 FROM user_roles 
        WHERE user_id = auth.uid() 
        AND role = 'admin'
    )
);

*/

-- ============================================================================
-- SECTION C: MINIMAL PRODUCTION SETUP (Recommended for Quick Start)
-- ============================================================================
-- Simple auth check without complex role tables
-- Use this if you don't have a user_roles table yet

/*

-- PRODUCTS: Minimal Auth

CREATE POLICY "products_auth_read" ON products
FOR SELECT USING (auth.uid() IS NOT NULL OR status = 'Active');

CREATE POLICY "products_auth_write" ON products
FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "products_auth_update" ON products
FOR UPDATE USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "products_auth_delete" ON products
FOR DELETE USING (auth.uid() IS NOT NULL);

-- ORDER_ITEMS: Minimal Auth

CREATE POLICY "order_items_read" ON order_items
FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "order_items_insert" ON order_items
FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "order_items_update" ON order_items
FOR UPDATE USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "order_items_delete" ON order_items
FOR DELETE USING (auth.uid() IS NOT NULL);

*/

-- ============================================================================
-- SECTION D: CREATE USER_ROLES TABLE (For Advanced Auth)
-- ============================================================================
-- Optional: Use this if you want role-based access control

/*

CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, role)
);

-- Enable RLS on user_roles
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Anyone can read roles (for app logic)
CREATE POLICY "user_roles_public_read" ON user_roles
FOR SELECT USING (true);

-- Only authenticated users can see their own roles
CREATE POLICY "user_roles_see_own" ON user_roles
FOR SELECT USING (user_id = auth.uid());

-- Add initial admin user (replace with actual admin UUID)
INSERT INTO user_roles (user_id, role)
VALUES ('550e8400-e29b-41d4-a716-446655440000', 'admin')
ON CONFLICT DO NOTHING;

*/

-- ============================================================================
-- HELPER: Check Current Policies
-- ============================================================================

-- Run this to see all RLS policies:
/*
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    qual,
    with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
*/

-- Check which tables have RLS enabled:
/*
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
*/

-- ============================================================================
-- DOCUMENTATION: RLS Policy Best Practices
-- ============================================================================

/*

WHY RLS?
- Prevents unauthorized data access
- Enforces data isolation at database level
- Protects against SQL injection and privilege escalation

TESTING RLS:
1. Create test user without admin role
2. Try to update/delete products
3. Should get 403 Forbidden error
4. Add user to admin role
5. Try again - should succeed

DEBUGGING RLS ISSUES:
1. Check Supabase logs: Project Settings > Logs > Postgres
2. Look for "RLS policy" or "permission denied" errors
3. Verify auth.uid() matches user_roles.user_id
4. Check JWT tokens include correct user ID
5. Ensure policies use correct comparison operators (=, IS NOT NULL, etc)

COMMON RLS PROBLEMS:
- Null auth.uid() = Not authenticated. Check JWT token.
- Case sensitivity: Use ILIKE for text comparison if needed.
- Missing role check: Add fallback policy for unauthenticated users.
- Wrong table reference: Verify table/column names are correct.

SECURITY TIPS:
1. NEVER use (true) in production - only for development!
2. ALWAYS require auth.uid() IS NOT NULL for write operations
3. Use role-based checks for sensitive operations
4. Log all deletes to audit table
5. Regular audit: SELECT * FROM pg_policies;
6. Test policies before deployment
7. Use Supabase JWT verification in frontend

*/

-- ============================================================================
-- QUICK TEST: Verify RLS is working
-- ============================================================================

-- As admin/authenticated user, this should return products:
-- SELECT * FROM products LIMIT 1;

-- As anonymous (no JWT), with development policies, this should return public products:
-- SELECT * FROM products WHERE status = 'Active' LIMIT 1;

-- DELETE attempt should be blocked for non-admin:
-- DELETE FROM products WHERE id = 1;
-- (Error: new row violates row-level security policy "products_auth_delete")
