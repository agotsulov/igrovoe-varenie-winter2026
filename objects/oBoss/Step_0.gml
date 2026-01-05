// STEP oBoss
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

switch (state) {
    case BOSS_STATE.IDLE:
		if (!grounded) {
			vsp += jump_gravity;
		}
		
        state_timer--;
        if (state_timer <= 0) {
            boss_next_attack();
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
        if (collide_x) {
            boss_change_state(BOSS_STATE.STUNNED);
        }
        break;
		
	case BOSS_STATE.STUNNED:
		state_timer--;
        if (state_timer <= 0) {
			boss_change_state(BOSS_STATE.JUMP_ATTACK);
            //boss_next_attack();
        }
		break;
	
	case BOSS_STATE.STUNNED_JUMP:
		state_timer--;
        if (state_timer <= 0) {
			boss_change_state(BOSS_STATE.DASH_ATTACK);
            //boss_next_attack();
        }
		break;
}
