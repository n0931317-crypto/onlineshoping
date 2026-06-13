# Payment Proof Screenshot Display Fix

## Problem
Payment proof screenshots uploaded by users were not appearing in the admin panel's order management section, even though:
- The upload to Supabase storage was successful
- The public URL was being generated correctly
- The admin panel code was correct and ready to display the screenshot

## Root Cause
The issue was in **payment.js** - the `transaction_screenshot` URL was being generated and uploaded to Supabase storage, but **was NOT being saved to the database** when creating the order.

The order insertion was missing the `transaction_screenshot` field in the insert statement.

## Solution
Added the `transaction_screenshot` field to the order insert statement in the `confirmPayment()` function.

### File Changed
- **b:\sunr\payment.js** (Line 415)

### Change Made
```javascript
// BEFORE - Missing transaction_screenshot field
const { data: orderInsert, error: orderError } = await client
    .from('orders')
    .insert([{
        order_number: uniqueOrderNumber,
        customer_name: orderData.customer_name,
        customer_email: orderData.customer_email,
        customer_phone: orderData.customer_phone,
        delivery_address: addressData.street_address,
        delivery_date: orderData.delivery_date,
        total_amount: orderData.total_amount,
        status: 'pending_verification',
        order_notes: orderData.notes,
        payment_method: paymentMethod,
        transaction_code: transactionData.transaction_code
        // MISSING: transaction_screenshot field
    }])

// AFTER - Added transaction_screenshot field
const { data: orderInsert, error: orderError } = await client
    .from('orders')
    .insert([{
        order_number: uniqueOrderNumber,
        customer_name: orderData.customer_name,
        customer_email: orderData.customer_email,
        customer_phone: orderData.customer_phone,
        delivery_address: addressData.street_address,
        delivery_date: orderData.delivery_date,
        total_amount: orderData.total_amount,
        status: 'pending_verification',
        order_notes: orderData.notes,
        payment_method: paymentMethod,
        transaction_code: transactionData.transaction_code,
        transaction_screenshot: transactionData.screenshot_url  // ADDED
    }])
```

## Data Flow
Now the complete flow is:
1. ✅ User uploads screenshot on payment page
2. ✅ Screenshot is uploaded to Supabase storage (`transaction-screenshots` bucket)
3. ✅ Public URL is generated from storage
4. ✅ **NEW**: URL is saved to `transaction_screenshot` column in orders table
5. ✅ Admin can view the screenshot in order management panel

## Testing
To verify the fix:
1. Create a new test order with payment proof screenshot
2. Go to admin panel → Order Management
3. Click on the order to view details
4. Scroll to "Payment Screenshot/Proof" section
5. The screenshot should now display correctly

## Related Files
- Admin display logic: `admin.js` (lines 2315-2370)
- Database schema: `SUPABASE_ECOMMERCE_SCHEMA.sql`
- Payment page: `payment.html`
