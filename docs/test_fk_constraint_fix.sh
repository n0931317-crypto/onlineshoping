#!/bin/bash
# ============================================================================
# Supabase FK Constraint Fix - cURL Test Commands
# ============================================================================
# Use these commands to test delete/edit from command line (useful for CI/CD)
# Requires: curl, jq (optional for pretty JSON)
#
# Setup:
# 1. Replace YOUR_PROJECT with your Supabase project name
# 2. Replace YOUR_ANON_KEY with your Supabase anonymous key
# 3. Replace YOUR_JWT_TOKEN with a valid JWT token (or remove -H Authorization)
# 4. Replace PRODUCT_ID with actual product ID
#
# Get your credentials from: Supabase Dashboard > Project Settings > API
# ============================================================================

# Configuration
SUPABASE_PROJECT="your-project"
SUPABASE_URL="https://${SUPABASE_PROJECT}.supabase.co"
SUPABASE_ANON_KEY="your-anon-key-here"
SUPABASE_JWT_TOKEN="your-jwt-token-here"  # Leave empty if not needed
PRODUCT_ID="1"  # Replace with actual product ID

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# TEST 1: Health Check - List Products (Public Read)
# ============================================================================
echo -e "${BLUE}TEST 1: List Products (Health Check)${NC}"
echo "==================================="

curl -X GET \
  "${SUPABASE_URL}/rest/v1/products?select=id,name,price,stock_quantity" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Accept: application/json" \
  -w "\nHTTP Status: %{http_code}\n" \
  | jq '.' 2>/dev/null || echo "Products retrieved"

echo ""

# ============================================================================
# TEST 2: Create Test Product
# ============================================================================
echo -e "${BLUE}TEST 2: Create Test Product${NC}"
echo "==================================="

TEST_PRODUCT_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/rest/v1/products" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "name": "Test Product for FK Test",
    "price": 99.99,
    "stock_quantity": 10,
    "category": "test",
    "description": "Created by cURL test script",
    "is_active": true
  }')

echo "$TEST_PRODUCT_RESPONSE" | jq '.' 2>/dev/null || echo "$TEST_PRODUCT_RESPONSE"

# Extract product ID from response
TEST_PRODUCT_ID=$(echo "$TEST_PRODUCT_RESPONSE" | jq -r '.[0].id' 2>/dev/null || echo "")
echo -e "${GREEN}Created test product ID: ${TEST_PRODUCT_ID}${NC}"
echo ""

# ============================================================================
# TEST 3: Update Product (Edit)
# ============================================================================
if [ ! -z "$TEST_PRODUCT_ID" ] && [ "$TEST_PRODUCT_ID" != "null" ]; then
    echo -e "${BLUE}TEST 3: Update Product (Edit)${NC}"
    echo "==================================="

    curl -X PATCH \
      "${SUPABASE_URL}/rest/v1/products?id=eq.${TEST_PRODUCT_ID}" \
      -H "apikey: ${SUPABASE_ANON_KEY}" \
      -H "Content-Type: application/json" \
      -H "Prefer: return=representation" \
      -d '{
        "price": 149.99,
        "stock_quantity": 15,
        "name": "Updated Test Product"
      }' \
      -w "\nHTTP Status: %{http_code}\n" \
      | jq '.' 2>/dev/null || echo "Product updated"

    echo ""
fi

# ============================================================================
# TEST 4: Delete Product WITHOUT Dependencies
# ============================================================================
if [ ! -z "$TEST_PRODUCT_ID" ] && [ "$TEST_PRODUCT_ID" != "null" ]; then
    echo -e "${BLUE}TEST 4: Delete Product (No Dependencies)${NC}"
    echo "==================================="

    curl -X DELETE \
      "${SUPABASE_URL}/rest/v1/products?id=eq.${TEST_PRODUCT_ID}" \
      -H "apikey: ${SUPABASE_ANON_KEY}" \
      -H "Authorization: Bearer ${SUPABASE_JWT_TOKEN}" \
      -w "\nHTTP Status: %{http_code}\n"

    echo -e "${GREEN}Deletion request sent${NC}"
    echo ""
fi

# ============================================================================
# TEST 5: Create Product with Dependent Order Item
# ============================================================================
echo -e "${BLUE}TEST 5: Create Product + Order Item (For FK Test)${NC}"
echo "==================================="

# Create product
FK_TEST_PRODUCT=$(curl -s -X POST \
  "${SUPABASE_URL}/rest/v1/products" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "name": "FK Test Product",
    "price": 199.99,
    "stock_quantity": 5,
    "category": "test",
    "description": "Has dependent order items",
    "is_active": true
  }')

FK_PRODUCT_ID=$(echo "$FK_TEST_PRODUCT" | jq -r '.[0].id' 2>/dev/null || echo "")
echo "Created product ID: ${FK_PRODUCT_ID}"

# Note: Order item creation requires valid order_id
# For testing, you may need to create an order first
if [ ! -z "$FK_PRODUCT_ID" ] && [ "$FK_PRODUCT_ID" != "null" ]; then
    echo -e "${YELLOW}To fully test FK constraint, create an order item manually:${NC}"
    echo "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (1, ${FK_PRODUCT_ID}, 1, 199.99);"
    echo ""
fi

# ============================================================================
# TEST 6: Delete Product with FK Constraint (Should Fail Before Fix)
# ============================================================================
if [ ! -z "$FK_PRODUCT_ID" ] && [ "$FK_PRODUCT_ID" != "null" ]; then
    echo -e "${BLUE}TEST 6: Delete Product with FK Constraint${NC}"
    echo "==================================="
    echo -e "${YELLOW}(This tests the FK constraint handling)${NC}"

    curl -X DELETE \
      "${SUPABASE_URL}/rest/v1/products?id=eq.${FK_PRODUCT_ID}" \
      -H "apikey: ${SUPABASE_ANON_KEY}" \
      -H "Authorization: Bearer ${SUPABASE_JWT_TOKEN}" \
      -w "\nHTTP Status: %{http_code}\n"

    echo -e "${GREEN}Expected:${NC}"
    echo "- Before fix: HTTP 409 Conflict with FK constraint error"
    echo "- After fix: HTTP 204 No Content (success)"
    echo ""
fi

# ============================================================================
# TEST 7: Check for Orphaned Order Items
# ============================================================================
echo -e "${BLUE}TEST 7: Check for Orphaned Order Items${NC}"
echo "==================================="

curl -X GET \
  "${SUPABASE_URL}/rest/v1/order_items?select=id,product_id" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Accept: application/json" \
  -w "\nHTTP Status: %{http_code}\n" \
  | jq '.' 2>/dev/null || echo "Order items retrieved"

echo ""

# ============================================================================
# TEST 8: Batch Delete Test Products
# ============================================================================
echo -e "${BLUE}TEST 8: Clean Up Test Data${NC}"
echo "==================================="

curl -X DELETE \
  "${SUPABASE_URL}/rest/v1/products?category=eq.test" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_JWT_TOKEN}" \
  -w "\nHTTP Status: %{http_code}\n"

echo -e "${GREEN}Test data cleanup requested${NC}"
echo ""

# ============================================================================
# TEST 9: Test with JSON Request Body (Alternative Format)
# ============================================================================
echo -e "${BLUE}TEST 9: Alternative Format - Update Multiple Fields${NC}"
echo "==================================="
echo -e "${YELLOW}(Demonstrates updateing all product fields)${NC}"

curl -X PATCH \
  "${SUPABASE_URL}/rest/v1/products?id=eq.1" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "name": "Updated via cURL",
    "price": 299.99,
    "stock_quantity": 20,
    "category": "updated",
    "description": "Updated product",
    "is_active": true
  }' \
  -w "\nHTTP Status: %{http_code}\n"

echo ""

# ============================================================================
# DIAGNOSTIC INFORMATION
# ============================================================================
echo -e "${BLUE}DIAGNOSTIC INFORMATION${NC}"
echo "==================================="
echo "Configuration:"
echo "  Project URL: ${SUPABASE_URL}"
echo "  Anon Key: ${SUPABASE_ANON_KEY:0:20}..."
echo "  JWT Token: ${SUPABASE_JWT_TOKEN:0:20}..."
echo ""

echo "HTTP Status Codes (Expected):"
echo "  200 OK            - GET/SELECT successful"
echo "  201 Created       - POST/INSERT successful"
echo "  204 No Content    - DELETE successful"
echo "  400 Bad Request   - Malformed request"
echo "  401 Unauthorized  - Missing/invalid auth"
echo "  403 Forbidden     - RLS policy blocked"
echo "  404 Not Found     - Resource not found"
echo "  409 Conflict      - FK constraint / data conflict"
echo ""

echo "Common Error Codes:"
echo "  23503             - Foreign Key Constraint Violation"
echo "  42501             - RLS Policy Violation"
echo "  22000             - Data Exception"
echo ""

# ============================================================================
# VERBOSE DEBUG MODE
# ============================================================================
echo -e "${BLUE}VERBOSE DEBUG: Test Connection${NC}"
echo "==================================="
echo -e "${YELLOW}Send request to Supabase${NC}"

curl -v -X GET \
  "${SUPABASE_URL}/rest/v1/products?limit=1" \
  -H "apikey: ${SUPABASE_ANON_KEY}" 2>&1 | head -20

echo ""
echo -e "${GREEN}Connection test complete${NC}"

# ============================================================================
# HELPER: Generate JWT Token (if needed)
# ============================================================================
echo ""
echo -e "${BLUE}HELPER: Generate JWT Token${NC}"
echo "==================================="
echo "To authenticate, you may need a JWT token. Options:"
echo "1. Use Supabase Dashboard > Authentication > Users > Generate JWT"
echo "2. Use your service role key (server-side only)"
echo "3. Implement JWT generation in your app"
echo ""
echo "Example with curl and jq:"
echo "  curl -X POST 'https://YOUR_PROJECT.supabase.co/auth/v1/token' \\"
echo "    -H 'apikey: YOUR_ANON_KEY' \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"email\":\"user@example.com\",\"password\":\"password\"}'"
echo ""

# ============================================================================
# NOTES
# ============================================================================
echo -e "${BLUE}IMPORTANT NOTES${NC}"
echo "==================================="
echo "1. Replace placeholders (YOUR_PROJECT, YOUR_ANON_KEY, etc.)"
echo "2. Ensure Supabase RLS policies allow your operations"
echo "3. Check CORS settings if making requests from web app"
echo "4. For DELETE operations, JWT token may be required"
echo "5. Monitor Supabase logs for detailed error messages"
echo "6. Test with actual product IDs from your database"
echo ""

echo -e "${GREEN}✓ Test script complete!${NC}"
