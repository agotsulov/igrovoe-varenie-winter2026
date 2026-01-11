// STEP oBoss3
prev_x = x;
prev_y = y;

grounded = place_meeting(x, y + 1, oSolid);
collide_x = false;

//move and collide
/*
if (place_meeting(x + hsp, y, oSolid)) {
    while (!place_meeting(x + sign(hsp), y, oSolid)) {
        x += sign(hsp);
    }
	collide_x = true
    hsp = 0;
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
*/
x += hsp
y += vsp

// === ЛОГИКА СОСТОЯНИЙ ===
switch (state) {
    case BOSS3_STATE.IDLE:
    case BOSS3_STATE.STUNNED_LIGHT:
    case BOSS3_STATE.STUNNED_HEAVY:
	case BOSS3_STATE.ATTACK_OR_SPAWN:
	case BOSS3_STATE.ATTACK:
    case BOSS3_STATE.SPAWN:
        state_timer--;
        if (state_timer <= 0) {
            boss_change_state();
        }
        break;
        
    case BOSS3_STATE.MOVE_LEFT:
	case BOSS3_STATE.MOVE_RIGHT:
	    var dist = point_distance(x, y, fly_target_x, fly_target_y);
    
	    if (dist <= fly_speed) {
	        x = fly_target_x;
	        y = fly_target_y;
	        hsp = 0;
	        vsp = 0;
	        boss_change_state();
	    } else {
	        var dir = point_direction(x, y, fly_target_x, fly_target_y);
	        hsp = lengthdir_x(fly_speed, dir);
	        vsp = lengthdir_y(fly_speed, dir);
	    }
	    break;
       
    case BOSS3_STATE.PARABOLA_LR:
	    parabola_timer++;
	    var t = parabola_timer / parabola_duration;
    
	    if (t >= 1) {
	        x = parabola_end_x;
	        y = parabola_end_y;
	        hsp = 0;
	        vsp = 0;
	        parabola_shooting = false;
	        boss_change_state();
	    } else {
	        var new_x = lerp(parabola_start_x, parabola_end_x, t);
	        var parabola_offset = power(sin(t * pi), 2) * parabola_height;
	        var base_y = lerp(parabola_start_y, parabola_end_y, t);
	        var new_y = base_y + parabola_offset;
        
	        hsp = new_x - x;
	        vsp = new_y - y;
        
	        // Стрельба вниз
	        var in_shoot_zone = (x >= parabola_shoot_start_x && x <= parabola_shoot_end_x);
        
	        if (in_shoot_zone) {
	            parabola_shoot_timer--;
	            if (parabola_shoot_timer <= 0) {
	                parabola_shooting = true;
	                parabola_shoot_timer = parabola_shoot_interval;
                
	                var proj = instance_create_layer(x, y+32, "Instances_1", oProjectile);
	                proj.hsp = 0;
	                proj.vsp = 1;
	                proj.sp = 3;
	            }
	        } else if (parabola_shooting && x > parabola_shoot_end_x) {
	            // Вышли из зоны — последний выстрел oRock
	            parabola_shooting = false;
	            var proj = instance_create_layer(x, y+32, "Instances_1", oRock);
	            proj.hsp = 0;
	            proj.vsp = 1;
	            proj.sp = 3;
	        }
	    }
	    break;
    
	case BOSS3_STATE.PARABOLA_RL:
	    parabola_timer++;
	    var t = parabola_timer / parabola_duration;
    
	    if (t >= 1) {
	        x = parabola_end_x;
	        y = parabola_end_y;
	        hsp = 0;
	        vsp = 0;
	        parabola_shooting = false;
	        boss_change_state();
	    } else {
	        var new_x = lerp(parabola_start_x, parabola_end_x, t);
	        var parabola_offset = power(sin(t * pi), 2) * parabola_height;
	        var base_y = lerp(parabola_start_y, parabola_end_y, t);
	        var new_y = base_y + parabola_offset;
        
	        hsp = new_x - x;
	        vsp = new_y - y;
        
	        // Стрельба вниз (для RL зона проверяется в обратном направлении)
	        var in_shoot_zone = (x <= parabola_shoot_end_x && x >= parabola_shoot_start_x);
        
	        if (in_shoot_zone) {
	            parabola_shoot_timer--;
	            if (parabola_shoot_timer <= 0) {
	                parabola_shooting = true;
	                parabola_shoot_timer = parabola_shoot_interval;
                
	                var proj = instance_create_layer(x, y+32, "Instances_1", oProjectile);
	                proj.hsp = 0;
	                proj.vsp = 1;
	                proj.sp = 3;
	            }
	        } else if (parabola_shooting && x < parabola_shoot_start_x) {
	            // Вышли из зоны — последний выстрел oRock
	            parabola_shooting = false;
	            var proj = instance_create_layer(x, y+32, "Instances_1", oRock);
	            proj.hsp = 0;
	            proj.vsp = 1;
	            proj.sp = 3;
	        }
	    }
	    break;
        
		case BOSS3_STATE.FLY_TO_RANDOM:
		    if (fly_shooting) {
		        // Режим стрельбы
		        fly_shoot_timer--;
		        fly_shoot_cooldown--;
        
		        if (fly_shoot_cooldown <= 0) {
		            fly_shoot_cooldown = fly_shoot_interval;
            
		            // Два снаряда вниз
		            var proj1 = instance_create_layer(x - fly_shoot_offset, y, "Instances_1", oProjectile);
		            proj1.hsp = 0;
		            proj1.vsp = 1;
		            proj1.sp = 3;
            
		            var proj2 = instance_create_layer(x + fly_shoot_offset, y, "Instances_1", oProjectile);
		            proj2.hsp = 0;
		            proj2.vsp = 1;
		            proj2.sp = 3;
		        }
        
		        if (fly_shoot_timer <= 0) {
		            // Последние выстрелы — oRock
		            var rock1 = instance_create_layer(x - fly_shoot_offset, y, "Instances_1", oRock);
		            rock1.hsp = 0;
		            rock1.vsp = 1;
		            rock1.sp = 3;
            
		            var rock2 = instance_create_layer(x + fly_shoot_offset, y, "Instances_1", oRock);
		            rock2.hsp = 0;
		            rock2.vsp = 1;
		            rock2.sp = 3;
            
		            fly_shooting = false;
		            boss_change_state();
		        }
		    } else {
		        // Режим полёта
		        var dist = point_distance(x, y, fly_target_x, fly_target_y);
        
		        if (dist <= fly_speed) {
		            x = fly_target_x;
		            y = fly_target_y;
		            hsp = 0;
		            vsp = 0;
            
		            // Начинаем стрельбу
		            fly_shooting = true;
		            fly_shoot_timer = fly_shoot_duration;
		            fly_shoot_cooldown = 0;
		        } else {
		            var dir = point_direction(x, y, fly_target_x, fly_target_y);
		            hsp = lengthdir_x(fly_speed, dir);
		            vsp = lengthdir_y(fly_speed, dir);
		        }
		    }
		    break;
	
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
