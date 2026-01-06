// STEP oBoss
prev_x = x;
prev_y = y;

grounded = place_meeting(x, y + 1, oSolid);

collide_x = false

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

delta_x = x - prev_x;
delta_y = y - prev_y;

// Boss damage
var bullet = instance_place(x, y, oBullet);
if (bullet != noone) {
	hp -= bullet.damage;
	instance_destroy(bullet)
}
 

switch (state) {
    case BOSS_STATE.IDLE:
		if (!grounded) {
			vsp += jump_gravity;
		}
		
        state_timer--;
        if (state_timer <= 0) {
            boss_change_state(BOSS_STATE.JUMP_ATTACK)
        }
        break;
    
    case BOSS_STATE.JUMP_ATTACK:
		if (!grounded) {
			vsp += jump_gravity;
		}

        if (grounded && vsp >= 0) {
            if (!jump_landed) {
                jump_landed = true;
                hsp = 0;
                vsp = 0;
                state_timer = jump_delay;
            }
            
            state_timer--;
            if (state_timer <= 0) {
                jump_count++;
                
                if (jump_count > jump_count_max) {
                    boss_change_state(BOSS_STATE.STUNNED_JUMP);
                } else {
                    boss_do_jump();
                }
            }
        }
        break;
    
    case BOSS_STATE.DASH_ATTACK:
        // Ускоряемся в направлении facing
		hsp += dash_accel * facing;
    
		// Ограничиваем максимальную скорость
		hsp = clamp(hsp, -dash_max_speed, dash_max_speed);
    
		// Врезались в стену
		if (collide_x) {
			boss_change_state(BOSS_STATE.STUNNED);
		}
        break;
		
	case BOSS_STATE.STUNNED:
		state_timer--;
        if (state_timer <= 0) {
			boss_change_state(BOSS_STATE.FLY_UP);
        }
		break;
	
	case BOSS_STATE.STUNNED_JUMP:
		state_timer--;
        if (state_timer <= 0) {
			boss_change_state(BOSS_STATE.DASH_ATTACK);
        }
		break;
		
	case BOSS_STATE.FLY_UP:
		if (place_meeting(x, y - 1, oSolid)) {
		    vsp = 0;
		    boss_change_state(BOSS_STATE.CHASE);
		}
		break;

	case BOSS_STATE.CHASE:
	    var _player = instance_nearest(x, y, oPlayer);
	    if (_player != noone) {
	        var dir_to_player = sign(_player.x - x);
	        if (dir_to_player != sign(hsp) && hsp != 0) {
	            hsp *= chase_friction;
	        }
	        hsp += chase_accel * dir_to_player;
	        if (dir_to_player != 0) facing = dir_to_player;
	    }
    
	    hsp = clamp(hsp, -chase_max_speed, chase_max_speed);
    
	    state_timer--;
	    if (state_timer <= 0) {
	        hsp = 0;
	        boss_change_state(BOSS_STATE.FALLING);
	    }
	    break;

	case BOSS_STATE.FALLING:
	    vsp += jump_gravity;
    
	    if (grounded && vsp >= 0) {
	        vsp = 0;
	        hsp = 0;
	        boss_change_state(BOSS_STATE.STUNNED_FALLING);  
	    }
	    break;
		
		
	case BOSS_STATE.STUNNED_FALLING:
		state_timer--;
        if (state_timer <= 0) {
			boss_change_state(BOSS_STATE.JUMP_ATTACK);
        }
		break;
}
