if breaktimer == -1 {
	image_index = 0	
}

if breaktimer > 0 {
	breaktimer -= 1	
}

if breaktimer == 0 {
	for (var i = 0; i < 10; i++) {
		var randX = random_range(bbox_left, bbox_right);
		var randY = random_range(bbox_top, bbox_bottom);
		instance_create_depth(randX, randY, depth+1, oDoublePoof);
	}
	audio_play_sound(sfxCrystalBreakFinish,1,0,1.3)
	instance_destroy(self)
	
	var _found = false;

	// Check in all 4 directions (1 pixel away from hitbox)
	var _checks = [
	    [bbox_right + 1, y],      // Right
	    [bbox_left - 1, y],       // Left  
	    [x, bbox_top - 1],        // Up
	    [x, bbox_bottom + 1]      // Down
	];

	for (var i = 0; i < array_length(_checks); i++) {
	    var _check = _checks[i];
	    var _crystal = instance_position(_check[0], _check[1], oPuzzleCrystal);
    
	    if (_crystal != noone && _crystal.id != id) {
	        _crystal.trigger();
	        _found = true;
	    }
	}
}