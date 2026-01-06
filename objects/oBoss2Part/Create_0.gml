// Inherit the parent event
event_inherited();

father = noone

is_eye = false
//shoot_timer = 0;
//shoot_interval = 60 * 3; // 3 секунды (при 60 FPS)

// --- ПОЗИЦИИ (устанавливаются контроллером) ---
home_x = x;
home_y = y;
target_x = x;
target_y = y;

// --- ИДЕНТИФИКАЦИЯ ---
block_index = 0;       // индекс в сетке (0-11)
controller = noone;    // ссылка на контроллер

// --- ДВИЖЕНИЕ ---
move_speed = 12;       // скорость (устанавливается контроллером)
is_moving = false;     // флаг: летит ли сейчас
move_to_x = x;         // целевая точка X
move_to_y = y;         // целевая точка Y
move_direction = 0;    // направление в градусах

// --- ВИЗУАЛ ---
draw_color = c_red;    // цвет блока (можно менять)


hurt_timer = 30;

// --- ФУНКЦИЯ: НАЧАТЬ ДВИЖЕНИЕ ---
function start_move(_tx, _ty) {
    move_to_x = _tx;
    move_to_y = _ty;
    move_direction = point_direction(x, y, _tx, _ty);
    is_moving = true;
}

// --- ФУНКЦИЯ: ОСТАНОВИТЬСЯ ---
function stop_move() {
    is_moving = false;
    x = move_to_x;
    y = move_to_y;
}

