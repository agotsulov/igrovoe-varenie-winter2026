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

// FSM состояния
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

// Для отслеживания предыдущего состояния
previous_state = BOSS3_STATE.IDLE;

// Следующее состояние (после текущего)
next_state = noone;
next_state_params = {};

// Параметры текущего состояния (передаются при смене)
state_params = {};

// === НАСТРОЙКИ СОСТОЯНИЙ ===

// IDLE
idle_delay = 60;

// CHASE - преследование игрока
chase_acceleration = 0.3;      // ускорение
chase_max_speed = 4;           // максимальная скорость
chase_duration = 180;          // длительность преследования (в кадрах)
chase_y_offset = -48;          // на сколько выше игрока пытается быть босс

// SPAWN
spawn_offset_x = 48;           // отступ по X для спавна oFatherSmall
spawn_offset_y = 0;            // отступ по Y для спавна

// MOVE_LEFT / MOVE_RIGHT
move_speed = 3;                // скорость движения к стене

// PARABOLA - настройки параболы
parabola_start_x = 0;          // начальная точка X (задается при входе в состояние)
parabola_start_y = 0;          // начальная точка Y
parabola_end_x = 0;            // конечная точка X
parabola_end_y = 0;            // конечная точка Y
parabola_height = 80;          // глубина прогиба параболы (на сколько опускается)
parabola_duration = 120;       // длительность полета в кадрах
parabola_timer = 0;            // текущий таймер

// Настройки конечных точек для парабол (можно менять)
parabola_lr_end_x = room_width - 64;   // конечная точка для PARABOLA_LR
parabola_rl_end_x = 64;                 // конечная точка для PARABOLA_RL
parabola_target_y = 0;                  // целевая высота Y (задается динамически или вручную)

// STUNNED - дефолтная длительность если не передана
stun_time_default = 60;

// Общий таймер состояния
state = BOSS3_STATE.IDLE;
state_timer = idle_delay;

// === ФУНКЦИЯ СМЕНЫ СОСТОЯНИЯ ===
// _params - struct с параметрами:
//   duration - длительность состояния (в кадрах)
//   next - следующее состояние после этого
//   next_params - параметры для следующего состояния
//   ... любые другие параметры для конкретного состояния
//
// Примеры:
//   boss_change_state(BOSS3_STATE.MOVE_LEFT);
//   boss_change_state(BOSS3_STATE.STUNNED, { duration: 30, next: BOSS3_STATE.MOVE_RIGHT });
//   boss_change_state(BOSS3_STATE.PARABOLA_LR, { end_x: 500, height: 100 });

boss_change_state = function(_new_state, _params = {}) {
    previous_state = state;
    state = _new_state;
    state_params = _params;
    
    // Сохраняем next state если передан
    next_state = _params[$ "next"] ?? noone;
    next_state_params = _params[$ "next_params"] ?? {};
    
    switch (_new_state) {
        case BOSS3_STATE.IDLE:
            state_timer = _params[$ "duration"] ?? idle_delay;
            hsp = 0;
            vsp = 0;
            break;
            
        case BOSS3_STATE.CHASE:
            state_timer = _params[$ "duration"] ?? chase_duration;
            break;
            
        case BOSS3_STATE.SPAWN:
            var _offset_x = _params[$ "offset_x"] ?? spawn_offset_x;
            var _offset_y = _params[$ "offset_y"] ?? spawn_offset_y;
            
            var spawn1 = instance_create_layer(x - _offset_x, y + _offset_y, layer, oFatherSmall);
            spawn1.facing = -1;
            
            var spawn2 = instance_create_layer(x + _offset_x, y + _offset_y, layer, oFatherSmall);
            spawn2.facing = 1;
            
            state_timer = _params[$ "duration"] ?? 30;
            break;
            
        case BOSS3_STATE.MOVE_LEFT:
            hsp = -(_params[$ "speed"] ?? move_speed);
            vsp = 0;
            break;
            
        case BOSS3_STATE.MOVE_RIGHT:
            hsp = _params[$ "speed"] ?? move_speed;
            vsp = 0;
            break;
            
        case BOSS3_STATE.PARABOLA_LR:
            parabola_start_x = x;
            parabola_start_y = y;
            parabola_end_x = _params[$ "end_x"] ?? parabola_lr_end_x;
            parabola_end_y = _params[$ "end_y"] ?? y;
            parabola_height = _params[$ "height"] ?? parabola_height;
            parabola_duration = _params[$ "duration"] ?? parabola_duration;
            parabola_timer = 0;
            hsp = 0;
            vsp = 0;
            break;
            
        case BOSS3_STATE.PARABOLA_RL:
            parabola_start_x = x;
            parabola_start_y = y;
            parabola_end_x = _params[$ "end_x"] ?? parabola_rl_end_x;
            parabola_end_y = _params[$ "end_y"] ?? y;
            parabola_height = _params[$ "height"] ?? parabola_height;
            parabola_duration = _params[$ "duration"] ?? parabola_duration;
            parabola_timer = 0;
            hsp = 0;
            vsp = 0;
            break;
            
        case BOSS3_STATE.STUNNED:
            hsp = 0;
            vsp = 0;
            state_timer = _params[$ "duration"] ?? stun_time_default;
            break;
    }
}

// === ВСПОМОГАТЕЛЬНАЯ ФУНКЦИЯ ДЛЯ ПЕРЕХОДА В NEXT STATE ===
boss_goto_next_state = function() {
    if (next_state != noone) {
        var _next = next_state;
        var _next_params = next_state_params;
        next_state = noone;
        next_state_params = {};
        boss_change_state(_next, _next_params);
    } else {
        boss_change_state(BOSS3_STATE.IDLE);
    }
}
