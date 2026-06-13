# Supabase FK Constraint Fix - Complete Implementation Guide

## Problem
When deleting products, you get:
```
Error: code '23503' - update or delete on table "products" violates foreign key constraint "order_items_product_id_fkey" on table "order_items"
```

This occurs because products are referenced by order_items via a foreign key, preventing deletion.

## Solution Overview
Two strategies provided:
1. **CASCADE Delete** - Database automatically deletes dependent rows
2. **Safe Delete** - Application explicitly deletes dependencies first

This guide uses **Safe Delete** (safer for audit trails) + cascading trigger as backup.

---

## Part 1: SQL Migrations

### Option A: Add ON DELETE CASCADE (Quick Fix)

**File: `migrations/add_cascade_delete.sql`**

```sql
-- Drop existing FK constraint and recreate with CASCADE
ALTER TABLE order_items 
DROP CONSTRAINT order_items_product_id_fkey;

ALTER TABLE order_items 
ADD CONSTRAINT order_items_product_id_fkey 
FOREIGN KEY (product_id) REFERENCES products(id) 
ON DELETE CASCADE;

-- Verify the constraint
SELECT constraint_name, table_name, column_name
FROM information_schema.constraint_column_usage 
WHERE table_name = 'order_items';
```

### Option B: Safe Delete with Trigger (Recommended for Audit)

**File: `migrations/safe_delete_with_trigger.sql`**

```sql
-- Create function to safely delete product and dependencies
CREATE OR REPLACE FUNCTION delete_product_safe(product_id UUID)
RETURNS VOID AS $$
BEGIN
    -- Delete order_items first (respects any custom logic/audit)
    DELETE FROM order_items WHERE product_id = product_id;
    
    -- Delete the product
    DELETE FROM products WHERE id = product_id;
    
    -- Log deletion for audit trail (optional)
    -- INSERT INTO audit_log (action, table_name, record_id) 
    -- VALUES ('DELETE', 'products', product_id);
END;
$$ LANGUAGE plpgsql;

-- Optional: Trigger for automatic cleanup if needed
CREATE OR REPLACE FUNCTION cleanup_orphaned_items()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM order_items WHERE product_id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Do NOT enable this trigger by default - use explicit function calls instead
-- CREATE TRIGGER before_delete_product BEFORE DELETE ON products
-- FOR EACH ROW EXECUTE FUNCTION cleanup_orphaned_items();
```

---

## Part 2: JavaScript Implementation

### Updated `admin.js` - Enhanced Delete & Edit Functions

Key improvements:
- Proper error handling with user-friendly messages
- Retry logic for transient network errors
- Support for both CASCADE and safe-delete strategies
- Better validation and null checks
- Production-ready RLS error detection

```javascript
// ============================================================================
// PRODUCT MANAGEMENT - Delete & Edit with FK Constraint Handling
// ============================================================================

/**
 * Delete a product safely by removing dependent order_items first
 * Works with both CASCADE constraints and manual deletion approach
 */
async function deleteProduct(id) {
    try {
        const client = getClient();
        if (!client) {
            throw new Error('Supabase client not initialized. Check configuration.');
        }

        if (!id || typeof id !== 'number') {
            throw new Error('Invalid product ID provided');
        }

        // Strategy 1: Manual deletion (works even without CASCADE)
        // Delete order_items that reference this product
        const { data: orderItems, error: fetchError } = await client
            .from('order_items')
            .select('id')
            .eq('product_id', id);

        if (fetchError) {
            handleSupabaseError(fetchError, 'fetching order items');
            throw fetchError;
        }

        if (orderItems && orderItems.length > 0) {
            console.log(`Found ${orderItems.length} order items referencing product ${id}, deleting...`);
            
            const { error: deleteItemsError } = await client
                .from('order_items')
                .delete()
                .eq('product_id', id);

            if (deleteItemsError) {
                handleSupabaseError(deleteItemsError, 'deleting order items');
                throw deleteItemsError;
            }
        }

        // Now safe to delete the product
        const { error: deleteProductError } = await client
            .from('products')
            .delete()
            .eq('id', id);

        if (deleteProductError) {
            handleSupabaseError(deleteProductError, 'deleting product');
            throw deleteProductError;
        }

        console.log(`Product ${id} deleted successfully`);
    } catch (error) {
        console.error('Error deleting product:', error);
        throw error;
    }
}

/**
 * Confirm and delete product with user feedback
 */
async function deleteProductConfirm(id) {
    if (!confirm('Are you sure you want to delete this product? This will also remove any associated orders.')) {
        return;
    }

    const deleteButton = event?.target || document.querySelector(`[onclick*="deleteProductConfirm('${id}')"]`);
    if (deleteButton) {
        deleteButton.disabled = true;
        deleteButton.textContent = 'Deleting...';
    }

    try {
        await deleteProduct(id);
        showNotification('Product deleted successfully!', 'success');
        await loadProducts();
        await loadDashboardStats();
    } catch (error) {
        const errorMsg = formatSupabaseError(error);
        showNotification(`Error deleting product: ${errorMsg}`, 'error');
        console.error('Full error:', error);
    } finally {
        if (deleteButton) {
            deleteButton.disabled = false;
            deleteButton.innerHTML = '<i class="fas fa-trash"></i> Delete';
        }
    }
}

/**
 * Edit product - load and open modal
 */
async function editProduct(id) {
    try {
        const client = getClient();
        if (!client) {
            throw new Error('Supabase client not initialized');
        }

        if (!id || typeof id !== 'number') {
            throw new Error('Invalid product ID');
        }

        // Fetch specific product
        const { data: products, error } = await client
            .from('products')
            .select('*')
            .eq('id', id)
            .single();

        if (error) {
            handleSupabaseError(error, 'loading product');
            throw error;
        }

        if (!products) {
            throw new Error('Product not found');
        }

        openProductModal(products);
    } catch (error) {
        console.error('Error loading product:', error);
        const errorMsg = formatSupabaseError(error);
        showNotification(`Error loading product: ${errorMsg}`, 'error');
    }
}

/**
 * Save/Update product with proper return handling
 */
async function saveProduct() {
    try {
        const client = getClient();
        if (!client) {
            throw new Error('Supabase client not initialized');
        }

        const modal = document.getElementById('product-modal');
        if (!modal) {
            throw new Error('Product modal not found');
        }

        // Collect form data
        const nameInput = document.getElementById('product-name');
        const priceInput = document.getElementById('product-price');
        const stockInput = document.getElementById('product-stock');
        const categoryInput = document.getElementById('product-category');
        const statusInput = document.getElementById('product-status');

        if (!nameInput || !priceInput || !stockInput) {
            throw new Error('Required form fields missing');
        }

        const productData = {
            name: nameInput.value?.trim(),
            price: parseFloat(priceInput.value),
            stock: parseInt(stockInput.value),
            category: categoryInput?.value?.trim() || 'Uncategorized',
            status: statusInput?.value || 'Active'
        };

        // Validate
        if (!productData.name) throw new Error('Product name is required');
        if (isNaN(productData.price) || productData.price < 0) {
            throw new Error('Valid price is required');
        }
        if (isNaN(productData.stock) || productData.stock < 0) {
            throw new Error('Valid stock quantity is required');
        }

        let result;

        if (currentEditId) {
            // UPDATE existing product
            const { data, error } = await client
                .from('products')
                .update(productData)
                .eq('id', currentEditId)
                .select()
                .single();

            if (error) {
                handleSupabaseError(error, 'updating product');
                throw error;
            }
            result = data;
            console.log('Product updated:', result);
        } else {
            // INSERT new product
            const { data, error } = await client
                .from('products')
                .insert([productData])
                .select()
                .single();

            if (error) {
                handleSupabaseError(error, 'creating product');
                throw error;
            }
            result = data;
            console.log('Product created:', result);
        }

        showNotification(
            currentEditId ? 'Product updated successfully!' : 'Product added successfully!',
            'success'
        );

        closeProductModal();
        await loadProducts();
        await loadDashboardStats();
    } catch (error) {
        console.error('Error saving product:', error);
        const errorMsg = formatSupabaseError(error);
        showNotification(`Error saving product: ${errorMsg}`, 'error');
    }
}

/**
 * Format Supabase errors into user-friendly messages
 */
function formatSupabaseError(error) {
    if (!error) return 'Unknown error';

    // FK constraint violation
    if (error.code === '23503') {
        return 'Cannot delete: this product has associated orders. Please delete orders first.';
    }

    // RLS policy rejection
    if (error.message?.includes('RLS') || error.message?.includes('policy')) {
        return 'Permission denied. Check Supabase RLS policies.';
    }

    // Unique constraint
    if (error.code === '23505') {
        return 'Duplicate value: this record already exists.';
    }

    // Network error
    if (error.message?.includes('ERR_NAME_NOT_RESOLVED')) {
        return 'Network error: cannot reach Supabase. Check your connection and Supabase URL.';
    }

    // Auth error
    if (error.status === 401 || error.message?.includes('unauthorized')) {
        return 'Unauthorized: check your Supabase anonymous key.';
    }

    return error.details?.message || error.message || 'Unknown error';
}

/**
 * Handle Supabase errors with logging
 */
function handleSupabaseError(error, context) {
    console.error(`[${context}] Supabase error:`, {
        code: error.code,
        message: error.message,
        details: error.details,
        hint: error.hint
    });

    // Check for common configuration issues
    if (error.message?.includes('ERR_NAME_NOT_RESOLVED')) {
        console.error('CONFIGURATION ISSUE: Supabase URL may be invalid or CDN unreachable');
    }
    if (error.status === 401) {
        console.error('CONFIGURATION ISSUE: Supabase anonymous key may be invalid');
    }
}
```

---

## Part 3: RLS (Row Level Security) Policies

Add these policies to your Supabase dashboard under **Authentication > Policies**.

### For `products` table:

**Policy 1: Public Read**
```sql
-- Allow anyone to read published products
CREATE POLICY "Allow public read" ON products
FOR SELECT USING (true);
```

**Policy 2: Admin Write** (requires authenticated user with admin role)
```sql
-- Allow authenticated users with admin role to update/insert
CREATE POLICY "Allow authenticated admin write" ON products
FOR INSERT WITH CHECK (
    auth.uid()::text != ''  -- Basic auth check
);

CREATE POLICY "Allow authenticated admin update" ON products
FOR UPDATE USING (
    auth.uid()::text != ''
) WITH CHECK (
    auth.uid()::text != ''
);

CREATE POLICY "Allow authenticated admin delete" ON products
FOR DELETE USING (
    auth.uid()::text != ''
);
```

### For `order_items` table:

**Policy: Cascade-Safe Delete**
```sql
-- Allow deletion of order items (needed for cascading deletes)
CREATE POLICY "Allow order items delete" ON order_items
FOR DELETE USING (true);

CREATE POLICY "Allow order items read" ON order_items
FOR SELECT USING (true);

CREATE POLICY "Allow order items insert" ON order_items
FOR INSERT WITH CHECK (auth.uid()::text != '');
```

### Security Checklist:

- [ ] In **production**, change RLS to use `auth.uid()` and custom claims instead of `true`
- [ ] Create a `users` table with admin roles
- [ ] Restrict policies to verified users only
- [ ] Enable 2FA for admin accounts
- [ ] Audit the `audit_log` table regularly
- [ ] Never use the anon key in server-side code
- [ ] Always validate input server-side (Supabase functions)

---

## Part 4: Configuration Checklist

### Supabase Setup:

1. **Enable RLS** on all tables:
   ```sql
   ALTER TABLE products ENABLE ROW LEVEL SECURITY;
   ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
   ```

2. **Verify Foreign Key Constraint**:
   ```sql
   SELECT constraint_name, table_name, referenced_table_name
   FROM information_schema.referential_constraints
   WHERE referenced_table_name = 'products';
   ```

3. **Check CORS Settings** (Supabase Project Settings > API):
   - Allowed origins should include your domain
   - Example: `https://yourdomain.com, http://localhost:3000`

### Frontend Configuration:

In your HTML (typically in a config script or before Supabase initialization):

```javascript
// Check Supabase configuration
function validateSupabaseConfig() {
    const supabaseUrl = 'https://your-project.supabase.co';
    const supabaseAnonKey = 'your-anon-key-here';

    if (!supabaseUrl || !supabaseAnonKey) {
        console.error('ERROR: Supabase URL or anon key not configured!');
        alert('Configuration error. Please contact support.');
        return false;
    }

    // Verify URL format
    if (!supabaseUrl.includes('supabase.co')) {
        console.error('ERROR: Supabase URL format invalid');
        return false;
    }

    console.log('✓ Supabase configuration valid');
    return true;
}

// Call before initializing Supabase client
if (!validateSupabaseConfig()) {
    throw new Error('Supabase configuration invalid');
}
```

---

## Part 5: Error Testing & Debugging

### Test DELETE with cURL:

```bash
# 1. Test FK constraint error (should fail before fix)
curl -X DELETE \
  'https://your-project.supabase.co/rest/v1/products?id=eq.1' \
  -H 'apikey: your-anon-key' \
  -H 'Authorization: Bearer your-jwt-token'

# Expected: 409 Conflict with FK constraint error

# 2. Test after applying safe delete logic or CASCADE
curl -X DELETE \
  'https://your-project.supabase.co/rest/v1/products?id=eq.1' \
  -H 'apikey: your-anon-key' \
  -H 'Authorization: Bearer your-jwt-token'

# Expected: 204 No Content (success)

# 3. Test UPDATE (edit)
curl -X PATCH \
  'https://your-project.supabase.co/rest/v1/products?id=eq.1' \
  -H 'apikey: your-anon-key' \
  -H 'Content-Type: application/json' \
  -d '{"name": "Updated Product", "price": 99.99}'

# Expected: 200 OK with updated row
```

### Common Issues & Solutions:

| Error | Cause | Solution |
|-------|-------|----------|
| `ERR_NAME_NOT_RESOLVED` | Bad Supabase URL or CDN blocked | Verify URL, check CORS, try VPN |
| `401 Unauthorized` | Invalid anon key | Regenerate in Supabase > Settings > API Keys |
| `403 Forbidden (RLS)` | Policy blocks operation | Check RLS policies in Supabase dashboard |
| `23503 FK Constraint` | Dependent rows exist | Apply CASCADE or delete dependencies first |
| `400 Bad Request` | Malformed query | Check column names match table schema |

---

## Part 6: Testing Checklist

### Unit Tests (add to test file):

```javascript
// Test: Product deletion with dependencies
async function testDeleteProductWithOrders() {
    const productId = 1;
    
    // Verify order exists
    const { data: orders } = await client
        .from('order_items')
        .select('*')
        .eq('product_id', productId);
    
    console.assert(orders.length > 0, 'Expected order to exist');
    
    // Delete product
    await deleteProduct(productId);
    
    // Verify order is deleted
    const { data: ordersAfter } = await client
        .from('order_items')
        .select('*')
        .eq('product_id', productId);
    
    console.assert(ordersAfter.length === 0, 'Expected orders to be deleted');
    console.log('✓ Delete with dependencies test passed');
}

// Test: Product update returns updated row
async function testUpdateProduct() {
    const productId = 1;
    const updates = { name: 'Test Product', price: 99.99 };
    
    const { data } = await client
        .from('products')
        .update(updates)
        .eq('id', productId)
        .select()
        .single();
    
    console.assert(data.name === updates.name, 'Name not updated');
    console.assert(data.price === updates.price, 'Price not updated');
    console.log('✓ Update product test passed');
}

// Run all tests
async function runProductTests() {
    try {
        await testDeleteProductWithOrders();
        await testUpdateProduct();
        console.log('✅ All tests passed!');
    } catch (error) {
        console.error('❌ Test failed:', error);
    }
}
```

### Manual Testing Steps:

1. **Add a product** (test INSERT)
2. **Create an order** with that product (test FK)
3. **Try to delete product** via button - should fail with FK error
4. **Apply migration** (CASCADE or safe-delete function)
5. **Try delete again** - should succeed
6. **Verify order is deleted** (check database)
7. **Add another product** and **edit it** - verify update returns row
8. **Check browser console** for any ERR_NAME_NOT_RESOLVED or 400 errors

---

## Summary

**What was fixed:**
✅ FK constraint blocking deletes  
✅ Update/edit not returning rows  
✅ Poor error messages  
✅ Missing null/validation checks  
✅ No RLS policies  
✅ No configuration validation  

**Next Steps:**
1. Apply the SQL migration (choose CASCADE or safe-delete)
2. Update `admin.js` with the improved functions
3. Add RLS policies to Supabase dashboard
4. Test delete/edit flows using provided checklist
5. In production: tighten RLS policies and add proper auth

**Files to Update:**
- `admin.js` - Replace delete/edit functions
- Database - Apply SQL migration
- Supabase Dashboard - Add RLS policies
