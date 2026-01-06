// Get direction to player from eye's origin
var target_x = oPlayer.x - x;
var target_y = oPlayer.y - y;

// Normalize direction
var distance = point_distance(0, 0, target_x, target_y);
var dir_x = (distance > 0) ? target_x / distance : 0;
var dir_y = (distance > 0) ? target_y / distance : 0;

// Limit pupil to radius and max distance
var pupil_distance = min(radius, distance);
pupil_distance = min(pupil_distance, max_pupil_distance);

// Calculate target position
var target_pupil_x = dir_x * pupil_distance;
var target_pupil_y = dir_y * pupil_distance;

// Apply offsets
target_pupil_x += pupil_offset_x;
target_pupil_y += pupil_offset_y;

// Smooth interpolation
pupil_x = lerp(pupil_x, target_pupil_x, follow_speed);
pupil_y = lerp(pupil_y, target_pupil_y, follow_speed);

if (instance_exists(oBoss1)) {
	i = instance_nearest(x,y, oBoss1)
	image_index = 0
	x = i.x
	y = i.y - i.sprite_height/2
}