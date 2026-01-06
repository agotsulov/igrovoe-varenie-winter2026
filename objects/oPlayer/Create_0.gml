// CREATE

hp = 4;
max_hp = 4;

// Движение
xsp = 0.0;
ysp = 0.0;

// Горизонтальное движение
ground_accel = 0.8;      // Ускорение на земле
air_accel = 0.5;         // Ускорение в воздухе (меньше контроля)
ground_friction = 0.85;  // Трение на земле (0-1, чем меньше — тем быстрее остановка)
air_friction = 0.95;     // Трение в воздухе (больше — скользишь дольше)
max_speed = 4.5;

// Вертикальное движение
gravity_accel = 0.45;    // Гравитация
max_fall_speed = 10;     // Максимальная скорость падения
jump_speed = 8.5;        // Сила прыжка
jump_hold_gravity = 0.25; // Гравитация при удержании прыжка (для variable jump)

// Буферы и таймеры
coyote_time_max = 6;
coyote_timer = 0;
jump_buffer_max = 8;
jump_buffer = 0;
is_jumping = false;      // Для variable jump height

on_ground = false;

// Ввод
deadzone = 0.25;  
gp_index = 0;

facing_x = 1;  // По умолчанию смотрит вправо
facing_y = 0;

// Боевые таймеры
atk_timer = 0;
dmg_timer = 0;

invulnerable = false;
invulnerable_timer = 0;
invulnerable_duration = 60;

inventory = false;

was_riding_boss = noone;

shoot = function () {
	show_debug_message("SHOOT")
    var offset = facing_x ? -8 : 8 // TODO: 8 заменить на растояние откуда вылетает пуля
    var bullet = instance_create_depth(x + offset, y - sprite_height, depth + 1, oBullet);
  
    bullet.hsp = facing_x;
    //bullet.vsp = facing_y;

    inventory = false
}


pickup = function () {
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

