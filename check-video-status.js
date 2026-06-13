// Save this as: check-video-status.js
// Add to index.html before other scripts to debug video loading

window.checkVideoStatus = async function() {
    console.clear();
    console.log('=== VIDEO DIAGNOSTIC CHECK ===\n');
    
    // Check 1: Video element exists
    const videoElement = document.getElementById('heroVideo');
    console.log('✓ Video element exists:', !!videoElement);
    if (videoElement) {
        console.log('  - src:', videoElement.src || '(empty)');
        console.log('  - display:', getComputedStyle(videoElement).display);
        console.log('  - z-index:', getComputedStyle(videoElement).zIndex);
        console.log('  - width:', videoElement.offsetWidth);
        console.log('  - height:', videoElement.offsetHeight);
    }
    
    // Check 2: Supabase client
    const client = window.supabase || (typeof getClient === 'function' ? getClient() : null);
    console.log('\n✓ Supabase available:', !!client);
    
    // Check 3: Query database
    if (client) {
        try {
            console.log('\n📡 Querying settings table...');
            const { data, error } = await client
                .from('settings')
                .select('*')
                .eq('key', 'hero_video');
            
            if (error) {
                console.error('❌ Database error:', error);
            } else {
                console.log('✓ Data retrieved:', data);
                if (data && data.length > 0) {
                    const videoUrl = data[0].hero_video_url;
                    console.log('✓ Video URL:', videoUrl || '(empty)');
                    
                    if (videoUrl) {
                        // Check 4: Test if URL is accessible
                        console.log('\n🔗 Testing URL accessibility...');
                        try {
                            const response = await fetch(videoUrl, { method: 'HEAD' });
                            console.log('✓ URL is accessible:', response.ok, '(Status:', response.status + ')');
                        } catch (err) {
                            console.error('❌ URL not accessible:', err.message);
                        }
                    }
                } else {
                    console.warn('⚠ No hero_video setting found in database');
                }
            }
        } catch (err) {
            console.error('❌ Error querying database:', err);
        }
    }
    
    // Check 5: Test video loading manually
    if (videoElement && client) {
        console.log('\n🎬 Manual video load test...');
        try {
            const { data, error } = await client
                .from('settings')
                .select('hero_video_url')
                .eq('key', 'hero_video')
                .single();
            
            if (data && data.hero_video_url) {
                console.log('Setting video source to:', data.hero_video_url);
                videoElement.src = data.hero_video_url;
                videoElement.style.display = 'block';
                console.log('✓ Video source set and display enabled');
            }
        } catch (err) {
            console.error('❌ Error setting video:', err);
        }
    }
    
    console.log('\n=== END DIAGNOSTIC ===');
};

// Auto-run on page load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        setTimeout(() => window.checkVideoStatus(), 1000);
    });
} else {
    setTimeout(() => window.checkVideoStatus(), 1000);
}
