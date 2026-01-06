draw_self()

// AURA PROPERTIES
var _num_particles = 4;
var _radius = 5; // Change this to your desired radius
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
	var _y_offset = lengthdir_y(_radius, _angle);
    
	// Draw particle at calculated position
	draw_sprite(sMiniStarRed, 0, x + _x_offset, y + _y_offset);
}

