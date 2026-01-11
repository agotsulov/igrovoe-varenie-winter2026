if (sleep_timer > 0) {
	speed = 0
	sleep_timer -= 1
	exit
}

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


if (phase == 1) {
	if (instance_exists(oPhase1Approacher)) {
		ap = instance_nearest(x,y,oPhase1Approacher) 
		move_towards_point(ap.x, ap.y, 1)
	}


	if (place_meeting(x,y,oPhase1Approacher)) {
		ap = instance_nearest(x,y,oPhase1Approacher)
		instance_create_depth(x,y+32,depth+1,oBoss1)
		instance_destroy(ap)
	}
	

	if (instance_exists(oBoss1)) {
		var i = instance_nearest(x,y, oBoss1)
		image_index = 0
		x = i.x
		y = i.y - i.sprite_height/2
	}
}

if (phase == 2) {
	if (instance_exists(oPhase2Approacher)) {
		ap = instance_nearest(x,y,oPhase2Approacher) 
		move_towards_point(ap.x, ap.y, 1)
	}


	if (place_meeting(x,y,oPhase2Approacher)) {
		ap = instance_nearest(x,y,oPhase2Approacher)
		instance_create_depth(x,y,depth+1,oBoss2)
		instance_destroy(ap)
	}
	

	if (instance_exists(oBoss2)) {
		var i = instance_nearest(x,y, oBoss2Eye)
		image_index = 0
		x = i.x + i.sprite_width/2 - 2
		y = i.y + i.sprite_height/2
	}
}

if (phase == 3) {
	if (instance_exists(oPhase3Approacher)) {
		ap = instance_nearest(x,y,oPhase3Approacher) 
		move_towards_point(ap.x, ap.y, 1)
	}


	if (place_meeting(x,y,oPhase3Approacher)) {
		ap = instance_nearest(x,y,oPhase3Approacher)
		instance_create_depth(x,y,depth+1,oBoss3)
		instance_destroy(ap)
	}
	

	if (instance_exists(oBoss3)) {
		var i = instance_nearest(x,y, oBoss3)
		image_index = 0
		x = i.x
		y = i.y
	}
}

if (phase == 99) {
	ap = instance_nearest(x,y,oFinalApproacher) 
	move_towards_point(ap.x, ap.y, 1)
		
	if (audio_is_playing(musBoss)) {
		audio_stop_sound(musBoss)	
	}
	special_timer -= 1
	if (special_timer < 0) {
		special_timer = 15
		instance_create_depth(x,y,depth+1,oDoublePoof)
		audio_play_sound(sfxSmallFall,1,0)
	}
	
	if (place_meeting(x,y,oFinalApproacher)) {
		for (var i = 0; i < 20; i++) {
		    var randX = random_range(bbox_left, bbox_right);
		    var randY = random_range(bbox_top, bbox_bottom);
		    instance_create_depth(randX, randY, depth+1, oDoublePoof);
		}
		instance_destroy(self)
		audio_play_sound(sfxBigSlam,1,0)
		
		instance_create_depth(ap.x,ap.y,depth+1,oRestartWaiter)
	}
}