// Время жизни
/*
lifetime -= 1;
if (lifetime <= 0) {
    instance_destroy();
    exit;
}
*/


// Получение урона
var bullet = instance_place(x, y, oBullet);
if (bullet != noone) {
	instance_destroy(bullet)
	instance_destroy(self)
}

// Гравитация
vsp += grv;

// Коллизия с полом (вертикальное движение)
if (place_meeting(x, y + vsp, oSolid)) {
    while (!place_meeting(x, y + sign(vsp), oSolid)) {
        y += sign(vsp);
    }
    vsp = 0;
}
y += vsp;


// Горизонтальное движение — только на земле
var on_ground = place_meeting(x, y + 1, oSolid);

if (on_ground) {
    var hsp = move_speed * facing;
    
    // Разворот у стены
    if (place_meeting(x + hsp, y, oSolid)) {
        facing *= -1;
        hsp = move_speed * facing;
    }
	// ЕСЛИ НАДО разворот у края платформы 
	//if (!place_meeting(x + (move_speed * facing), y + 1, oSolid)) {
	//    facing *= -1;
	//}
    
    x += hsp;
}
