// CREATE

hp = 5;
max_hp = 5;

// Движение
xsp = 0.0;
ysp = 0.0;
move_x = 0;

// Визуал

aura_rotation = 0;

// Normal animation tracking
current_normal_animation = noone;
normal_frame = 0;
normal_frame_speed = 0;

facing_left = false;
walkAnimation = sGatoWalk;
jumpAnimation = sGatoJump;
idleAnimation = sGatoIdle;
grabAnimation = sGatoGrab;
throwAnimation = sGatoShoot;
hurtAnimation = sGatoHurt;

// Animation control
current_override = noone;        // Which animation is currently overriding
override_frame = 0;
override_speed = 1;
override_playing = false;        // Track if override is playing

walk_speed_multiplier = 0.1;     // Adjust to match walk animation to xsp

// Jump animation control
jump_frame_2_min_ysp = -0.5;     // Minimum ysp for hang time frame
jump_frame_2_max_ysp = 0.5;      // Maximum ysp for hang time frame


// Горизонтальное движение
ground_accel = 0.4;      // Ускорение на земле
air_accel = 0.2;         // Ускорение в воздухе (меньше контроля)
ground_friction = 0.85;  // Трение на земле (0-1, чем меньше — тем быстрее остановка)
air_friction = 0.95;     // Трение в воздухе (больше — скользишь дольше)
max_speed = 3.5;

// Вертикальное движение
gravity_accel = 0.45;    // Гравитация
max_fall_speed = 10;     // Максимальная скорость падения
jump_speed = 5.5;        // Сила прыжка
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

inventory = true;

was_riding_boss = noone;

// КАМЕРА

// Camera Controller Initialization
goal_x = 0;
goal_y = 0;

inactive_timer = 60*15

shoot = function () {
    var offset = facing_x ? -8 : 8 // TODO: 8 заменить на растояние откуда вылетает пуля
    var bullet = instance_create_depth(x + offset, y-sprite_height/2, depth + 1, oBullet);
  
    bullet.hsp = facing_x;
    //bullet.vsp = facing_y;
	
	audio_play_sound(sfxToss,1,0)

    inventory = false
}


pickup = function () {
    var half_w = 10;
    var half_h = sprite_height / 2;
	
    var check_x = x + facing_x * half_w;
    var check_y = y;
    
    var item = collision_rectangle(
        check_x - half_w, check_y - half_h,
        check_x + half_w, check_y + half_h,
        oPickable, false, true
    );
    
    if (item != noone) {
        inventory = item.object_index;
		audio_play_sound(sfxGrabSuccess, 1, 0, 1.5)
        instance_destroy(item, false);
    }
	
	// Мешком убивать отцов 
	// Но так слишком легко, можно тупо стоять на одно месте
	/*
	var fathersmall = collision_rectangle(
        check_x - half_w, check_y - half_h,
        check_x + half_w, check_y + half_h,
        oFatherSmall, false, true
    );
	
	if (fathersmall != noone) {
      	audio_play_sound(sfxGrabSuccess, 1, 0, 1.5)
        instance_destroy(fathersmall);
    }
	*/
}

function trigger_hurt_animation() {
    sprite_index = sGatoHurt;
    image_index = 0;
    image_speed = 0.2;
    override_playing = true;
    current_override = sGatoHurt;
}

function trigger_grab_animation() {
	audio_play_sound(sfxSwing,1,0,1.5)
    sprite_index = sGatoGrab;
    image_index = 0;
    image_speed = 0.7;
    override_playing = true;
    current_override = sGatoGrab;
}

function trigger_throw_animation() {
    sprite_index = sGatoShoot;
    image_index = 0;
    image_speed = 1;
    override_playing = true;
    current_override = sGatoShoot;
}