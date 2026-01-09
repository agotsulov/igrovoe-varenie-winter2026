if breaktimer == -1 {
	image_index = 0	
}

if breaktimer > 0 {
	breaktimer -= 1	
}

if breaktimer == 0 {
	instance_create_depth(x+8,y+8,depth-1,oDoublePoof_1)
	
	_found = false
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

	if (!_found) {
	    if (!audio_is_playing(sfxPuzzleComplete))	audio_play_sound(sfxPuzzleComplete,1,0,1.3)
	}
	audio_play_sound(sfxPuzzleBreak,1,0,0.3)
	instance_destroy(self)
}