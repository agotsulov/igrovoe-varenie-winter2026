// STEP oBoss3
prev_x = x;
prev_y = y;

grounded = place_meeting(x, y + 1, oSolid);

collide_x = false;

// === ЛОГИКА СОСТОЯНИЙ (до движения) ===
switch (state) {
    case BOSS3_STATE.IDLE:
        state_timer--;
        if (state_timer <= 0) {
            boss_goto_next_state();
        }
        break;
        
    case BOSS3_STATE.CHASE:
        // Преследуем игрока по оси X, пытаемся оказаться над ним
        if (instance_exists(oPlayer)) {
            var target_x = oPlayer.x;
            var target_y = oPlayer.y + chase_y_offset;
            
            // Движение по X с ускорением
            var dir_x = sign(target_x - x);
            if (dir_x != 0) {
                hsp += dir_x * chase_acceleration;
                hsp = clamp(hsp, -chase_max_speed, chase_max_speed);
                facing = dir_x;
            }
        }
        
        state_timer--;
        if (state_timer <= 0) {
            boss_goto_next_state();
        }
        break;
        
    case BOSS3_STATE.SPAWN:
        // Ждем немного после спавна
        state_timer--;
        if (state_timer <= 0) {
            boss_goto_next_state();
        }
        break;
        
    case BOSS3_STATE.MOVE_LEFT:
        hsp = -(state_params[$ "speed"] ?? move_speed);
        vsp = 0;
        // Остановка при столкновении обрабатывается ниже через collide_x
        break;
        
    case BOSS3_STATE.MOVE_RIGHT:
        hsp = state_params[$ "speed"] ?? move_speed;
        vsp = 0;
        // Остановка при столкновении обрабатывается ниже через collide_x
        break;
        
    case BOSS3_STATE.PARABOLA_LR:
    case BOSS3_STATE.PARABOLA_RL:
        // Движение по параболе
        parabola_timer++;
        var t = parabola_timer / parabola_duration; // прогресс от 0 до 1
        
        if (t >= 1) {
            // Достигли конца параболы
            x = parabola_end_x;
            y = parabola_end_y;
            hsp = 0;
            vsp = 0;
            boss_goto_next_state();
        } else {
            // Линейная интерполяция по X
            var new_x = lerp(parabola_start_x, parabola_end_x, t);
            
            // Парабола по Y: опускаемся в середине пути
            // Используем формулу параболы: 4 * h * t * (1 - t) дает максимум h при t = 0.5
            var parabola_offset = 4 * parabola_height * t * (1 - t);
            var base_y = lerp(parabola_start_y, parabola_end_y, t);
            var new_y = base_y + parabola_offset;
            
            // Вычисляем скорости для коллизий
            hsp = new_x - x;
            vsp = new_y - y;
        }
        break;
        
    case BOSS3_STATE.STUNNED:
        // Босс оглушен - стоит на месте
        hsp = 0;
        vsp = 0;
        state_timer--;
        if (state_timer <= 0) {
            boss_goto_next_state();
        }
        break;
}

// === ДВИЖЕНИЕ И КОЛЛИЗИИ ===
// Горизонтальное движение
if (place_meeting(x + hsp, y, oSolid)) {
    while (!place_meeting(x + sign(hsp), y, oSolid)) {
        x += sign(hsp);
    }
    collide_x = true;
    hsp = 0;
    
    // Если были в состоянии движения к стене - переходим в next state
    if (state == BOSS3_STATE.MOVE_LEFT || state == BOSS3_STATE.MOVE_RIGHT) {
        boss_goto_next_state();
    }
} else {
    x += hsp;
}

// Вертикальное движение
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

// === ПОЛУЧЕНИЕ УРОНА ===
var bullet = instance_place(x, y, oBullet);
if (bullet != noone) {
    hp -= bullet.damage;
    instance_destroy(bullet);
    
    if (hp <= 0) {
        // Смерть босса
        instance_destroy();
		for (var i = 0; i < 20; i++) {
		    var randX = random_range(bbox_left, bbox_right);
		    var randY = random_range(bbox_top, bbox_bottom);
		    instance_create_layer(randX, randY, layer, oDoublePoof);
		}
    }
}
