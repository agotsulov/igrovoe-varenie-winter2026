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


if (inventory) {
	// AURA PROPERTIES
	var _num_particles = 20;
	var _radius = 16; // Change this to your desired radius
	var _rotation_speed = 1; // Degrees per frame (adjust as needed)

	// Persistent rotation value (initialize in Create event: aura_rotation = 0;)
	if (!variable_instance_exists(id, "aura_rotation")) aura_rotation = 0;
	aura_rotation += _rotation_speed;

	// Calculate particle positions
	for (var i = 0; i < _num_particles; i++) {
	    // Calculate angle for this particle (evenly distributed)
	    var _angle = (i / _num_particles) * 360 + aura_rotation;
    
	    // Convert to radians and calculate position
	    var _rad = degtorad(_angle);
	    var _x_offset = lengthdir_x(_radius, _angle);
	    var _y_offset = lengthdir_y(_radius, _angle)-8;
    
	    // Draw particle at calculated position
	    draw_sprite(sMiniStar, 0, x + _x_offset, y + _y_offset);
	}
}


if (hp > 0) {
	// AURA PROPERTIES
	var _num_particles = hp;
	var _radius = 14; // Change this to your desired radius
	var _rotation_speed = 1; // Degrees per frame (adjust as needed)

	// Persistent rotation value (initialize in Create event: aura_rotation = 0;)
	if (!variable_instance_exists(id, "aura_rotation")) aura_rotation = 0;
	aura_rotation += _rotation_speed;

	// Calculate particle positions
	for (var i = 0; i < _num_particles; i++) {
	    // Calculate angle for this particle (evenly distributed)
	    var _angle = (i / _num_particles) * 360 + aura_rotation;
    
	    // Convert to radians and calculate position
	    var _rad = degtorad(_angle);
	    var _x_offset = lengthdir_x(_radius, _angle);
	    var _y_offset = lengthdir_y(_radius, _angle)-8;
    
	    // Draw particle at calculated position
	    draw_sprite(sMiniHeart, 0, x + _x_offset, y + _y_offset);
	}
}