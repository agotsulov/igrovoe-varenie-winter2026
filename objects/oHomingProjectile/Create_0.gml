// Inherit the parent event
event_inherited();

// Скорость движения
spd = 2;

// Поворот
turn_speed = 0;           // Текущая скорость поворота
turn_acceleration = 0.3;  // Ускорение поворота
turn_max_speed = 1;       // Максимальная скорость поворота (градусы/кадр)

if (instance_exists(oPlayer)) {
	dir = point_direction(x, y, oPlayer.x, oPlayer.y); 
}

lifetime = 60 * 5; 