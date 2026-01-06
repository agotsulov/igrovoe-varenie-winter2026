// CREATE oBoss3
event_inherited()

max_hp = 8;
hp = max_hp;
facing = 1;

vsp = 0;
hsp = 0;
grounded = false;

collide_x = false

prev_x = x;
prev_y = y;
delta_x = 0;
delta_y = 0;

// FSM состояния
enum BOSS3_STATE {
    IDLE,
    SPAWN,
	PARABOLA_MOVE,
} 

idle_delay = 60;

state = BOSS3_STATE.IDLE;
state_timer = idle_delay;

boss_change_state = function(_new_state) {
    state = _new_state;
    
	switch (_new_state) {
        case BOSS_STATE.IDLE:
            state_timer = idle_delay;
            hsp = 0;
            vsp = 0;
            break;
            
        case BOSS_STATE.JUMP_ATTACK:
            jump_count = 0;
            break;
	
        case BOSS_STATE.DASH_ATTACK:
			var _player = instance_nearest(x, y, oPlayer);
			if (_player != noone) {
				facing = sign(_player.x - x);
				if (facing == 0) facing = 1;
			}
			
            vsp = 0;
            break;
            
        case BOSS_STATE.STUNNED:
            state_timer = dash_stun_time;
            hsp = 0;
			boss_do_proj()
			boss_do_proj()
			break;
		
		case BOSS_STATE.STUNNED_JUMP:
            state_timer = dash_stun_time;
            hsp = 0;
			boss_do_proj()
			break;
		
		case BOSS_STATE.FLY_UP:
			hsp = 0;
			vsp = fly_up_speed;
			break;

		case BOSS_STATE.CHASE:
			state_timer = chase_duration;
			vsp = 0;
			break;

		case BOSS_STATE.FALLING:
			hsp = 0;
			// vsp сохраняется или можно обнулить
			break;
			
		
		case BOSS_STATE.STUNNED_FALLING:
            state_timer = dash_stun_time;
            hsp = 0;
			boss_do_proj()
			break;
    }
}

boss_do_proj = function() {
	var proj = instance_create_depth(irandom_range(24, 294), 24, depth + 1, oRock);
  
	proj.vsp = 1;	
	
}

boss_do_jump = function() {
    var _player = instance_nearest(x, y, oPlayer);
    if (_player != noone) {
        facing = sign(_player.x - x);
        if (facing == 0) facing = 1;
    }
    
    hsp = jump_hspeed * facing;
    vsp = jump_vspeed;
    jump_landed = false;
}