// CREATE oBoss3
event_inherited()

max_hp = 8;
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

start_y = y;  

// FSM
enum BOSS3_STATE {
    IDLE,
    SPAWN,
    MOVE_LEFT,
    MOVE_RIGHT,
    PARABOLA_LR,
    PARABOLA_RL,
    STUNNED_LIGHT,
    STUNNED_HEAVY,
    ATTACK, 
	ATTACK_OR_SPAWN,
    FLY_TO_RANDOM,
}

state = BOSS3_STATE.IDLE;
state_timer = 60;

// ==============================
// === ПАТТЕРН ПОВЕДЕНИЯ БОССА ===
// ==============================
// Каждая нода: {state, next}
boss_pattern = [
    {state: BOSS3_STATE.IDLE, next: 1},
    {state: BOSS3_STATE.MOVE_LEFT, next: 2},
    {state: BOSS3_STATE.ATTACK, next: 3},
    {state: BOSS3_STATE.PARABOLA_LR, next: 4},
    {state: BOSS3_STATE.STUNNED_LIGHT, next: 5},
    {state: BOSS3_STATE.ATTACK_OR_SPAWN, next: 6},
    {state: BOSS3_STATE.STUNNED_LIGHT, next: 7},
	{state: BOSS3_STATE.FLY_TO_RANDOM, next: 8},
	{state: BOSS3_STATE.FLY_TO_RANDOM, next: 9},
    {state: BOSS3_STATE.STUNNED_LIGHT, next: 10},
    {state: BOSS3_STATE.MOVE_RIGHT, next: 11},
    {state: BOSS3_STATE.STUNNED_LIGHT, next: 12},
    {state: BOSS3_STATE.PARABOLA_RL, next: 13},
    {state: BOSS3_STATE.STUNNED_LIGHT, next: 14},
    {state: BOSS3_STATE.ATTACK_OR_SPAWN, next: 15},
    {state: BOSS3_STATE.STUNNED_LIGHT, next: 16},
	{state: BOSS3_STATE.FLY_TO_RANDOM, next: 17},
	{state: BOSS3_STATE.FLY_TO_RANDOM, next: 18},
    {state: BOSS3_STATE.STUNNED_LIGHT, next: 19},
    {state: BOSS3_STATE.MOVE_LEFT, next: 20},
    {state: BOSS3_STATE.STUNNED_LIGHT, next: 5},
];

pattern_index = 0;  // Текущая нода

// === НАСТРОЙКИ ===


// SPAWN
spawn_offset_x = 24;
spawn_offset_y = +8;
spawn_ready = false;  // Спавн разрешён со второго раза

// MOVE
move_speed = 3;

// PARABOLA
parabola_start_x = 0;
parabola_start_y = 0;
parabola_end_x = 0;
parabola_end_y = 0;
parabola_height = 32;
parabola_duration = 60 * 2.5;
parabola_timer = 0;
parabola_lr_end_x = room_width - 64;
parabola_rl_end_x = 64;
// Стрельба во время параболы
parabola_shoot_start_x = 128;              // Начинает стрелять после этой X
parabola_shoot_end_x = room_width - 128;   // Заканчивает стрелять до этой X
parabola_shoot_interval = 1;              // Кадров между выстрелами
parabola_shoot_timer = 0;
parabola_shooting = false;                 // Стреляет ли сейчас

// FLY_TO_RANDOM
fly_target_x = 0;
fly_target_y = 0;
fly_speed = 2;
fly_shooting = false;
fly_shoot_timer = 0;
fly_shoot_duration = 60 * 0.75;  // 0.75 секунды
fly_shoot_interval = 1;          // Интервал между выстрелами
fly_shoot_cooldown = 0;
fly_shoot_offset = 32;           // Смещение точек стрельбы от центра

// STUNNED
stunned_light_duration = 60 * 1; 
stunned_heavy_duration = 60 * 2;

// === ФУНКЦИИ ===

shoot = function(start_x, start_y, proj_speed = 2) {
	if (instance_exists(oPlayer)) {
		var dir = point_direction(start_x, start_y, oPlayer.x, oPlayer.y);
        dir += irandom_range(-4, 4); // чтобы он не точно в игрока бил всегда
		var proj = instance_create_layer(start_x, start_y, "Instances_1", oRock);
		proj.hsp = lengthdir_x(1, dir);
		proj.vsp = lengthdir_y(1, dir);
		proj.sp = proj_speed
	}
}

shoot_left = function() {
	shoot(x-32, y)
}
shoot_right = function() {
	shoot(x+32, y)
}
shoot_up = function() {
	shoot(x, y+32)
}
shoot_down = function() {
	shoot(x, y-32)
}

shoot_smart = function() {
	var half = room_width / 2;
	var boss_left = (x < half);
	var player_left = (oPlayer.x < half);
    
	if (boss_left == player_left) {
		// В одной половине — стреляем по бокам
		shoot_left();
		shoot_right();
	} else {
		// В разных половинах — стреляем вверх/вниз
		shoot_up();
		shoot_down();
	}
}

shoot_functions = [shoot_left, shoot_right, shoot_up, shoot_down];

/// Переход к следующей ноде по паттерну
boss_change_state = function() {
    pattern_index = boss_pattern[pattern_index].next;
    var _new_state = boss_pattern[pattern_index].state;
    
    state = _new_state;
    
    switch (_new_state) {
        case BOSS3_STATE.IDLE:
            hsp = 0;
            vsp = 0;
            break;
            
        case BOSS3_STATE.SPAWN:
            var spawn1 = instance_create_layer(x - spawn_offset_x, y + spawn_offset_y, layer, oFatherSmall);
            spawn1.facing = -1;
            var spawn2 = instance_create_layer(x + spawn_offset_x, y + spawn_offset_y, layer, oFatherSmall);
            spawn2.facing = 1;
            state_timer = 30;
            break;
            
        case BOSS3_STATE.MOVE_LEFT:
		    fly_target_x = parabola_rl_end_x;
		    fly_target_y = start_y;
		    break;
    
		case BOSS3_STATE.MOVE_RIGHT:
		    fly_target_x = parabola_lr_end_x;
		    fly_target_y = start_y;
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
		
		case BOSS3_STATE.STUNNED_LIGHT:
            state_timer = stunned_light_duration;
            hsp = 0;
            vsp = 0;
            break;
            
        case BOSS3_STATE.STUNNED_HEAVY:
            state_timer = stunned_heavy_duration;
            hsp = 0;
            vsp = 0;
            break;
			
		case BOSS3_STATE.ATTACK:
			state_timer = 30;
            hsp = 0;
            vsp = 0;
			zshoot_functions = array_shuffle(shoot_functions);
			shoot_functions[0]();
			shoot_functions[1]();
            break;
			
		case BOSS3_STATE.ATTACK_OR_SPAWN:
			state_timer = 30;
            hsp = 0;
            vsp = 0;

            if (instance_number(oFatherSmall) < 2) {
			    if (spawn_ready) {
			        // Второй+ раз — спавним
			        var spawn1 = instance_create_layer(x - spawn_offset_x, y + spawn_offset_y, layer, oFatherSmall);
			        spawn1.facing = -1;
			        var spawn2 = instance_create_layer(x + spawn_offset_x, y + spawn_offset_y, layer, oFatherSmall);
			        spawn2.facing = 1;
			        spawn_ready = false;  
			    } else {
			        spawn_ready = true;
					shoot_smart()
			    }
			} else {
			    spawn_ready = false; 
			    shoot_smart()
			}
		case BOSS3_STATE.FLY_TO_RANDOM:
			fly_target_x = irandom_range(55, 262);
			fly_target_y = irandom_range(16+40, 64);
			break;
    }
}



