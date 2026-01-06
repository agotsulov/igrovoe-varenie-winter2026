// STEP EVENT - Update shake
if (shake_timer > 0) {
    // Reduce timer
    shake_timer -= 1;
    
    // Apply shake to the camera
    var shake_amount = shake_timer; // Current timer value is the shake amount
    
    // Randomize viewport position based on shake_amount
    var shake_x = random_range(-shake_amount, shake_amount);
    var shake_y = random_range(-shake_amount, shake_amount);
    
    // Apply to camera
    camera_set_view_pos(view_camera[0], 
                        camera_get_view_x(view_camera[0]) + shake_x,
                        camera_get_view_y(view_camera[0]) + shake_y);
    
    // Optional: Apply falloff for smoother diminishing
    shake_timer *= shake_falloff;
    
    // Reset camera when shake is nearly done
    if (shake_timer < 0.1) {
        shake_timer = 0;
        // Reset to original position (you might want to track original position)
        // Or just let it settle naturally as shake_amount approaches 0
    }
}