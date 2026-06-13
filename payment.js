// Payment Page JavaScript
let orderData = null;
let paymentConfig = null;
let transactionScreenshot = null;

// Initialize payment page
document.addEventListener('DOMContentLoaded', async function() {
    // Wait for Supabase to initialize
    const client = await waitForSupabaseClient();
    
    if (!client) {
        showError('Failed to initialize payment system. Please try again.');
        return;
    }

    // Load order data
    loadOrderData();
    
    // Load payment configuration
    await loadPaymentConfiguration(client);
    
    // Setup payment confirmation checkbox
    document.getElementById('payment-confirmation').addEventListener('change', function() {
        document.getElementById('confirm-btn').disabled = !this.checked;
    });

    // Setup transaction screenshot preview
    const screenshotInput = document.getElementById('transaction-screenshot');
    if (screenshotInput) {
        screenshotInput.addEventListener('change', handleScreenshotPreview);
    }
});

// Wait for Supabase client to be initialized
function waitForSupabaseClient() {
    return new Promise((resolve) => {
        let attempts = 0;
        const checkInterval = setInterval(() => {
            if (window.supabaseClient) {
                clearInterval(checkInterval);
                resolve(window.supabaseClient);
            } else if (attempts > 20) {
                clearInterval(checkInterval);
                resolve(null);
            }
            attempts++;
        }, 100);
    });
}

// Load order data from session/local storage
function loadOrderData() {
    const stored = sessionStorage.getItem('orderData') || localStorage.getItem('orderData');
    if (!stored) {
        showError('No order data found. Please go back and try again.');
        return;
    }
    try {
        orderData = JSON.parse(stored);
        if (typeof fillCustomerForm === 'function') {
            fillCustomerForm(orderData);
        }
        displayOrderData();
    } catch (error) {
        console.error('Error parsing order data:', error);
        showError('Invalid order data. Please try again.');
    }
}

// Display order data
function displayOrderData() {
    if (!orderData) return;
    // Customer info now handled by form fields

    // Display order items
    // Fill customer info form fields
    function fillCustomerForm(orderData) {
        if (!orderData) return;
        var nameField = document.getElementById('customer-name');
        var phoneField = document.getElementById('customer-phone');
        var emailField = document.getElementById('customer-email');
        var streetField = document.getElementById('street-address');
        var cityField = document.getElementById('city');
        var dateField = document.getElementById('delivery-date');
        if (nameField) nameField.value = orderData.customer_name || '';
        if (phoneField) phoneField.value = orderData.customer_phone || '';
        if (emailField) emailField.value = orderData.customer_email || '';
        if (streetField) streetField.value = orderData.delivery_address || '';
        if (cityField) cityField.value = orderData.delivery_city || '';
        if (dateField) dateField.value = orderData.delivery_date || '';
    }
        // Validate required fields on confirm
        const confirmBtn = document.getElementById('confirm-btn');
        if (confirmBtn) {
            confirmBtn.addEventListener('click', function(e) {
                const name = document.getElementById('customer-name').value.trim();
                const phone = document.getElementById('customer-phone').value.trim();
                if (!name || !phone) {
                    e.preventDefault();
                    showError('Name and phone number are required.');
                    return false;
                }
            });
        }
    const itemsHtml = orderData.items.map(item => `
        <div class="order-item">
            <div class="order-item-name">${item.product_name}</div>
            <div class="order-item-qty">x${item.quantity}</div>
            <div class="order-item-price">Rs. ${(item.price * item.quantity).toFixed(2)}</div>
        </div>
    `).join('');

    document.getElementById('order-items').innerHTML = itemsHtml + `
        <div class="order-item" style="border-bottom: 1px solid #eee;">
            <span>Delivery Charge</span>
            <span>Rs. ${orderData.delivery_charge.toFixed(2)}</span>
        </div>
    `;

    // Display totals
    document.getElementById('total-amount').textContent = `Rs. ${orderData.total_amount.toFixed(2)}`;
    document.getElementById('summary-order-id').textContent = orderData.order_number;

    // Update amount references
    document.getElementById('esewa-amount').textContent = `Rs. ${orderData.total_amount.toFixed(2)}`;
    document.getElementById('khalti-amount').textContent = `Rs. ${orderData.total_amount.toFixed(2)}`;
    document.getElementById('bank-amount').textContent = `Rs. ${orderData.total_amount.toFixed(2)}`;
    document.getElementById('note-amount').textContent = `Rs. ${orderData.total_amount.toFixed(2)}`;
    document.getElementById('khalti-note-amount').textContent = `Rs. ${orderData.total_amount.toFixed(2)}`;
    document.getElementById('bank-note-amount').textContent = `Rs. ${orderData.total_amount.toFixed(2)}`;

    // Set reference numbers
    document.getElementById('esewa-ref').textContent = orderData.order_number;
    document.getElementById('khalti-ref').textContent = orderData.order_number;
    document.getElementById('bank-ref').textContent = orderData.order_number;
}

// Load payment configuration from admin
async function loadPaymentConfiguration(client) {
    try {
        const { data, error } = await client
            .from('payment_configuration')
            .select('*')
            .eq('is_active', true)
            .single();

        if (error) {
            console.error('Error loading payment config:', error);
            showWarning('Using default payment details. Please contact admin for correct details.');
            paymentConfig = getDefaultPaymentConfig();
        } else {
            paymentConfig = data || getDefaultPaymentConfig();
        }

        displayPaymentConfig();
    } catch (error) {
        console.error('Error loading payment configuration:', error);
        paymentConfig = getDefaultPaymentConfig();
        displayPaymentConfig();
    }
}

// Get default payment configuration
function getDefaultPaymentConfig() {
    return {
        esewa_number: '9847193358',
        esewa_name: 'Manisha Beauty Parlor',
        khalti_number: '9847193358',
        khalti_name: 'Manisha Beauty Parlor',
        bank_name: 'NIC ASIA BANK',
        bank_account: '1234567890123456',
        bank_holder: 'Manisha Beauty Parlor',
        bank_code: 'NICAASIA'
    };
}

// Display payment configuration
function displayPaymentConfig() {
    if (!paymentConfig) return;

    document.getElementById('esewa-number').textContent = paymentConfig.esewa_number || '9847193358';
    document.getElementById('khalti-number').textContent = paymentConfig.khalti_number || '9847193358';
    document.getElementById('bank-name').textContent = paymentConfig.bank_name || 'NIC ASIA BANK';
    document.getElementById('bank-account').textContent = paymentConfig.bank_account || '1234567890123456';
    document.getElementById('bank-holder').textContent = paymentConfig.bank_holder || 'Manisha Beauty Parlor';
}

// Show payment details
function showPaymentDetails(method) {
    // Hide all details
    document.getElementById('esewa-details').classList.remove('active');
    document.getElementById('khalti-details').classList.remove('active');
    document.getElementById('bank-details').classList.remove('active');

    // Show selected method
    if (method === 'esewa') {
        document.getElementById('esewa-details').classList.add('active');
    } else if (method === 'khalti') {
        document.getElementById('khalti-details').classList.add('active');
    } else if (method === 'bank') {
        document.getElementById('bank-details').classList.add('active');
    }
}

// Copy to clipboard
function copyToClipboard(elementId) {
    const element = document.getElementById(elementId);
    const text = element.textContent;
    
    navigator.clipboard.writeText(text).then(() => {
        const btn = event.target;
        const originalText = btn.textContent;
        btn.textContent = '✓ Copied!';
        setTimeout(() => {
            btn.textContent = originalText;
        }, 2000);
    }).catch(err => {
        console.error('Failed to copy:', err);
        alert('Failed to copy. Please try manually.');
    });
}

// Handle transaction screenshot preview
function handleScreenshotPreview(e) {
    const file = e.target.files[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('image/')) {
        showError('Please upload an image file');
        e.target.value = '';
        return;
    }

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
        showError('File size must be less than 5MB');
        e.target.value = '';
        return;
    }

    // Read and display preview
    const reader = new FileReader();
    reader.onload = function(event) {
        transactionScreenshot = {
            file: file,
            dataUrl: event.target.result,
            name: file.name
        };

        const preview = document.getElementById('screenshot-preview');
        const img = document.getElementById('screenshot-img');
        img.src = event.target.result;
        preview.classList.add('active');
    };
    reader.readAsDataURL(file);
}

// Validate transaction fields
function validateTransactionFields() {
    const code = document.getElementById('transaction-code').value.trim();
    const screenshot = document.getElementById('transaction-screenshot').files[0];

    if (!code) {
        showError('Please enter transaction code');
        return false;
    }

    if (!screenshot) {
        showError('Please upload transaction screenshot');
        return false;
    }

    if (!transactionScreenshot) {
        showError('Screenshot preview failed to load');
        return false;
    }

    return true;
}

// Validate address fields
function validateAddressFields() {
    const street = document.getElementById('street-address').value.trim();
    const city = document.getElementById('city').value.trim();
    const date = document.getElementById('delivery-date').value.trim();

    if (!street || !city || !date) {
        showError('Please fill in all required address fields (Street, City, and Delivery Date)');
        return false;
    }

    return true;
}

// Get transaction data
async function getTransactionData(client) {
    const code = document.getElementById('transaction-code').value.trim();
    const screenshot = document.getElementById('transaction-screenshot').files[0];
    const notes = document.getElementById('transaction-notes').value.trim();

    if (!screenshot || !transactionScreenshot) {
        throw new Error('Screenshot not ready');
    }

    // Upload screenshot to Supabase storage
    const fileName = `${Date.now()}_${transactionScreenshot.name}`;
    console.log('📤 Uploading screenshot:', fileName);
    
    const { data: uploadData, error: uploadError } = await client
        .storage
        .from('transaction-screenshots')
        .upload(`screenshots/${fileName}`, screenshot);

    if (uploadError) {
        console.error('❌ Upload error:', uploadError);
        throw new Error(`Failed to upload screenshot: ${uploadError.message}`);
    }

    console.log('✅ Screenshot uploaded successfully');

    // Get public URL
    const { data: publicUrlData } = client
        .storage
        .from('transaction-screenshots')
        .getPublicUrl(`screenshots/${fileName}`);

    const publicUrl = publicUrlData?.publicUrl || '';
    console.log('🔗 Public URL generated:', publicUrl);

    return {
        transaction_code: code,
        screenshot_url: publicUrl,
        screenshot_filename: fileName,
        notes: notes
    };
}

// Get address data
function getAddressData() {
    return {
        street_address: document.getElementById('street-address').value.trim(),
        city: document.getElementById('city').value.trim(),
        state: document.getElementById('state').value.trim(),
        postal_code: document.getElementById('postal-code').value.trim(),
        delivery_instructions: document.getElementById('delivery-instructions').value.trim()
    };
}

// Confirm payment
async function confirmPayment() {
    const selectedMethod = document.querySelector('input[name="payment-method"]:checked');
    
    if (!selectedMethod) {
        showError('Please select a payment method');
        return;
    }

    if (!orderData) {
        showError('Order data not found. Please try again.');
        return;
    }

    // Validate transaction fields
    if (!validateTransactionFields()) {
        return;
    }

    // Validate address fields
    if (!validateAddressFields()) {
        return;
    }

    const paymentMethod = selectedMethod.value;

    try {
        document.getElementById('payment-loader').style.display = 'block';
        document.getElementById('confirm-btn').disabled = true;

        const client = window.supabaseClient;
        if (!client) {
            throw new Error('Supabase client not initialized');
        }

        // Generate a unique order number (include timestamp to avoid duplicates)
        const uniqueOrderNumber = `ORD-${Date.now()}-${Math.floor(Math.random() * 10000)}`;

        // Get latest customer info from form
        const customerName = document.getElementById('customer-name').value.trim();
        const customerPhone = document.getElementById('customer-phone').value.trim();
        const customerEmail = document.getElementById('customer-email').value.trim();
        const deliveryDate = document.getElementById('delivery-date').value;
        const deliveryAddress = document.getElementById('street-address').value.trim();

        // Update orderData with latest info
        orderData.customer_name = customerName;
        orderData.customer_phone = customerPhone;
        orderData.customer_email = customerEmail;
        orderData.delivery_date = deliveryDate;
        orderData.delivery_address = deliveryAddress;

        // Get transaction data
        const transactionData = await getTransactionData(client);
        const addressData = getAddressData();

        // Create order in database
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
                transaction_screenshot: transactionData.screenshot_url
            }])
            .select()
            .single();

        if (orderError) throw orderError;

        const orderId = orderInsert.id;

        // Save order items
        const orderItems = orderData.items.map(item => ({
            order_id: orderId,
            product_id: item.product_id,
            product_name: item.product_name,
            quantity: item.quantity,
            price: item.price
        }));

        const { error: itemsError } = await client
            .from('order_items')
            .insert(orderItems);

        if (itemsError) throw itemsError;

        // Store updated order data with payment method and ID
        const updatedOrderData = {
            ...orderData,
            payment_method: paymentMethod,
            order_id: orderId,
            status: 'pending_verification',
            transaction_code: transactionData.transaction_code,
            transaction_screenshot: transactionData.screenshot_url,
            customer_phone: orderData.customer_phone,
            order_number: uniqueOrderNumber,
            delivery_charge: orderData.delivery_charge,
            items: orderData.items
        };

        // Debug logging
        console.log('✅ Order created successfully:', {
            order_id: orderId,
            order_number: uniqueOrderNumber,
            transaction_code: transactionData.transaction_code,
            transaction_screenshot: transactionData.screenshot_url,
            screenshot_filename: transactionData.screenshot_filename
        });

        sessionStorage.setItem('orderData', JSON.stringify(updatedOrderData));
        localStorage.setItem('orderData', JSON.stringify(updatedOrderData));

        // Send email to customer
        console.log('📧 Sending email notifications for order:', uniqueOrderNumber);
        if (typeof sendNewOrderEmail === 'function') {
            await sendNewOrderEmail(updatedOrderData);
        }
        
        // Send email to admin
        if (typeof sendNewOrderEmailToAdmin === 'function') {
            await sendNewOrderEmailToAdmin(updatedOrderData);
        }

        // Show success message
        document.getElementById('payment-loader').style.display = 'none';
        document.getElementById('order-id').textContent = uniqueOrderNumber;
        document.getElementById('success-message').style.display = 'block';

        // Redirect to invoice after 3 seconds
        setTimeout(() => {
            window.location.href = 'invoice.html';
        }, 3000);

    } catch (error) {
        console.error('Error confirming payment:', error);
        showError(`Payment confirmation failed: ${error.message}`);
        document.getElementById('payment-loader').style.display = 'none';
        document.getElementById('confirm-btn').disabled = false;
    }
}

// Go back to orders
function goBackToOrders() {
    if (confirm('Are you sure? Your order data will be cleared.')) {
        sessionStorage.removeItem('orderData');
        localStorage.removeItem('orderData');
        window.location.href = 'orders.html';
    }
}

// Show error message
function showError(message) {
    const errorDiv = document.getElementById('error-message');
    errorDiv.textContent = '⚠️ ' + message;
    errorDiv.style.display = 'block';
    setTimeout(() => {
        errorDiv.style.display = 'none';
    }, 5000);
}

// Show warning message
function showWarning(message) {
    const errorDiv = document.getElementById('error-message');
    errorDiv.textContent = '⚠️ ' + message;
    errorDiv.style.display = 'block';
    errorDiv.style.background = '#fff3cd';
    errorDiv.style.color = '#856404';
    errorDiv.style.borderColor = '#ffeaa7';
}
