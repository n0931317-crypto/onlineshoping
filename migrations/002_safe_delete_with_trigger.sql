-- ============================================================================
-- MIGRATION: Safe Delete with Trigger (Audit-Friendly)
-- ============================================================================
-- Use this if you need to control deletion logic or maintain audit trails
-- Deletes are initiated only when explicitly called
-- 
-- Provides two approaches:
-- 1. Stored procedure for explicit deletion
-- 2. Optional trigger for safety net
--
-- Before running: Backup your database!
-- ============================================================================

-- ============================================================================
-- APPROACH 1: Stored Procedure (Recommended - Explicit Control)
-- ============================================================================

-- Create function to safely delete a product and its dependencies
CREATE OR REPLACE FUNCTION delete_product_safe(product_id_param UUID)
RETURNS TABLE(deleted_product_id UUID, deleted_order_items_count INT) AS $$
DECLARE
    deleted_items_count INT;
    deleted_product UUID;
BEGIN
    -- Delete all order_items referencing this product
    DELETE FROM order_items 
    WHERE product_id = product_id_param
    RETURNING product_id INTO deleted_product;
    
    GET DIAGNOSTICS deleted_items_count = ROW_COUNT;
    
    -- Delete the product itself
    DELETE FROM products 
    WHERE id = product_id_param;
    
    -- Return results
    RETURN QUERY SELECT product_id_param, deleted_items_count;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions (adjust as needed for your auth setup)
-- GRANT EXECUTE ON FUNCTION delete_product_safe TO authenticated;

-- Usage from JavaScript:
-- const { data, error } = await client.rpc('delete_product_safe', { 
--     product_id_param: productId 
-- });

-- ============================================================================
-- APPROACH 2: Optional Audit Trigger (Safety Net)
-- ============================================================================
-- Enable this if you want automatic tracking of deletions

-- Create audit log table (if not exists)
CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    performed_by UUID REFERENCES auth.users(id) DEFAULT auth.uid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on audit log
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read their own deletions (for transparency)
CREATE POLICY "Users can read own audit logs" ON audit_log
FOR SELECT USING (performed_by = auth.uid() OR auth.uid()::text LIKE '%admin%');

-- Function to log deletions to audit table
CREATE OR REPLACE FUNCTION log_product_deletion()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (action, table_name, record_id, old_values)
    VALUES ('DELETE', 'products', OLD.id, row_to_json(OLD));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger (disabled by default - uncomment to enable)
-- DO NOT enable this unless you want automatic cascading
-- CREATE TRIGGER before_delete_product 
-- BEFORE DELETE ON products
-- FOR EACH ROW 
-- EXECUTE FUNCTION log_product_deletion();

-- ============================================================================
-- APPROACH 3: Alternative - Keep CASCADE but Add Trigger for Logging
-- ============================================================================
-- This is a hybrid: CASCADE handles FK, trigger logs deletions

-- Enable CASCADE on FK (if not already done)
-- ALTER TABLE order_items 
-- DROP CONSTRAINT order_items_product_id_fkey;
-- 
-- ALTER TABLE order_items 
-- ADD CONSTRAINT order_items_product_id_fkey 
-- FOREIGN KEY (product_id) REFERENCES products(id) 
-- ON DELETE CASCADE;

-- Function to log any deletion attempt
CREATE OR REPLACE FUNCTION audit_product_deletion()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (action, table_name, record_id, old_values)
    VALUES ('DELETE_PRODUCT', 'products', OLD.id, row_to_json(OLD));
    
    -- Also log the cascading deletes
    INSERT INTO audit_log (action, table_name, record_id, old_values)
    SELECT 'DELETE_ORDER_ITEM', 'order_items', id, row_to_json(order_items.*)
    FROM order_items 
    WHERE product_id = OLD.id;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- This trigger AFTER DELETE works with CASCADE
-- CREATE TRIGGER audit_after_delete_product
-- AFTER DELETE ON products
-- FOR EACH ROW
-- EXECUTE FUNCTION audit_product_deletion();

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- View current FK constraints
/*
SELECT 
    constraint_name,
    table_name,
    column_name,
    referenced_table_name
FROM information_schema.referential_constraints
WHERE referenced_table_name = 'products'
ORDER BY table_name;
*/

-- View audit log (if enabled)
/*
SELECT 
    action,
    table_name,
    record_id,
    performed_by,
    created_at
FROM audit_log
ORDER BY created_at DESC
LIMIT 20;
*/

-- ============================================================================
-- TESTING
-- ============================================================================

-- Test with Approach 1 (Stored Procedure):
/*
-- Create test data
INSERT INTO products (name, price, stock, category) 
VALUES ('Test Product', 99.99, 10, 'test');

INSERT INTO order_items (order_id, product_id, quantity)
VALUES (1, (SELECT id FROM products WHERE name = 'Test Product'), 1);

-- Delete using procedure
SELECT * FROM delete_product_safe(
    (SELECT id FROM products WHERE name = 'Test Product')
);

-- Verify deletion
SELECT COUNT(*) FROM products WHERE name = 'Test Product';  -- Should be 0
SELECT COUNT(*) FROM order_items WHERE product_id IN 
    (SELECT id FROM products WHERE name = 'Test Product');  -- Should be 0
*/
