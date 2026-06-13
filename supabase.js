// Supabase Configuration
const SUPABASE_URL = 'https://solffnnevevczgysxdkw.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvbGZmbm5ldmV2Y3pneXN4ZGt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNDg4MzcsImV4cCI6MjA5NjkyNDgzN30.5ko-2SI69J3fbp-TPq5_Rd0IypFea29_fHh1cf6TQJ0';

// Initialize Supabase client
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Authentication functions
let currentUser = null;

async function checkAuth() {
    const { data: { user } } = await supabase.auth.getUser();
    currentUser = user;
    return user;
}

async function login(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
    });
    
    if (error) throw error;
    return data;
}

async function logout() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
}

// File upload to Supabase Storage
async function uploadFile(file, bucket = 'gallery-images') {
    try {
        const fileExt = file.name.split('.').pop();
        const fileName = `${Date.now()}-${Math.random().toString(36).substring(2)}.${fileExt}`;
        const filePath = `${fileName}`;
        
        const { data, error } = await supabase.storage
            .from(bucket)
            .upload(filePath, file, {
                cacheControl: '3600',
                upsert: false
            });
        
        if (error) throw error;
        
        // Get public URL
        const { data: { publicUrl } } = supabase.storage
            .from(bucket)
            .getPublicUrl(filePath);
        
        return publicUrl;
    } catch (error) {
        console.error('Error uploading file:', error);
        throw error;
    }
}

// Data fetch functions
async function fetchServices() {
    const { data, error } = await supabase
        .from('services')
        .select('*')
        .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data;
}

async function fetchProducts() {
    const { data, error } = await supabase
        .from('products')
        .select('*')
        .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data;
}

async function fetchGallery() {
    const { data, error } = await supabase
        .from('gallery')
        .select('*')
        .order('created_at', { ascending: false });
    
    if (error) throw error;
    return data;
}

async function fetchAppointments(date = null, status = 'all') {
    let query = supabase
        .from('appointments')
        .select(`
            *,
            services:service_id (name, price)
        `)
        .order('date', { ascending: false })
        .order('time', { ascending: false });
    
    if (date) {
        const startDate = new Date(date);
        const endDate = new Date(date);
        endDate.setDate(endDate.getDate() + 1);
        
        query = query
            .gte('date', startDate.toISOString().split('T')[0])
            .lt('date', endDate.toISOString().split('T')[0]);
    }
    
    if (status !== 'all') {
        query = query.eq('status', status);
    }
    
    const { data, error } = await query;
    if (error) throw error;
    return data;
}

async function fetchDashboardStats() {
    const today = new Date().toISOString().split('T')[0];
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    // Today's appointments
    const { data: appointments, error: appointmentsError } = await supabase
        .from('appointments')
        .select(`
            status,
            services:service_id (price)
        `)
        .gte('date', today)
        .lt('date', tomorrow.toISOString().split('T')[0]);
    
    if (appointmentsError) throw appointmentsError;
    
    // Total services
    const { count: totalServices, error: servicesError } = await supabase
        .from('services')
        .select('*', { count: 'exact', head: true });
    
    if (servicesError) throw servicesError;
    
    // Total products
    const { count: totalProducts, error: productsError } = await supabase
        .from('products')
        .select('*', { count: 'exact', head: true });
    
    if (productsError) throw productsError;
    
    // Today's revenue (confirmed appointments only)
    const confirmedAppointments = appointments?.filter(a => a.status === 'confirmed') || [];
    const todayRevenue = confirmedAppointments.reduce((sum, appointment) => {
        return sum + (appointment.services?.price || 0);
    }, 0);
    
    return {
        todayAppointments: appointments?.length || 0,
        totalServices: totalServices || 0,
        totalProducts: totalProducts || 0,
        todayRevenue: todayRevenue || 0
    };
}

// CRUD operations for Services
async function createService(serviceData) {
    const { data, error } = await supabase
        .from('services')
        .insert([serviceData])
        .select()
        .single();
    
    if (error) throw error;
    return data;
}

async function updateService(id, serviceData) {
    const { data, error } = await supabase
        .from('services')
        .update(serviceData)
        .eq('id', id)
        .select()
        .single();
    
    if (error) throw error;
    return data;
}

async function deleteService(id) {
    const { error } = await supabase
        .from('services')
        .delete()
        .eq('id', id);
    
    if (error) throw error;
}

// CRUD operations for Products
async function createProduct(productData) {
    const { data, error } = await supabase
        .from('products')
        .insert([productData])
        .select()
        .single();
    
    if (error) throw error;
    return data;
}

async function updateProduct(id, productData) {
    const { data, error } = await supabase
        .from('products')
        .update(productData)
        .eq('id', id)
        .select()
        .single();
    
    if (error) throw error;
    return data;
}

async function deleteProduct(id) {
    const { error } = await supabase
        .from('products')
        .delete()
        .eq('id', id);
    
    if (error) throw error;
}

// CRUD operations for Gallery
async function createGalleryItem(itemData) {
    const { data, error } = await supabase
        .from('gallery')
        .insert([itemData])
        .select()
        .single();
    
    if (error) throw error;
    return data;
}

async function deleteGalleryItem(id) {
    const { error } = await supabase
        .from('gallery')
        .delete()
        .eq('id', id);
    
    if (error) throw error;
}

// Update appointment status
async function updateAppointmentStatus(id, status) {
    const { data, error } = await supabase
        .from('appointments')
        .update({ status })
        .eq('id', id)
        .select()
        .single();
    
    if (error) throw error;
    return data;
}

// Settings operations
async function getSetting(key) {
    const { data, error } = await supabase
        .from('settings')
        .select('value')
        .eq('key', key)
        .single();
    
    if (error && error.code !== 'PGRST116') throw error; // PGRST116 = no rows returned
    return data?.value;
}

async function setSetting(key, value) {
    const { data, error } = await supabase
        .from('settings')
        .upsert({ key, value }, { onConflict: 'key' })
        .select()
        .single();
    
    if (error) throw error;
    return data;
}

// Export functions
window.supabaseClient = {
    supabase,
    checkAuth,
    login,
    logout,
    uploadFile,
    fetchServices,
    fetchProducts,
    fetchGallery,
    fetchAppointments,
    fetchDashboardStats,
    createService,
    updateService,
    deleteService,
    createProduct,
    updateProduct,
    deleteProduct,
    createGalleryItem,
    deleteGalleryItem,
    updateAppointmentStatus,
    getSetting,
    setSetting,
    currentUser: () => currentUser
};
