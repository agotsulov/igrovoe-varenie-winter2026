// Inherit the parent event
event_inherited();

shoot_timer += 1;

if (shoot_timer >= shoot_interval) {
	shoot_timer = 0;
    
	if (instance_exists(oPlayer)) {
	    var dir = point_direction(x, y, oPlayer.x, oPlayer.y);
        
	    var proj = instance_create_layer(x, y, layer, oRock);
	    proj.hsp = lengthdir_x(1, dir);
	    proj.vsp = lengthdir_y(1, dir);
		proj.sp = 2
		audio_play_sound(sfxEnemyFire,1,0)
	}
}