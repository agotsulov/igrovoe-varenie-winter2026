// CREATE oBoss
event_inherited()

max_hp = 6;
hp = max_hp;
facing = 1;

idle_delay = 60;

jump_count_max = 3;
jump_hspeed = 1;
jump_vspeed = -3;
jump_gravity = 0.1;
jump_delay = 30;

dash_speed = 6;
dash_stun_time = 20


vsp = 0;
hsp = 0;
grounded = false;

collide_x = false

prev_x = x;
prev_y = y;
delta_x = 0;
delta_y = 0;

// FSM состояния
enum BOSS_STATE {
    IDLE,
    JUMP_ATTACK,
    DASH_ATTACK,
    STUNNED,
	STUNNED_JUMP,
}

state = BOSS_STATE.IDLE;
state_timer = idle_delay;

// Переменные атак
jump_count = 0;
jump_landed = false;

current_attack_index = 0;
attacks = [BOSS_STATE.JUMP_ATTACK, BOSS_STATE.DASH_ATTACK];


boss_change_state = function(_new_state) {
    state = _new_state;
    
	show_debug_message("STATE")
	show_debug_message(_new_state)
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
			
            hsp = dash_speed * facing;
            vsp = 0;
            break;
            
        case BOSS_STATE.STUNNED:
			show_debug_message("STUNNED")
            state_timer = dash_stun_time;
            hsp = 0;
			boss_do_proj()
			boss_do_proj()
			break;
		
		case BOSS_STATE.STUNNED_JUMP:
			show_debug_message("STUNNED")
            state_timer = dash_stun_time;
            hsp = 0;
			boss_do_proj()
			break;
    }
}

boss_do_proj = function() {
	var proj = instance_create_depth(irandom_range(180, 580), 440, depth + 1, oProjectile);
  
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


boss_next_attack = function() {
	if (current_attack_index >= array_length(attacks)) {
		current_attack_index = 0
	}
    var _attack = attacks[current_attack_index];
	current_attack_index += 1
	boss_change_state(_attack);
}