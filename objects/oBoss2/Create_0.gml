// Inherit the parent event
event_inherited();

max_hp = 10
hp = max_hp

// --- НАСТРОЙКИ СЕТКИ ---
grid_width = 3;        // блоков по горизонтали
grid_height = 4;       // блоков по вертикали  
block_size = 16;       // размер блока в пикселях

// --- ПОЗИЦИИ БОССА ---
home_x = 224+32;          // начальная позиция X
home_y = 98;          // начальная позиция Y
target_x = 16;        // целевая позиция X (куда перелетает)
target_y = 98;        // целевая позиция Y

// --- СКОРОСТЬ И ТАЙМИНГИ ---
block_speed = 3.5;              // скорость полёта блока (пикселей/кадр)
delay_between_blocks = 8;      // задержка между вылетами (кадры)
delay_after_scatter = 60;      // пауза после разлёта (кадры)
delay_after_gather = 90;       // пауза после сборки (кадры)

// --- СОСТОЯНИЯ ---
enum BOSS_STATE2 {
    IDLE,              // ожидание перед атакой
    SCATTER,           // блоки летят к цели
    SCATTERED_WAIT,    // пауза в целевой точке
    GATHER,            // блоки возвращаются
    GATHER_WAIT        // пауза после возврата
}
state = BOSS_STATE2.IDLE;

// --- ХРАНИЛИЩЕ БЛОКОВ ---
blocks = [];

// --- ПОРЯДОК ВЫЛЕТА ---
scatter_order = [
    0, 4, 8, 
	1, 5, 9, 
	2, 6, 10,
	3, 7, 11
];

// scatter_order = [0, 4, 8, 1, 5, 9, 2, 6, 10, 3, 7, 11];
// gather_order = [11, 7, 3, 10, 6, 2, 9, 5, 1, 8, 4, 0];

gather_order = [
    11, 7, 3,
	10, 6, 2,
	9, 5, 1,
	8, 4, 0
];

blocks_sprites = [
	sBullet, sProjectile, sSolid,
	sSolid,	sSolid, sSolid,
	sSolid, sSolid, sSolid,
	sSolid, sSolid, sSolid,
]

block_is_eye = [
	false, false, false,
	false, true, false,
	false, false, false,
	false, false, false,
]

// --- ВНУТРЕННИЕ ПЕРЕМЕННЫЕ ---
current_order_index = 0;
timer = 0;
waiting_for_block = false;

// --- ФУНКЦИЯ СОЗДАНИЯ БЛОКОВ ---
function create_blocks() {
    for (var row = 0; row < grid_height; row++) {
        for (var col = 0; col < grid_width; col++) {
            var idx = row * grid_width + col;
            
            var bx = home_x + col * block_size;
            var by = home_y + row * block_size;
            var tx = target_x + col * block_size;
            var ty = target_y + row * block_size;
            
            var blk = instance_create_layer(bx, by, "Instances", oBoss2Part);
            blk.home_x = bx;
            blk.home_y = by;
            blk.target_x = tx;
            blk.target_y = ty;
            blk.block_index = idx;
            blk.controller = id;
            blk.move_speed = block_speed;
			blk.sprite_index = blocks_sprites[idx]
			blk.father = self
            blk.is_eye = block_is_eye[idx]
			
            blocks[idx] = blk;
        }
    }
}

// Создаём блоки при старте
create_blocks();

// Начальная пауза
timer = 60;

