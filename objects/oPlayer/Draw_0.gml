// Invulnerability blinking
if (invulnerable) {
    if (floor(invulnerable_timer / 0.2) % 2 == 0) {
        exit;
    }
}

// Handle jump frame selection
if (sprite_index == sGatoJump && !override_playing) {
    var frame = 0;  // Frame 1 (rise) - default
    
    if (ysp >= jump_frame_2_min_ysp && ysp <= jump_frame_2_max_ysp) {
        frame = 1;  // Frame 2 (hang time)
    } else if (ysp > jump_frame_2_max_ysp) {
        frame = 2;  // Frame 3 (fall)
    }
    
    // Draw jump sprite with correct frame
    draw_sprite_ext(
        sGatoJump,
        frame,
        x, y,
        facing_left ? -1 : 1, 1,
        0, c_white, 1
    );
} else {
    // Draw normally for all other sprites
    // This lets GameMaker handle animation and broadcast messages
    draw_sprite_ext(
        sprite_index,
        image_index,
        x, y,
        facing_left ? -1 : 1, 1,
        0, c_white, 1
    );
}
