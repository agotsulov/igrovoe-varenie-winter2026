// STEP
xsp = 0
ysp += grvt

var gp_connected = gamepad_is_connected(gp_index);

var btn_up = keyboard_check(vk_up) || (gp_connected && gamepad_button_check(gp_index, gp_padu));
var btn_down = keyboard_check(vk_down) || (gp_connected && gamepad_button_check(gp_index, gp_padd));
var btn_left = keyboard_check(vk_left) || (gp_connected && gamepad_button_check(gp_index, gp_padl));
var btn_right = keyboard_check(vk_right) || (gp_connected && gamepad_button_check(gp_index, gp_padr));
var btn_jump = keyboard_check(ord("Z")) || (gp_connected && gamepad_button_check(gp_index, gp_face1));
var btn_attack = keyboard_check(ord("X")) || (gp_connected && (gamepad_button_check(gp_index, gp_face2) || gamepad_button_check(gp_index, gp_face3)));
var btn_attack_pressed = keyboard_check_pressed(ord("X")) || (gp_connected && (gamepad_button_check_pressed(gp_index, gp_face2) || gamepad_button_check_pressed(gp_index, gp_face3)));


var move = 0;
if (btn_right) move = 1;
else if (btn_left) move = -1;

facing_x = 0
facing_y = 0

if (btn_right) facing_x = 1;
if (btn_left) facing_x = -1;
if (btn_up) facing_y = 1;
if (btn_down) facing_y = -1;

if (move != 0) {
  xsp = move * accel;
} else {
  xsp *= frctn
    if (abs(xsp) < 0.1) xsp = 0;
}

xsp = clamp(xsp, -max_speed, max_speed)
ysp = clamp(ysp, -100, max_fall_speed)

var on_solid = place_meeting(x, y + 1, oSolid);

on_ground = on_solid;

// Coyote time
if (on_ground) {
    coyote_timer = coyote_time_max;
} else {
    if (coyote_timer > 0) {
        coyote_timer -= 1;
    }
}


// Jump
if (btn_jump && (on_ground || coyote_timer > 0)) {
	ysp = -jump_speed;
    on_ground = false;
    coyote_timer = 0;
    jump_buffer = 0;
}

// Неуязвимость
if (invulnerable_timer > 0) {
    invulnerable_timer -= 1;
    if (invulnerable_timer <= 0) {
        invulnerable = false;
    }
}

// Move and collide platforms
if (xsp != 0) {
    if (place_meeting(x + xsp, y, oSolid)) {
        while (!place_meeting(x + sign(xsp), y, oSolid)) {
            x += sign(xsp);
        }
        xsp = 0;
    } else {
        x += xsp;
    }
}
if (ysp != 0) {
    // Проверяем столкновение с обычными solid
    var collision_solid = place_meeting(x, y + ysp, oSolid);
    
    // Обработка столкновения с oSolid
    if (collision_solid) {
        while (!place_meeting(x, y + sign(ysp), oSolid)) {
            y += sign(ysp);
        }
        ysp = 0;
	} else {
        // Свободное падение
        y += ysp;
    }
}

if (!invulnerable) {
    var enemy = instance_place(x, y, oEnemy);
    if (enemy != noone) {
		show_debug_message("dasedfasdgdsda")
        
        hp -= enemy.damage;
        invulnerable = true;
        invulnerable_timer = invulnerable_duration; 
    }
}


// Attack
if (inventory) { 
	if (btn_attack_pressed) {
		shoot()
	}
} else {
	if (btn_attack) {
		pickup()
	}
}


function shoot() {
	var offset = facing_x ? -8 : 8 // TODO: 8 заменить на растояние откуда вылетает пуля
	var bullet = instance_create_depth(x + offset, y - sprite_height / 2 + 1, depth + 1, oBullet);
  
	bullet.hsp = facing_x;
	//bullet.vsp = facing_y;

    inventory = false
}


function pickup() {
    var check_x = x + facing_x * sprite_width;
    var check_y = y;
    
    var half_w = sprite_width / 2;
    var half_h = sprite_height / 2;
    
    var item = collision_rectangle(
        check_x - half_w, check_y - half_h,
        check_x + half_w, check_y + half_h,
        oPickable, false, true
    );
    
    if (item != noone) {
        inventory = item.object_index;
        instance_destroy(item);
    }
}


if (hp < 1) {
	game_restart()	
}