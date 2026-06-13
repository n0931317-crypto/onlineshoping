// Supabase Configuration - Clean initialization
// NOTE: Update these with your actual Supabase project credentials
// Get these from: https://app.supabase.com/project/[your-project]/settings/api
const SUPABASE_URL = 'https://solffnnevevczgysxdkw.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvbGZmbm5ldmV2Y3pneXN4ZGt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDg4MzcsImV4cCI6MjA5NjkyNDgzN30.5ko-2SI69J3fbp-TPq5_Rd0IypFea29_fHh1cf6TQJ0';

// EmailJS Configuration
const EMAILJS_SERVICE_ID = 'service_dmgtj5n'; // Replace with your service ID
const EMAILJS_TEMPLATE_ID = 'template_zw2605w'; // Replace with your template ID
const EMAILJS_PUBLIC_KEY = 'x4HoJf_vf3TNpEbhD'; // Replace with your public key

// Initialize Supabase client (global scope)
window.supabaseClient = null;

// Initialize EmailJS
function initializeEmailJS() {
    try {
        if (window.emailjs) {
            emailjs.init(EMAILJS_PUBLIC_KEY);
            console.log('✅ EmailJS initialized successfully');
        }
    } catch (err) {
        console.error('⚠️ EmailJS initialization issue:', err);
    }
}

function initializeSupabase() {
    if (!window.supabaseClient && window.supabase) {
        try {
            window.supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
            console.log('✅ Supabase client initialized successfully');
            initializeEmailJS(); // Initialize EmailJS when Supabase is ready
            return true;
        } catch (err) {
            console.error('❌ Failed to initialize Supabase:', err);
            return false;
        }
    }
    return !!window.supabaseClient;
}

// Try to initialize Supabase immediately when script loads
if (window.supabase) {
    console.log('⏳ Supabase library detected, initializing...');
    initializeSupabase();
} else {
    console.warn('⚠️ Supabase library not yet loaded');
}

// Also try on DOMContentLoaded as fallback
document.addEventListener('DOMContentLoaded', function() {
    if (!window.supabaseClient) {
        console.log('⏳ DOMContentLoaded: Attempting Supabase initialization...');
        setTimeout(initializeSupabase, 100);
    }
});

// Helper function to get client with error handling
function getClient() {
    const client = window.supabaseClient;
    if (!client && window.supabase) {
        // Try to initialize if library loaded but client not created
        console.warn('⚠️ Supabase client not ready, attempting initialization...');
        initializeSupabase();
        return window.supabaseClient;
    }
    if (!client) {
        console.error('❌ Supabase client not initialized');
        return null;
    }
    return client;
}

// ============================================================
// DASHBOARD STATS
// ============================================================

async function fetchDashboardStats() {
    try {
        const client = getClient();
        if (!client) {
            return {
                todayAppointments: 0,
                totalServices: 0,
                totalProducts: 0,
                pendingOrders: 0,
                todayRevenue: 0
            };
        }

        // Get services count
        const { count: servicesCount, error: servError } = await client
            .from('services')
            .select('id', { count: 'exact', head: true });

        if (servError) console.warn('Services count error:', servError.message);

        // Get products count
        const { count: productsCount, error: prodError } = await client
            .from('products')
            .select('id', { count: 'exact', head: true });

        if (prodError) console.warn('Products count error:', prodError.message);

        // Get today's appointments
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);

        const { data: appointments, error: apptError } = await client
            .from('appointments')
            .select('*')
            .gte('appointment_date', today.toISOString())
            .lt('appointment_date', tomorrow.toISOString())
            .neq('status', 'cancelled');

        if (apptError) console.warn('Appointments error:', apptError.message);

        // Get pending orders
        const { count: ordersCount, error: ordersError } = await client
            .from('orders')
            .select('id', { count: 'exact', head: true })
            .eq('status', 'pending_verification');

        if (ordersError) console.warn('Orders count error:', ordersError.message);

        // Calculate today's revenue from orders
        const { data: todayOrders, error: revenueError } = await client
            .from('orders')
            .select('total_amount')
            .gte('created_at', today.toISOString())
            .lt('created_at', tomorrow.toISOString())
            .neq('status', 'cancelled');

        let todayRevenue = 0;
        if (todayOrders && todayOrders.length > 0) {
            todayRevenue = todayOrders.reduce((sum, order) => sum + (order.total_amount || 0), 0);
        }

        console.log('✅ Dashboard stats:', {
            appointments: appointments?.length || 0,
            services: servicesCount || 0,
            products: productsCount || 0,
            orders: ordersCount || 0,
            revenue: todayRevenue
        });

        return {
            todayAppointments: appointments ? appointments.length : 0,
            totalServices: servicesCount || 0,
            totalProducts: productsCount || 0,
            pendingOrders: ordersCount || 0,
            todayRevenue: todayRevenue
        };
    } catch (error) {
        console.error('❌ Dashboard stats error:', error);
        return {
            todayAppointments: 0,
            totalServices: 0,
            totalProducts: 0,
            pendingOrders: 0,
            todayRevenue: 0
        };
    }
}

// ============================================================
// SERVICES
// ============================================================

async function fetchServices() {
    try {
        const client = getClient();
        if (!client) return [];

        const { data, error } = await client
            .from('services')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) {
            console.error('❌ Fetch services error:', error.message);
            return [];
        }
        console.log('✅ Fetched services:', data?.length || 0);
        return data || [];
    } catch (error) {
        console.error('❌ Fetch services exception:', error);
        return [];
    }
}

async function saveService(service) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        if (service.id) {
            const { data, error } = await client
                .from('services')
                .update(service)
                .eq('id', service.id)
                .select();
            if (error) throw error;
            console.log('✅ Service updated');
            return data ? data[0] : null;
        } else {
            const { data, error } = await client
                .from('services')
                .insert([service])
                .select();
            if (error) throw error;
            console.log('✅ Service created');
            return data ? data[0] : null;
        }
    } catch (error) {
        console.error('❌ Save service error:', error);
        throw error;
    }
}

async function deleteService(id) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        const { error } = await client
            .from('services')
            .delete()
            .eq('id', id);

        if (error) throw error;
        console.log('✅ Service deleted');
    } catch (error) {
        console.error('❌ Delete service error:', error);
        throw error;
    }
}

// ============================================================
// PRODUCTS
// ============================================================

async function fetchProducts() {
    try {
        const client = getClient();
        if (!client) return [];

        const { data, error } = await client
            .from('products')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) {
            console.error('❌ Fetch products error:', error.message);
            return [];
        }
        console.log('✅ Fetched products:', data?.length || 0);
        return data || [];
    } catch (error) {
        console.error('❌ Fetch products exception:', error);
        return [];
    }
}

async function saveProduct(product) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        if (product.id) {
            const { data, error } = await client
                .from('products')
                .update(product)
                .eq('id', product.id)
                .select();
            if (error) throw error;
            console.log('✅ Product updated');
            return data ? data[0] : null;
        } else {
            const { data, error } = await client
                .from('products')
                .insert([product])
                .select();
            if (error) throw error;
            console.log('✅ Product created');
            return data ? data[0] : null;
        }
    } catch (error) {
        console.error('❌ Save product error:', error);
        throw error;
    }
}

async function deleteProduct(id) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        const { error } = await client
            .from('products')
            .delete()
            .eq('id', id);

        if (error) throw error;
        console.log('✅ Product deleted');
    } catch (error) {
        console.error('❌ Delete product error:', error);
        throw error;
    }
}

// ============================================================
// GALLERY
// ============================================================

async function fetchGallery() {
    try {
        const client = getClient();
        if (!client) return [];

        const { data, error } = await client
            .from('gallery')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) {
            console.error('❌ Fetch gallery error:', error.message);
            return [];
        }
        console.log('✅ Fetched gallery items:', data?.length || 0);
        return data || [];
    } catch (error) {
        console.error('❌ Fetch gallery exception:', error);
        return [];
    }
}

async function saveGalleryItem(item) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        const { data, error } = await client
            .from('gallery')
            .insert([item])
            .select();

        if (error) throw error;
        console.log('✅ Gallery item added');
        return data ? data[0] : null;
    } catch (error) {
        console.error('❌ Save gallery error:', error);
        throw error;
    }
}

async function deleteGalleryItem(id) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        const { error } = await client
            .from('gallery')
            .delete()
            .eq('id', id);

        if (error) throw error;
        console.log('✅ Gallery item deleted');
    } catch (error) {
        console.error('❌ Delete gallery error:', error);
        throw error;
    }
}

// ============================================================
// APPOINTMENTS
// ============================================================

async function fetchAppointments(date = null, status = 'all') {
    try {
        const client = getClient();
        if (!client) {
            console.error('❌ Supabase client not available');
            return [];
        }

        let query = client.from('appointments').select('*, services(id, title, price)');

        // Filter by date if provided
        if (date) {
            const selectedDate = new Date(date + 'T00:00:00Z');
            const nextDate = new Date(selectedDate);
            nextDate.setDate(nextDate.getDate() + 1);
            
            const startISO = selectedDate.toISOString().split('T')[0];
            const endISO = nextDate.toISOString().split('T')[0];
            
            console.log('Filtering appointments for date:', startISO, 'to', endISO);
            
            query = query
                .gte('appointment_date', startISO)
                .lt('appointment_date', endISO);
        }
        
        // Filter by status if specified
        if (status && status !== 'all') {
            console.log('Filtering appointments by status:', status);
            query = query.eq('status', status);
        }

        const { data, error } = await query.order('appointment_date', { ascending: true });

        if (error) {
            console.error('❌ Fetch appointments error:', error);
            return [];
        }
        
        console.log('✅ Fetched appointments:', data?.length || 0, 'appointments');
        if (data && data.length > 0) {
            console.log('Sample appointment:', data[0]);
        }
        return data || [];
    } catch (error) {
        console.error('❌ Fetch appointments exception:', error);
        return [];
    }
}

async function saveAppointment(appointment) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        const { data, error } = await client
            .from('appointments')
            .insert([appointment])
            .select();

        if (error) throw error;
        console.log('✅ Appointment created');
        return data ? data[0] : null;
    } catch (error) {
        console.error('❌ Save appointment error:', error);
        throw error;
    }
}

async function updateAppointmentStatus(id, status) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        const { data, error } = await client
            .from('appointments')
            .update({ status })
            .eq('id', id)
            .select();

        if (error) throw error;
        console.log('✅ Appointment status updated');
        return data ? data[0] : null;
    } catch (error) {
        console.error('❌ Update appointment error:', error);
        throw error;
    }
}

async function deleteAppointment(id) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        const { error } = await client
            .from('appointments')
            .delete()
            .eq('id', id);

        if (error) throw error;
        console.log('✅ Appointment deleted');
    } catch (error) {
        console.error('❌ Delete appointment error:', error);
        throw error;
    }
}

// ============================================================
// SETTINGS
// ============================================================

async function getSetting(key) {
    try {
        const client = getClient();
        if (!client) return null;

        const { data, error } = await client
            .from('settings')
            .select('*')
            .eq('setting_key', key);

        if (error) {
            console.warn('⚠️ Get setting error:', error.message);
            return null;
        }
        return data ? data[0] : null;
    } catch (error) {
        console.error('❌ Get setting exception:', error);
        return null;
    }
}

async function saveSetting(key, value) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        const { data, error } = await client
            .from('settings')
            .upsert([{ setting_key: key, setting_value: value, updated_at: new Date().toISOString() }], { onConflict: 'setting_key' })
            .select();

        if (error) throw error;
        console.log('✅ Setting saved');
        return data ? data[0] : null;
    } catch (error) {
        console.error('❌ Save setting error:', error);
        throw error;
    }
}

// ============================================================
// FILE UPLOAD
// ============================================================

async function uploadFile(file, bucket = 'gallery') {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        const fileExt = file.name.split('.').pop();
        const fileName = `${Date.now()}-${Math.random().toString(36).substring(2)}.${fileExt}`;

        const { data, error } = await client.storage
            .from(bucket)
            .upload(fileName, file, {
                cacheControl: '3600',
                upsert: false
            });

        if (error) throw error;

        const { data: { publicUrl } } = client.storage
            .from(bucket)
            .getPublicUrl(fileName);

        console.log('✅ File uploaded:', publicUrl);
        return publicUrl;
    } catch (error) {
        console.error('❌ File upload error:', error);
        throw error;
    }
}

// ============================================================
// ORDERS MANAGEMENT
// ============================================================

async function fetchOrders(status = null) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        let query = client
            .from('orders')
            .select('*');

        if (status) {
            query = query.eq('status', status);
        }

        const { data, error } = await query.order('created_at', { ascending: false });

        if (error) throw error;

        console.log('✅ Fetched orders:', data?.length || 0);
        return data || [];
    } catch (error) {
        console.error('❌ Fetch orders error:', error);
        return [];
    }
}

async function fetchOrderItems(orderId) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        const { data, error } = await client
            .from('order_items')
            .select('*')
            .eq('order_id', orderId)
            .order('created_at', { ascending: false });

        if (error) throw error;

        console.log('✅ Fetched order items:', data?.length || 0);
        return data || [];
    } catch (error) {
        console.error('❌ Fetch order items error:', error);
        return [];
    }
}

async function saveOrder(orderData) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        let query;
        if (orderData.id) {
            // Update existing order
            query = client
                .from('orders')
                .update(orderData)
                .eq('id', orderData.id)
                .select();
        } else {
            // Create new order
            query = client
                .from('orders')
                .insert([orderData])
                .select();
        }

        const { data, error } = await query;

        if (error) throw error;

        console.log('✅ Order saved:', data?.[0]);
        return data?.[0];
    } catch (error) {
        console.error('❌ Save order error:', error);
        throw error;
    }
}

async function saveOrderItem(itemData) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        const { data, error } = await client
            .from('order_items')
            .insert([itemData])
            .select();

        if (error) throw error;

        console.log('✅ Order item saved');
        return data?.[0];
    } catch (error) {
        console.error('❌ Save order item error:', error);
        throw error;
    }
}

async function updateOrderStatus(orderId, status) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        const { data, error } = await client
            .from('orders')
            .update({ status: status })
            .eq('id', orderId)
            .select();

        if (error) throw error;

        console.log('✅ Order status updated:', status);
        return data?.[0];
    } catch (error) {
        console.error('❌ Update order status error:', error);
        throw error;
    }
}

async function deleteOrder(orderId) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase client not initialized');

        // Delete order items first
        const { error: itemsError } = await client
            .from('order_items')
            .delete()
            .eq('order_id', orderId);

        if (itemsError) throw itemsError;

        // Delete order
        const { error } = await client
            .from('orders')
            .delete()
            .eq('id', orderId);

        if (error) throw error;

        console.log('✅ Order deleted');
        return true;
    } catch (error) {
        console.error('❌ Delete order error:', error);
        throw error;
    }
}

// ============================================================
// EMAIL NOTIFICATIONS
// ============================================================

const ADMIN_EMAIL = 'diwashb32@gmail.com';

// Send email to user for new order
async function sendNewOrderEmail(orderData) {
    try {
        console.log('📧 Sending new order email to:', orderData.customer_email);
        
        const emailContent = `
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f5f5f5; padding: 20px; }
        .container { background-color: white; padding: 30px; border-radius: 8px; max-width: 600px; margin: 0 auto; }
        .header { color: #333; border-bottom: 2px solid #ff6b8b; padding-bottom: 20px; margin-bottom: 20px; }
        .order-details { background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .item { padding: 10px 0; border-bottom: 1px solid #eee; }
        .total { font-size: 18px; font-weight: bold; color: #ff6b8b; margin-top: 20px; }
        .footer { color: #666; font-size: 12px; margin-top: 30px; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>✅ Order Confirmed!</h2>
            <p>Your order has been successfully placed.</p>
        </div>
        
        <div>
            <h3>Order Details</h3>
            <p><strong>Order ID:</strong> ${orderData.order_number}</p>
            <p><strong>Date:</strong> ${new Date().toLocaleDateString()}</p>
            <p><strong>Status:</strong> Pending Payment Verification</p>
        </div>
        
        <div class="order-details">
            <h4>Items Ordered:</h4>
            ${orderData.items.map(item => `
                <div class="item">
                    <strong>${item.product_name}</strong><br>
                    Quantity: ${item.quantity} × ₹${item.price} = <strong>₹${(item.price * item.quantity).toFixed(2)}</strong>
                </div>
            `).join('')}
            <div class="item" style="border-bottom: 2px solid #ff6b8b;">
                <strong>Delivery Charge:</strong> ₹${orderData.delivery_charge.toFixed(2)}
            </div>
        </div>
        
        <div class="total">
            <p>Total Amount: ₹${orderData.total_amount.toFixed(2)}</p>
        </div>
        
        <div style="margin-top: 30px; padding: 20px; background-color: #fff3cd; border-left: 4px solid #ffc107; border-radius: 4px;">
            <strong>⏳ Next Steps:</strong>
            <p>Please transfer the amount to the provided account details and upload the transaction screenshot.</p>
            <p>Your order will be confirmed once we verify your payment.</p>
        </div>
        
        <div style="margin-top: 20px;">
            <p><strong>Delivery Address:</strong><br>${orderData.delivery_address}</p>
            <p><strong>Contact:</strong> ${orderData.customer_phone}</p>
        </div>
        
        <div class="footer">
            <p>Thank you for shopping at Nepo Online stores & Cosmetic Center!</p>
            <p>Phone: 033590207 | Email: nepoonline0@gmail.com</p>
        </div>
    </div>
</body>
</html>
        `;
        
        // Log the email (in production, use EmailJS or backend service)
        console.log('✅ Order email generated for:', orderData.customer_email);
        
        // Call EmailJS or your email service here
        await sendEmailViaService({
            to: orderData.customer_email,
            subject: `Order Confirmation - ${orderData.order_number}`,
            html: emailContent
        });
        
        return true;
    } catch (error) {
        console.error('❌ Error sending order email:', error);
        return false;
    }
}

// Send email to user for order status update
async function sendOrderUpdateEmail(orderData, newStatus) {
    try {
        console.log('📧 Sending order update email to:', orderData.customer_email);
        
        let statusMessage = '';
        let statusColor = '#667eea';
        
        switch(newStatus) {
            case 'payment_verified':
                statusMessage = 'Your payment has been verified! Your order is being prepared.';
                statusColor = '#28a745';
                break;
            case 'shipped':
                statusMessage = 'Your order has been shipped! Track it using your order ID.';
                statusColor = '#17a2b8';
                break;
            case 'delivered':
                statusMessage = 'Your order has been delivered! Thank you for your purchase.';
                statusColor = '#ffc107';
                break;
            case 'cancelled':
                statusMessage = 'Your order has been cancelled. Please contact us for more information.';
                statusColor = '#dc3545';
                break;
            default:
                statusMessage = `Your order status has been updated to: ${newStatus}`;
        }
        
        const emailContent = `
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f5f5f5; padding: 20px; }
        .container { background-color: white; padding: 30px; border-radius: 8px; max-width: 600px; margin: 0 auto; }
        .status-banner { background-color: ${statusColor}; color: white; padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 20px; }
        .details { background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .footer { color: #666; font-size: 12px; margin-top: 30px; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <div class="status-banner">
            <h2>${statusMessage}</h2>
        </div>
        
        <div class="details">
            <h3>Order Information</h3>
            <p><strong>Order ID:</strong> ${orderData.order_number}</p>
            <p><strong>Status:</strong> ${newStatus.toUpperCase().replace('_', ' ')}</p>
            <p><strong>Total Amount:</strong> ₹${orderData.total_amount.toFixed(2)}</p>
            <p><strong>Delivery Address:</strong> ${orderData.delivery_address}</p>
        </div>
        
        ${newStatus === 'cancelled' ? `
            <div style="background-color: #f8d7da; border-left: 4px solid #dc3545; padding: 15px; border-radius: 4px;">
                <p>If you have any questions about the cancellation, please contact us at nepoonline0@gmail.com or call 033590207.</p>
            </div>
        ` : ''}
        
        <div class="footer">
            <p>Nepo Online stores & Cosmetic Center</p>
            <p>Phone: 033590207 | Email: nepoonline0@gmail.com</p>
        </div>
    </div>
</body>
</html>
        `;
        
        await sendEmailViaService({
            to: orderData.customer_email,
            subject: `Order Update - ${orderData.order_number}`,
            html: emailContent
        });
        
        return true;
    } catch (error) {
        console.error('❌ Error sending order update email:', error);
        return false;
    }
}

// Send email to admin for new appointment
async function sendNewAppointmentEmailToAdmin(appointmentData) {
    try {
        console.log('📧 Sending appointment notification to admin:', ADMIN_EMAIL);
        
        const emailContent = `
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f5f5f5; padding: 20px; }
        .container { background-color: white; padding: 30px; border-radius: 8px; max-width: 600px; margin: 0 auto; }
        .header { background-color: #667eea; color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .details { background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .action-btn { display: inline-block; padding: 10px 20px; background-color: #ff6b8b; color: white; text-decoration: none; border-radius: 5px; margin-top: 15px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>📅 New Appointment Booking</h2>
            <p>You have received a new appointment booking.</p>
        </div>
        
        <div class="details">
            <h3>Customer Details</h3>
            <p><strong>Name:</strong> ${appointmentData.customer_name}</p>
            <p><strong>Phone:</strong> ${appointmentData.customer_phone}</p>
            <p><strong>Email:</strong> ${appointmentData.customer_email || 'Not provided'}</p>
        </div>
        
        <div class="details">
            <h3>Appointment Details</h3>
            <p><strong>Service:</strong> ${appointmentData.service_name}</p>
            <p><strong>Date:</strong> ${new Date(appointmentData.appointment_date).toLocaleDateString()}</p>
            <p><strong>Time:</strong> ${appointmentData.appointment_time}</p>
            <p><strong>Status:</strong> Pending</p>
            ${appointmentData.requirements ? `<p><strong>Special Requirements:</strong> ${appointmentData.requirements}</p>` : ''}
        </div>
        
        <p><a href="http://localhost:3000/admin.html" class="action-btn">View in Admin Panel</a></p>
        
        <div style="margin-top: 20px; padding: 15px; background-color: #e7f3ff; border-left: 4px solid #2196F3; border-radius: 4px;">
            <p><strong>Action Required:</strong> Please confirm or reject this appointment in your admin panel.</p>
        </div>
    </div>
</body>
</html>
        `;
        
        await sendEmailViaService({
            to: ADMIN_EMAIL,
            subject: `New Appointment Booking - ${appointmentData.customer_name}`,
            html: emailContent
        });
        
        return true;
    } catch (error) {
        console.error('❌ Error sending appointment email:', error);
        return false;
    }
}

// Send email to admin for new order
async function sendNewOrderEmailToAdmin(orderData) {
    try {
        console.log('📧 Sending new order notification to admin:', ADMIN_EMAIL);
        
        const emailContent = `
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f5f5f5; padding: 20px; }
        .container { background-color: white; padding: 30px; border-radius: 8px; max-width: 600px; margin: 0 auto; }
        .header { background-color: #667eea; color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .details { background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .item { padding: 10px 0; border-bottom: 1px solid #eee; }
        .total { font-size: 18px; font-weight: bold; color: #ff6b8b; margin-top: 15px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>🛍️ New Order Received</h2>
            <p>A new product order has been placed on your store.</p>
        </div>
        
        <div class="details">
            <h3>Customer Details</h3>
            <p><strong>Name:</strong> ${orderData.customer_name}</p>
            <p><strong>Phone:</strong> ${orderData.customer_phone}</p>
            <p><strong>Email:</strong> ${orderData.customer_email}</p>
            <p><strong>Address:</strong> ${orderData.delivery_address}</p>
        </div>
        
        <div class="details">
            <h3>Order Details</h3>
            <p><strong>Order ID:</strong> ${orderData.order_number}</p>
            <p><strong>Date:</strong> ${new Date().toLocaleDateString()}</p>
            <p><strong>Status:</strong> Pending Payment Verification</p>
            
            <h4 style="margin-top: 15px;">Items:</h4>
            ${orderData.items.map(item => `
                <div class="item">
                    <strong>${item.product_name}</strong> (Qty: ${item.quantity}) - ₹${(item.price * item.quantity).toFixed(2)}
                </div>
            `).join('')}
            
            <div class="total">
                Total: ₹${orderData.total_amount.toFixed(2)} (Including ₹${orderData.delivery_charge.toFixed(2)} delivery)
            </div>
        </div>
        
        <div style="margin-top: 20px; padding: 15px; background-color: #fff3cd; border-left: 4px solid #ffc107; border-radius: 4px;">
            <p><strong>⏳ Payment Status:</strong> Pending verification</p>
            <p>Waiting for customer to submit payment proof. Check the admin panel for payment verification.</p>
        </div>
    </div>
</body>
</html>
        `;
        
        await sendEmailViaService({
            to: ADMIN_EMAIL,
            subject: `New Order - ${orderData.order_number} from ${orderData.customer_name}`,
            html: emailContent
        });
        
        return true;
    } catch (error) {
        console.error('❌ Error sending order notification:', error);
        return false;
    }
}

// Generic email sending function (can be replaced with EmailJS or backend service)
async function sendEmailViaService(emailData) {
    try {
        // Using EmailJS (client-side)
        if (typeof emailjs !== 'undefined' && EMAILJS_SERVICE_ID && EMAILJS_TEMPLATE_ID) {
            try {
                const response = await emailjs.send(EMAILJS_SERVICE_ID, EMAILJS_TEMPLATE_ID, {
                    to_email: emailData.to,
                    customer_email: emailData.to,
                    customer_name: emailData.customerName || 'Customer',
                    subject: emailData.subject,
                    email_subject: emailData.subject,
                    message: emailData.html,
                    email_body: emailData.html,
                    html_content: emailData.html
                });
                console.log('✅ Email sent via EmailJS:', response);
                return true;
            } catch (emailJsError) {
                console.error('⚠️ EmailJS error:', emailJsError);
                return false;
            }
        }
        
        // If running on file:// protocol, skip backend API (it won't work)
        if (window.location.protocol === 'file:') {
            console.warn('⚠️ Running on file:// protocol - email service not available. Use a local web server to enable email notifications.');
            console.warn('   Suggestion: Use "npx http-server" or "python -m http.server" to run locally');
            return false;
        }
        
        // Option 2: Using a backend API endpoint (only for http/https)
        try {
            const response = await fetch('/api/send-email', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    to: emailData.to,
                    subject: emailData.subject,
                    html: emailData.html,
                    customerName: emailData.customerName
                })
            });
            
            if (response.ok) {
                console.log('✅ Email sent via backend API');
                return true;
            }
        } catch (fetchError) {
            console.warn('⚠️ Backend API not available:', fetchError.message);
        }
        
        console.warn('⚠️ Email service not configured. In production, set up EmailJS or backend email service.');
        return false;
    } catch (error) {
        console.error('❌ Error sending email:', error);
        return false;
    }
}

// ============================================================
// REVIEWS MANAGEMENT
// ============================================================

/**
 * Fetch all approved reviews for a product
 */
async function fetchProductReviews(productId) {
    try {
        const client = getClient();
        if (!client) return [];

        const { data, error } = await client
            .from('reviews')
            .select('*')
            .eq('product_id', productId)
            .eq('status', 'approved')
            .order('created_at', { ascending: false });

        if (error) {
            console.error('❌ Fetch reviews error:', error);
            return [];
        }

        console.log('✅ Fetched reviews for product:', productId, 'Count:', data?.length || 0);
        return data || [];
    } catch (error) {
        console.error('❌ Fetch reviews exception:', error);
        return [];
    }
}

/**
 * Fetch all reviews (admin - for moderation)
 */
async function fetchAllReviews(status = null) {
    try {
        const client = getClient();
        if (!client) return [];

        let query = client
            .from('reviews')
            .select('*');

        if (status) {
            query = query.eq('status', status);
        }

        const { data, error } = await query
            .order('created_at', { ascending: false });

        if (error) {
            console.error('❌ Fetch all reviews error:', error);
            return [];
        }

        console.log('✅ Fetched all reviews. Count:', data?.length || 0);
        return data || [];
    } catch (error) {
        console.error('❌ Fetch all reviews exception:', error);
        return [];
    }
}

/**
 * Submit a new review
 */
async function submitReview(reviewData) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        // Validate review data
        if (!reviewData.product_id || !reviewData.customer_name || !reviewData.customer_email || !reviewData.rating || !reviewData.review_text) {
            throw new Error('Missing required fields');
        }

        // Validate rating is between 1-5
        if (reviewData.rating < 1 || reviewData.rating > 5) {
            throw new Error('Rating must be between 1 and 5');
        }

        // Create review object with status 'pending' for moderation
        const newReview = {
            product_id: reviewData.product_id,
            customer_name: reviewData.customer_name.trim(),
            customer_email: reviewData.customer_email.trim(),
            rating: parseInt(reviewData.rating),
            review_title: reviewData.review_title?.trim() || 'Great Product',
            review_text: reviewData.review_text.trim(),
            is_verified_purchase: reviewData.is_verified_purchase || false,
            status: 'pending' // Reviews need approval before showing
        };

        const { data, error } = await client
            .from('reviews')
            .insert([newReview])
            .select();

        if (error) throw error;

        console.log('✅ Review submitted successfully! Pending admin approval.');
        return {
            success: true,
            message: 'Thank you for your review! It will be published after admin approval.',
            review: data?.[0]
        };
    } catch (error) {
        console.error('❌ Submit review error:', error);
        return {
            success: false,
            message: error.message || 'Failed to submit review'
        };
    }
}

/**
 * Get reviews statistics for a product
 */
async function getProductReviewStats(productId) {
    try {
        const client = getClient();
        if (!client) return null;

        // Get all approved reviews for the product
        const { data: reviews, error } = await client
            .from('reviews')
            .select('rating')
            .eq('product_id', productId)
            .eq('status', 'approved');

        if (error) {
            console.error('❌ Get review stats error:', error);
            return null;
        }

        if (!reviews || reviews.length === 0) {
            return {
                totalReviews: 0,
                averageRating: 0,
                ratingBreakdown: {
                    5: 0,
                    4: 0,
                    3: 0,
                    2: 0,
                    1: 0
                }
            };
        }

        // Calculate statistics
        const ratingBreakdown = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
        let totalRating = 0;

        reviews.forEach(review => {
            ratingBreakdown[review.rating]++;
            totalRating += review.rating;
        });

        const averageRating = (totalRating / reviews.length).toFixed(1);

        console.log('✅ Review stats for product:', productId, { average: averageRating, total: reviews.length });

        return {
            totalReviews: reviews.length,
            averageRating: parseFloat(averageRating),
            ratingBreakdown
        };
    } catch (error) {
        console.error('❌ Get review stats exception:', error);
        return null;
    }
}

/**
 * Approve a review (admin function)
 */
async function approveReview(reviewId) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        const { data, error } = await client
            .from('reviews')
            .update({ status: 'approved' })
            .eq('id', reviewId)
            .select();

        if (error) throw error;

        console.log('✅ Review approved');
        return data?.[0];
    } catch (error) {
        console.error('❌ Approve review error:', error);
        throw error;
    }
}

/**
 * Reject a review (admin function)
 */
async function rejectReview(reviewId) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        const { data, error } = await client
            .from('reviews')
            .update({ status: 'rejected' })
            .eq('id', reviewId)
            .select();

        if (error) throw error;

        console.log('✅ Review rejected');
        return data?.[0];
    } catch (error) {
        console.error('❌ Reject review error:', error);
        throw error;
    }
}

/**
 * Delete a review (admin function)
 */
async function deleteReview(reviewId) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        const { error } = await client
            .from('reviews')
            .delete()
            .eq('id', reviewId);

        if (error) throw error;

        console.log('✅ Review deleted');
        return true;
    } catch (error) {
        console.error('❌ Delete review error:', error);
        throw error;
    }
}

/**
 * Mark a review as helpful
 */
async function markReviewHelpful(reviewId, voterEmail) {
    try {
        const client = getClient();
        if (!client) throw new Error('Supabase not initialized');

        // Try to insert helpful vote (will fail if already voted)
        const { data, error } = await client
            .from('review_helpful_votes')
            .insert([{
                review_id: reviewId,
                voter_email: voterEmail
            }])
            .select();

        if (error) {
            // If error is unique constraint violation, user already voted
            if (error.code === '23505') {
                console.log('ℹ️ User already voted helpful for this review');
                return { success: false, message: 'You already voted for this review' };
            }
            throw error;
        }

        // Update helpful count in reviews table
        const { data: reviews, error: updateError } = await client
            .from('reviews')
            .select('helpful_count')
            .eq('id', reviewId)
            .single();

        if (!updateError && reviews) {
            const newHelpfulCount = (reviews.helpful_count || 0) + 1;
            await client
                .from('reviews')
                .update({ helpful_count: newHelpfulCount })
                .eq('id', reviewId);
        }

        console.log('✅ Review marked as helpful');
        return { success: true, message: 'Thank you for your feedback!' };
    } catch (error) {
        console.error('❌ Mark helpful error:', error);
        return { success: false, message: 'Failed to mark review as helpful' };
    }
}
