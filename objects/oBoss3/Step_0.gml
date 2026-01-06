// STEP oBoss3
prev_x = x;
prev_y = y;

grounded = place_meeting(x, y + 1, oSolid);
collide_x = false;

// === ЛОГИКА СОСТОЯНИЙ ===
switch (state) {
    case BOSS3_STATE.IDLE:
        state_timer--;
        if (state_timer <= 0) {
            // Тут выбираешь следующую атаку
            boss_change_state(BOSS3_STATE.CHASE);
        }
        break;
        
    case BOSS3_STATE.CHASE:
        if (instance_exists(oPlayer)) {
            var target_x = oPlayer.x;
            var target_y = oPlayer.y + chase_y_offset;
            
            var dir_x = sign(target_x - x);
            if (dir_x != 0) {
                hsp += dir_x * chase_acceleration;
                hsp = clamp(hsp, -chase_max_speed, chase_max_speed);
                facing = dir_x;
            }
            
            var dir_y = sign(target_y - y);
            if (abs(target_y - y) > 4) {
                vsp += dir_y * chase_acceleration * 0.5;
                vsp = clamp(vsp, -chase_max_speed * 0.7, chase_max_speed * 0.7);
            } else {
                vsp *= 0.9;
            }
        }
        
        state_timer--;
        if (state_timer <= 0) {
            boss_change_state(BOSS3_STATE.MOVE_LEFT);
        }
        break;
        
    case BOSS3_STATE.SPAWN:
        state_timer--;
        if (state_timer <= 0) {
            boss_change_state(BOSS3_STATE.IDLE);
        }
        break;
        
    case BOSS3_STATE.MOVE_LEFT:
    case BOSS3_STATE.MOVE_RIGHT:
        // Движение задано в hsp, остановка по коллизии ниже
        break;
        
    case BOSS3_STATE.PARABOLA_LR:
    case BOSS3_STATE.PARABOLA_RL:
        parabola_timer++;
        var t = parabola_timer / parabola_duration;
        
        if (t >= 1) {
            x = parabola_end_x;
            y = parabola_end_y;
            hsp = 0;
            vsp = 0;
            boss_change_state(BOSS3_STATE.IDLE);
        } else {
            var new_x = lerp(parabola_start_x, parabola_end_x, t);
            var parabola_offset = 4 * parabola_height * t * (1 - t);
            var base_y = lerp(parabola_start_y, parabola_end_y, t);
            var new_y = base_y + parabola_offset;
            
            hsp = new_x - x;
            vsp = new_y - y;
        }
        break;
        
    case BOSS3_STATE.STUNNED:
        state_timer--;
        if (state_timer <= 0) {
            boss_change_state(stunned_next_state);
        }
        break;
}

// === ДВИЖЕНИЕ И КОЛЛИЗИИ ===
if (place_meeting(x + hsp, y, oSolid)) {
    while (!place_meeting(x + sign(hsp), y, oSolid)) {
        x += sign(hsp);
    }
    collide_x = true;
    hsp = 0;
    
    // MOVE_LEFT/RIGHT — врезался в стену, готово
    if (state == BOSS3_STATE.MOVE_LEFT || state == BOSS3_STATE.MOVE_RIGHT) {
        boss_change_state(BOSS3_STATE.IDLE);
    }
} else {
    x += hsp;
}

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

// === УРОН ===
var bullet = instance_place(x, y, oBullet);
if (bullet != noone) {
    hp -= bullet.damage;
    instance_destroy(bullet);
    
    if (hp <= 0) {
        instance_destroy();
    }
}
