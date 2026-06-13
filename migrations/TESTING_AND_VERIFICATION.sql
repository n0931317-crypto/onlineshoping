-- ============================================================================
-- SUPABASE FK CONSTRAINT TEST SUITE
-- ============================================================================
-- Run these tests to verify the delete/edit fixes are working
-- Execute in Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- SETUP: Create test data
-- ============================================================================

-- Add test products
INSERT INTO products (name, price, stock_quantity, category, description, is_active)
VALUES 
    ('Test Product 1', 99.99, 10, 'test', 'Product for FK constraint testing', true),
    ('Test Product 2', 49.99, 5, 'test', 'Another test product', true),
    ('Test Product 3', 199.99, 20, 'test', 'Third test product with no orders', true)
ON CONFLICT DO NOTHING;

-- Get the first test product ID
-- SELECT id FROM products WHERE name = 'Test Product 1' LIMIT 1;

-- Add test order (replace order_id and product_id with real values)
-- INSERT INTO orders (customer_name, customer_email, customer_phone, total_amount, status)
-- VALUES ('Test Customer', 'test@example.com', '+977-9841234567', 99.99, 'pending_verification');

-- Add test order item referencing the test product
-- INSERT INTO order_items (order_id, product_id, quantity, price, product_name)
-- VALUES (1, <product_id>, 1, 99.99, 'Test Product 1');

-- ============================================================================
-- TEST 1: Verify FK Constraint Blocks Deletion
-- ============================================================================

-- This should FAIL with FK constraint error (before applying migration):
/*
DELETE FROM products WHERE name = 'Test Product 1';
-- Expected error: code '23503' - FK constraint violation
*/

-- ============================================================================
-- TEST 2: Verify Cascading Delete Works (After Applying Migration)
-- ============================================================================

-- After applying the CASCADE migration or safe-delete, this should SUCCEED:
/*
DELETE FROM products WHERE name = 'Test Product 1';
-- Expected: 1 row deleted, order_items automatically deleted
*/

-- Verify deletion cascaded:
/*
SELECT COUNT(*) FROM products WHERE name = 'Test Product 1';  -- Should return 0
SELECT COUNT(*) FROM order_items WHERE product_id = <product_id>;  -- Should return 0
*/

-- ============================================================================
-- TEST 3: Verify Product Update Returns Row
-- ============================================================================

-- Update a product and verify it returns the updated row:
/*
UPDATE products
SET price = 149.99, stock_quantity = 15
WHERE name = 'Test Product 2'
RETURNING id, name, price, stock_quantity;

-- Expected: Returns the updated product row
*/

-- Test via Supabase JS client (equivalent):
/*
const { data, error } = await client
    .from('products')
    .update({ price: 149.99, stock_quantity: 15 })
    .eq('name', 'Test Product 2')
    .select()
    .single();

// data should contain updated row
*/

-- ============================================================================
-- TEST 4: Verify Safe Delete (Order Items First)
-- ============================================================================

-- If using safe-delete with trigger/function:
/*
-- Delete order items first
DELETE FROM order_items WHERE product_id = <product_id>;

-- Then delete product
DELETE FROM products WHERE id = <product_id>;

-- Verify both deleted
SELECT COUNT(*) FROM products WHERE id = <product_id>;        -- Should be 0
SELECT COUNT(*) FROM order_items WHERE product_id = <product_id>;  -- Should be 0
*/

-- ============================================================================
-- TEST 5: Verify RLS Policies Block Unauthorized Access
-- ============================================================================

-- As unauthenticated user, this should fail with 403:
/*
SELECT * FROM products;
-- Expected error if RLS policy requires auth
*/

-- Delete attempt without proper auth should fail:
/*
DELETE FROM products WHERE id = <test_product_id>;
-- Expected error: new row violates row-level security policy
*/

-- ============================================================================
-- TEST 6: Verify No Orphaned Order Items Exist
-- ============================================================================

-- Check for order_items referencing deleted products:
/*
SELECT oi.* FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.id
WHERE p.id IS NULL;

-- Expected: Empty result set (no orphaned items)
*/

-- ============================================================================
-- TEST 7: Verify Audit Log (If Implemented)
-- ============================================================================

-- Check audit log for delete operations:
/*
SELECT * FROM audit_log
WHERE action IN ('DELETE_PRODUCT', 'DELETE_ORDER_ITEM')
ORDER BY created_at DESC
LIMIT 10;

-- Should show all delete operations with timestamps
*/

-- ============================================================================
-- CURL TEST COMMANDS
-- ============================================================================

-- Test 1: List products (public read)
-- curl -X GET \
--   'https://YOUR_PROJECT.supabase.co/rest/v1/products?select=id,name,price' \
--   -H 'apikey: YOUR_ANON_KEY'
-- Expected: 200 OK with product list

-- Test 2: Update product
-- curl -X PATCH \
--   'https://YOUR_PROJECT.supabase.co/rest/v1/products?id=eq.1' \
--   -H 'apikey: YOUR_ANON_KEY' \
--   -H 'Content-Type: application/json' \
--   -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
--   -d '{"price": 149.99, "stock_quantity": 15}'
-- Expected: 200 OK with updated row

-- Test 3: Delete product (before cascade)
-- curl -X DELETE \
--   'https://YOUR_PROJECT.supabase.co/rest/v1/products?id=eq.1' \
--   -H 'apikey: YOUR_ANON_KEY' \
--   -H 'Authorization: Bearer YOUR_JWT_TOKEN'
-- Expected: 409 Conflict (FK constraint error)

-- Test 4: Delete product (after cascade applied)
-- Same command should return 204 No Content

-- ============================================================================
-- CLEANUP: Remove test data
-- ============================================================================

-- Remove test products:
/*
DELETE FROM products WHERE category = 'test';

-- Or remove specific products:
DELETE FROM products WHERE name LIKE 'Test Product%';

-- Verify cleanup:
SELECT COUNT(*) FROM products WHERE category = 'test';  -- Should be 0
*/

-- ============================================================================
-- PRODUCTION SAFETY CHECKS
-- ============================================================================

-- Check for orphaned order_items:
SELECT oi.id, oi.order_id, oi.product_id
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.id
WHERE p.id IS NULL;
-- If any rows returned, those items reference deleted products!

-- Check FK constraint status:
SELECT constraint_name, table_name, column_name
FROM information_schema.constraint_column_usage
WHERE table_name = 'order_items' AND column_name = 'product_id';

-- Check RLS is enabled:
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Check for policies:
SELECT schemaname, tablename, policyname
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename;

-- ============================================================================
-- DIAGNOSTIC QUERIES
-- ============================================================================

-- Count products and their order references:
SELECT 
    p.id,
    p.name,
    COUNT(oi.id) as order_count,
    SUM(oi.quantity) as total_quantity_sold
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name
ORDER BY order_count DESC;

-- Find products with most orders:
SELECT 
    p.id,
    p.name,
    COUNT(DISTINCT oi.order_id) as distinct_orders,
    COUNT(oi.id) as total_items,
    SUM(oi.quantity * oi.price) as total_revenue
FROM products p
INNER JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name
ORDER BY total_revenue DESC;

-- Check recent delete attempts (from postgres logs):
/*
SELECT 
    query,
    query_start,
    state
FROM pg_stat_statements
WHERE query LIKE '%DELETE%products%'
ORDER BY query_start DESC
LIMIT 10;
*/
