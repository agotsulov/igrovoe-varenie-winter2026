
if (is_moving) {
    var dist = point_distance(x, y, move_to_x, move_to_y);
    
    if (dist <= move_speed) {
        // Достигли цели
        stop_move();
    } else {
        // Летим дальше
        x += lengthdir_x(move_speed, move_direction);
        y += lengthdir_y(move_speed, move_direction);
    }
}


// Boss2 damage
var bullet = instance_place(x, y, oBullet);
if (bullet != noone and father != noone) {
	father.hp -= bullet.damage;
	instance_destroy(bullet)
}
/*
if (is_eye) {
	shoot_timer += 1;

	if (shoot_timer >= shoot_interval) {
	    shoot_timer = 0;
    
	    if (instance_exists(oPlayer)) {
	        var dir = point_direction(x, y, oPlayer.x, oPlayer.y);
        
	        var proj = instance_create_layer(x, y, layer, oProjectile);
	        proj.hsp = lengthdir_x(1, dir);
	        proj.vsp = lengthdir_y(1, dir);
	    }
	}
}*/