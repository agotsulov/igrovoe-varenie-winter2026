// lifetime
lifetime--;
if (lifetime <= 0) {
    instance_destroy();
}


// Pool self destroy 
var pickable_count = instance_number(oPickable);
if (pickable_count > 4) {
    instance_destroy();
}


// Гравитация
vsp += grav;

// Горизонтальное трение (замедление)
hsp *= friction_h;

// Вертикальное движение + отскок от пола/потолка
if (place_meeting(x, y + vsp, oSolid)) {
    // Подходим вплотную к поверхности
    while (!place_meeting(x, y + sign(vsp), oSolid)) {
        y += sign(vsp);
    }
    // Отскок с затуханием
    vsp = -vsp * bounce;
    
    // Остановка если скорость мала
    if (abs(vsp) < min_speed) {
        vsp = 0;
    } else {
		audio_play_sound(sfxBounce, 1, 0)
	}
}

// Горизонтальное движение + отскок от стен
if (place_meeting(x + hsp, y, oSolid)) {
    while (!place_meeting(x + sign(hsp), y, oSolid)) {
        x += sign(hsp);
    }
    // Отскок с затуханием
    hsp = -hsp * bounce;
    
    if (abs(hsp) < min_speed) {
        hsp = 0;
    }
}

// Применяем движение
x += hsp;
y += vsp;