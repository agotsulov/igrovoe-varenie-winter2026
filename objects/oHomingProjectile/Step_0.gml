// Inherit the parent event
event_inherited();

// Время жизни
lifetime--;
if (lifetime <= 0) {
    instance_destroy();
    exit;
}

// Целевой угол к игроку
if (instance_exists(oPlayer)) {
    var target_dir = point_direction(x, y, oPlayer.x, oPlayer.y);
    
    // Разница углов (-180 до 180)
    var angle_diff = angle_difference(target_dir, dir);
    
    // Ускоряем поворот в нужную сторону
    if (angle_diff > 0) {
        turn_speed += turn_acceleration;
    } else if (angle_diff < 0) {
        turn_speed -= turn_acceleration;
    }
    
    // Ограничиваем скорость поворота
    turn_speed = clamp(turn_speed, -turn_max_speed, turn_max_speed);
    
    // Не поворачиваем больше чем нужно
    if (abs(turn_speed) > abs(angle_diff)) {
        turn_speed = angle_diff;
    }
    
    // Применяем поворот
    dir += turn_speed;
}

// Движение
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);

// Поворот спрайта
image_angle = dir;

// Уничтожение при столкновении
if (place_meeting(x, y, oSolid)) {
    instance_destroy();
}