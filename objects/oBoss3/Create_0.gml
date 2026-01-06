// CREATE oBoss3
event_inherited()

max_hp = 1;
hp = max_hp;
facing = 1;

vsp = 0;
hsp = 0;
grounded = false;

collide_x = false;

prev_x = x;
prev_y = y;
delta_x = 0;
delta_y = 0;

// FSM
enum BOSS3_STATE {
    IDLE,
    CHASE,
    SPAWN,
    MOVE_LEFT,
    MOVE_RIGHT,
    PARABOLA_LR,
    PARABOLA_RL,
    STUNNED,
}

state = BOSS3_STATE.IDLE;
state_timer = 0;

// Только для STUNNED — куда идти после стана
stunned_next_state = BOSS3_STATE.IDLE;

// === НАСТРОЙКИ ===

idle_delay = 60;

// CHASE
chase_acceleration = 0.3;
chase_max_speed = 4;
chase_duration = 180;
chase_y_offset = -48;

// SPAWN
spawn_offset_x = 48;
spawn_offset_y = 0;

// MOVE
move_speed = 3;

// PARABOLA
parabola_start_x = 0;
parabola_start_y = 0;
parabola_end_x = 0;
parabola_end_y = 0;
parabola_height = 80;
parabola_duration = 120;
parabola_timer = 0;
parabola_lr_end_x = room_width - 64;
parabola_rl_end_x = 64;

// === ФУНКЦИИ ===

boss_change_state = function(_new_state) {
    state = _new_state;
    
    switch (_new_state) {
        case BOSS3_STATE.IDLE:
            state_timer = idle_delay;
            hsp = 0;
            vsp = 0;
            break;
            
        case BOSS3_STATE.CHASE:
            state_timer = chase_duration;
            break;
            
        case BOSS3_STATE.SPAWN:
            var spawn1 = instance_create_layer(x - spawn_offset_x, y + spawn_offset_y, layer, oFatherSmall);
            spawn1.facing = -1;
            var spawn2 = instance_create_layer(x + spawn_offset_x, y + spawn_offset_y, layer, oFatherSmall);
            spawn2.facing = 1;
            state_timer = 30;
            break;
            
        case BOSS3_STATE.MOVE_LEFT:
            hsp = -move_speed;
            vsp = 0;
            break;
            
        case BOSS3_STATE.MOVE_RIGHT:
            hsp = move_speed;
            vsp = 0;
            break;
            
        case BOSS3_STATE.PARABOLA_LR:
            parabola_start_x = x;
            parabola_start_y = y;
            parabola_end_x = parabola_lr_end_x;
            parabola_end_y = y;
            parabola_timer = 0;
            hsp = 0;
            vsp = 0;
            break;
            
        case BOSS3_STATE.PARABOLA_RL:
            parabola_start_x = x;
            parabola_start_y = y;
            parabola_end_x = parabola_rl_end_x;
            parabola_end_y = y;
            parabola_timer = 0;
            hsp = 0;
            vsp = 0;
            break;
    }
}

// Стан: duration в кадрах, after куда после
boss_stun = function(_duration, _after = BOSS3_STATE.IDLE) {
    state = BOSS3_STATE.STUNNED;
    state_timer = _duration;
    stunned_next_state = _after;
    hsp = 0;
    vsp = 0;
}
