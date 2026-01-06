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

// Если игрок неуязвим — он не может стоять на боссе, проваливается сквозь
if (!invulnerable) {
    // Проверяем, стоим ли мы СВЕРХУ на боссе
    var boss_below = instance_place(x, y + 1, oBoss1);
    if (boss_below != noone) {
        if (bbox_bottom <= boss_below.bbox_top + 2) {
            riding_boss = boss_below;
        }
    }
}

// Если едем на боссе — передаём его движение
if (riding_boss != noone) {
    var new_x = x + riding_boss.delta_x;
    var new_y = y + riding_boss.delta_y;
    
    // Проверяем, не раздавит ли нас о потолок/стену
    var would_be_crushed = place_meeting(new_x, new_y, oSolid);
    
    if (would_be_crushed) {
        // Раздавливание — получаем урон!
        if (!invulnerable) {
            hp -= 1;
            invulnerable = true;
            invulnerable_timer = invulnerable_duration;
        }
        // Сбрасываем езду — проваливаемся сквозь босса
        riding_boss = noone;
        was_riding_boss = noone;
    } else {
        // Безопасно двигаемся с боссом
        x = new_x;
        y = new_y;
        
        // Корректируем если толкает в стену по X
        if (place_meeting(x, y, oSolid)) {
            x -= riding_boss.delta_x;
            while (place_meeting(x, y, oSolid)) {
                x -= sign(riding_boss.delta_x);
            }
        }
    }
}

// === ВЫТАЛКИВАНИЕ ИЗ БОССА ===
// Только если НЕ неуязвим (иначе проваливаемся сквозь)
if (!invulnerable) {
    var boss_overlap = instance_place(x, y, oBoss1);
    if (boss_overlap != noone) {
        var should_push_up = (ysp >= 0) || (was_riding_boss == boss_overlap);
        
        var player_center_y = (bbox_top + bbox_bottom) / 2;
        var boss_center_y = (boss_overlap.bbox_top + boss_overlap.bbox_bottom) / 2;
        
        if (should_push_up && player_center_y < boss_center_y) {
            // Проверяем, не раздавит ли выталкивание нас в потолок
            var push_y = boss_overlap.bbox_top - (bbox_bottom - y);
            if (!place_meeting(x, push_y, oSolid)) {
                y = push_y;
                ysp = 0;
                riding_boss = boss_overlap;
            } else {
                // Раздавливание при выталкивании
                if (!invulnerable) {
                    hp -= 1;
                    invulnerable = true;
                    invulnerable_timer = invulnerable_duration;
                }
            }
        }
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
	if (move_x < 0) {
		facing_left = true	
	} else {
		facing_left = false
	}
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
        var boss_check = instance_place(x, y + ysp, oBoss1);
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
        var boss_inst = instance_place(x, y + ysp, oBoss1);
        while (!place_meeting(x, y + 1, oBoss1)) {
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
			trigger_hurt_animation()
        }
    }
}

// === АТАКА ===
if (inventory) { 
    if (btn_attack_pressed) {
        //shoot();
		trigger_throw_animation()
    }
} else {
    if (btn_attack_pressed) {
        //pickup();
		trigger_grab_animation()
    }
}


// === СМЕРТЬ ===
if (hp < 1) {
    game_restart();
}


// Check if override animation just finished
if (override_playing) {
    if (image_index >= sprite_get_number(sprite_index) - 1) {
        // Override animation completed
        override_playing = false;
        current_override = noone;
    }
}

// Only update normal animations if no override is playing
if (!override_playing) {
    // Update sprite based on state
    if (!on_ground) {
        sprite_index = sGatoJump;
        image_speed = 0; // We'll set frame manually
    } else if (xsp != 0) {
        sprite_index = sGatoWalk;
        image_speed = abs(xsp) * 0.5; // Adjust multiplier as needed
    } else {
        sprite_index = sGatoIdle;
        image_speed = 1;
    }
}