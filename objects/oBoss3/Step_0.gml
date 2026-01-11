// STEP oBoss3
prev_x = x;
prev_y = y;

grounded = place_meeting(x, y + 1, oSolid);
collide_x = false;

//move and collide
if (place_meeting(x + hsp, y, oSolid)) {
    while (!place_meeting(x + sign(hsp), y, oSolid)) {
        x += sign(hsp);
    }
	collide_x = true
    hsp = 0;
} else {
    x += hsp;
}
if (place_meeting(x, y + vsp, oSolid)) {
    while (!place_meeting(x, y + sign(vsp), oSolid)) {
        y += sign(vsp);
    }
    vsp = 0;
} else {
    y += vsp;
}

// === ЛОГИКА СОСТОЯНИЙ ===
switch (state) {
    case BOSS3_STATE.IDLE:
    case BOSS3_STATE.STUNNED_LIGHT:
    case BOSS3_STATE.STUNNED_HEAVY:
	case BOSS3_STATE.ATTACK_OR_SPAWN:
	case BOSS3_STATE.ATTACK:
    case BOSS3_STATE.SPAWN:
        state_timer--;
        if (state_timer <= 0) {
            boss_change_state();
        }
        break;
        
        
    case BOSS3_STATE.MOVE_LEFT:
		if (x <= parabola_rl_end_x) {
		    x = parabola_rl_end_x;
		    hsp = 0;
		    boss_change_state();
		}
		break;
		
    case BOSS3_STATE.MOVE_RIGHT:
	    if (x >= parabola_lr_end_x) {
	        x = parabola_lr_end_x;
	        hsp = 0;
	        boss_change_state();
	    }
	    break;
       
    case BOSS3_STATE.PARABOLA_LR:
		parabola_timer++;
        var t = parabola_timer / parabola_duration;
        
        if (t >= 1) {
            x = parabola_end_x;
            y = parabola_end_y;
            hsp = 0;
            vsp = 0;
            boss_change_state();
        } else {
            var new_x = lerp(parabola_start_x, parabola_end_x, t);
			var parabola_offset = 4 * parabola_height * t * (1 - t);
            //var parabola_offset = power(sin(t * pi), 2) * parabola_height;
            var base_y = lerp(parabola_start_y, parabola_end_y, t);
            var new_y = base_y + parabola_offset;
            
            hsp = new_x - x;
            vsp = new_y - y;
        }
        break;
		
    case BOSS3_STATE.PARABOLA_RL:
        parabola_timer++;
        var t = parabola_timer / parabola_duration;
        
        if (t >= 1) {
            x = parabola_end_x;
            y = parabola_end_y;
            hsp = 0;
            vsp = 0;
            boss_change_state();
        } else {
            var new_x = lerp(parabola_start_x, parabola_end_x, t);
			var parabola_offset = 4 * parabola_height * t * (1 - t);
			//var parabola_offset = power(sin(t * pi), 2) * parabola_height;
            //var parabola_offset = sin(t * pi) * parabola_height;
            var base_y = lerp(parabola_start_y, parabola_end_y, t);
            var new_y = base_y + parabola_offset;
            
            hsp = new_x - x;
            vsp = new_y - y;
        }
        break;
        
	
	
}


delta_x = x - prev_x;
delta_y = y - prev_y;

// === УРОН ===
var bullet = instance_place(x, y, oBullet);
if (bullet != noone) {
    hp -= bullet.damage;
    instance_destroy(bullet);
    
    if (hp <= 0) {
        instance_destroy();
    }
}
