-- ============================================================================
-- MIGRATION: Add ON DELETE CASCADE to order_items.product_id FK
-- ============================================================================
-- Run this if you want automatic cascading deletes (simplest approach)
-- WARNING: Deleting a product will automatically delete all related order_items
-- 
-- Before running: Backup your database!
-- Estimated runtime: < 1 second
-- ============================================================================

-- Step 1: Drop the existing foreign key constraint
ALTER TABLE order_items 
DROP CONSTRAINT order_items_product_id_fkey;

-- Step 2: Recreate the constraint with ON DELETE CASCADE
ALTER TABLE order_items 
ADD CONSTRAINT order_items_product_id_fkey 
FOREIGN KEY (product_id) REFERENCES products(id) 
ON DELETE CASCADE;

-- Step 3: Verify the constraint is applied correctly
-- Run this to confirm:
/*
SELECT 
    constraint_name,
    table_name,
    column_name,
    referenced_table_name,
    referenced_column_name
FROM information_schema.referential_constraints
WHERE constraint_name = 'order_items_product_id_fkey';

-- Expected output:
-- constraint_name: order_items_product_id_fkey
-- table_name: order_items
-- column_name: product_id
-- referenced_table_name: products
-- referenced_column_name: id
*/

-- Step 4: Test deletion (optional, on test data only)
-- DELETE FROM products WHERE id = <test_product_id>;
-- -- This should now succeed and automatically delete related order_items
