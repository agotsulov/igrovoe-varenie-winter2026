// STEP

// === ВВОД ===
var gp_connected = gamepad_is_connected(gp_index);

var btn_left = keyboard_check(vk_left) || (gp_connected && gamepad_button_check(gp_index, gp_padl));
var btn_right = keyboard_check(vk_right) || (gp_connected && gamepad_button_check(gp_index, gp_padr));
var btn_up = keyboard_check(vk_up) || (gp_connected && gamepad_button_check(gp_index, gp_padu));
var btn_down = keyboard_check(vk_down) || (gp_connected && gamepad_button_check(gp_index, gp_padd));

var btn_jump = keyboard_check(ord("Z")) || (gp_connected && gamepad_button_check(gp_index, gp_face1));
var btn_jump_pressed = keyboard_check_pressed(ord("Z")) || (gp_connected && gamepad_button_check_pressed(gp_index, gp_face1));
var btn_jump_released = keyboard_check_released(ord("Z")) || (gp_connected && gamepad_button_check_released(gp_index, gp_face1));

var btn_attack = keyboard_check(ord("X")) || (gp_connected && (gamepad_button_check(gp_index, gp_face2) || gamepad_button_check(gp_index, gp_face3)));
var btn_attack_pressed = keyboard_check_pressed(ord("X")) || (gp_connected && (gamepad_button_check_pressed(gp_index, gp_face2) || gamepad_button_check_pressed(gp_index, gp_face3)));

// === RIDING PLATFORM (oBoss) ===
var riding_boss = noone;

// Проверяем, стоим ли мы СВЕРХУ на боссе
var boss_below = instance_place(x, y + 1, oBoss);
if (boss_below != noone) {
    if (bbox_bottom <= boss_below.bbox_top + 2) {
        riding_boss = boss_below;
    }
}

// Если едем на боссе — передаём его движение
if (riding_boss != noone) {
    x += riding_boss.delta_x;
    y += riding_boss.delta_y;
    
    // Корректируем если толкает в стену
    if (place_meeting(x, y, oSolid)) {
        x -= riding_boss.delta_x;
        while (place_meeting(x, y, oSolid)) {
            x -= sign(riding_boss.delta_x);
        }
    }
}

// === ВЫТАЛКИВАНИЕ ИЗ БОССА ===
// Если оказались внутри босса — выталкиваем наверх
var boss_overlap = instance_place(x, y, oBoss);
if (boss_overlap != noone) {
    // Проверяем: мы падаем ИЛИ были на боссе в прошлом кадре
    var should_push_up = (ysp >= 0) || (was_riding_boss == boss_overlap);
    
    // И наш центр выше центра босса (мы сверху, а не сбоку/снизу)
    var player_center_y = (bbox_top + bbox_bottom) / 2;
    var boss_center_y = (boss_overlap.bbox_top + boss_overlap.bbox_bottom) / 2;
    
    if (should_push_up && player_center_y < boss_center_y) {
        // Выталкиваем на верх босса
        y = boss_overlap.bbox_top - (bbox_bottom - y);
        ysp = 0;
        riding_boss = boss_overlap;
    }
}

// Запоминаем для следующего кадра
was_riding_boss = riding_boss;


// Направление движения
var move_x = btn_right - btn_left;

// Обновляем facing (только когда есть ввод)
if (move_x != 0) facing_x = move_x;
facing_y = btn_up - btn_down;


// === ПРОВЕРКА ЗЕМЛИ ===
var on_solid = place_meeting(x, y + 1, oSolid);
var on_boss = (riding_boss != noone);
on_ground = on_solid || on_boss;


// === ГОРИЗОНТАЛЬНОЕ ДВИЖЕНИЕ ===
var current_accel = on_ground ? ground_accel : air_accel;
var current_friction = on_ground ? ground_friction : air_friction;

if (move_x != 0) {
    // Ускорение
    xsp += move_x * current_accel;
} else {
    // Трение (замедление)
    xsp *= current_friction;
    if (abs(xsp) < 0.1) xsp = 0;
}

// Ограничение скорости
xsp = clamp(xsp, -max_speed, max_speed);


// === ВЕРТИКАЛЬНОЕ ДВИЖЕНИЕ ===

// Coyote time
if (on_ground) {
    coyote_timer = coyote_time_max;
    is_jumping = false;
} else {
    if (coyote_timer > 0) coyote_timer--;
}

// Jump buffer — запоминаем нажатие прыжка
if (btn_jump_pressed) {
    jump_buffer = jump_buffer_max;
}
if (jump_buffer > 0) jump_buffer--;

// Прыжок
var can_jump = (on_ground || coyote_timer > 0);
if (jump_buffer > 0 && can_jump) {
    ysp = -jump_speed;
    is_jumping = true;
    coyote_timer = 0;
    jump_buffer = 0;
}

// Variable jump height — отпустил кнопку раньше = прыжок ниже
if (btn_jump_released && is_jumping && ysp < 0) {
    ysp *= 0.5;  // Резко уменьшаем скорость вверх
    is_jumping = false;
}

// Гравитация
var current_gravity = gravity_accel;

// Уменьшенная гравитация при удержании прыжка (пока летим вверх)
if (btn_jump && ysp < 0 && is_jumping) {
    current_gravity = jump_hold_gravity;
}

ysp += current_gravity;
ysp = clamp(ysp, -100, max_fall_speed);


// === КОЛЛИЗИИ ===

// Горизонтальные
if (xsp != 0) {
    if (place_meeting(x + xsp, y, oSolid)) {
        // Подходим вплотную к стене
        while (!place_meeting(x + sign(xsp), y, oSolid)) {
            x += sign(xsp);
        }
        xsp = 0;
    } else {
        x += xsp;
    }
}

// Вертикальные
if (ysp != 0) {
    // Проверяем solid
    var hit_solid = place_meeting(x, y + ysp, oSolid);
    
    // Проверяем босса (только при падении!)
    var hit_boss = false;
    if (ysp > 0) {  // Только когда падаем вниз
        var boss_check = instance_place(x, y + ysp, oBoss);
        if (boss_check != noone && bbox_bottom <= boss_check.bbox_top + ysp) {
            hit_boss = true;
        }
    }
    
    if (hit_solid) {
        while (!place_meeting(x, y + sign(ysp), oSolid)) {
            y += sign(ysp);
        }
        if (ysp > 0) is_jumping = false;
        ysp = 0;
    } else if (hit_boss) {
        // Приземляемся на босса
        var boss_inst = instance_place(x, y + ysp, oBoss);
        while (!place_meeting(x, y + 1, oBoss)) {
            y += 1;
        }
        is_jumping = false;
        ysp = 0;
    } else {
        y += ysp;
    }
}


// === НЕУЯЗВИМОСТЬ ===
if (invulnerable_timer > 0) {
    invulnerable_timer--;
    if (invulnerable_timer <= 0) {
        invulnerable = false;
    }
}


// === УРОН ОТ ВРАГОВ ===
if (!invulnerable) {
    var enemy = instance_place(x, y, oEnemy);
    if (enemy != noone) {
        // Если это босс и мы стоим на нём сверху — НЕ получаем урон
        var is_riding_this_enemy = (enemy == riding_boss);
        
        if (!is_riding_this_enemy) {
            hp -= enemy.damage;
            invulnerable = true;
            invulnerable_timer = invulnerable_duration;
            
            // Отбрасывание
            var knockback_dir = sign(x - enemy.x);
            if (knockback_dir == 0) knockback_dir = 1;
            xsp = knockback_dir * 3;
            ysp = -3;
        }
    }
}

// === АТАКА ===
if (inventory) { 
    if (btn_attack_pressed) {
        shoot();
    }
} else {
    if (btn_attack) {
        pickup();
    }
}


// === СМЕРТЬ ===
if (hp < 1) {
    game_restart();
}