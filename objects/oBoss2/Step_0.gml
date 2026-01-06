
switch (state) {    
    // --- ОЖИДАНИЕ ПЕРЕД АТАКОЙ ---
    case BOSS_STATE2.IDLE:
        timer--;
        if (timer <= 0) {
            state = BOSS_STATE2.SCATTER;
            current_order_index = 0;
            timer = 0;
            waiting_for_block = false;
        }
        break;
    
    // --- РАЗЛЁТ БЛОКОВ ---
    case BOSS_STATE2.SCATTER:
        if (waiting_for_block) {
            // Ждём пока текущий блок долетит
            var blk_idx = scatter_order[current_order_index - 1];
            if (!blocks[blk_idx].is_moving) {
                waiting_for_block = false;
                timer = delay_between_blocks;
            }
        } else {
            timer--;
            if (timer <= 0) {
                if (current_order_index < array_length(scatter_order)) {
                    // Отправляем следующий блок
                    var blk_idx = scatter_order[current_order_index];
                    var blk = blocks[blk_idx];
                    blk.start_move(blk.target_x, blk.target_y);
                    current_order_index++;
                    waiting_for_block = true;
                } else {
                    // Все отправлены - ждём последний
                    var last_idx = scatter_order[array_length(scatter_order) - 1];
                    if (!blocks[last_idx].is_moving) {
                        state = BOSS_STATE2.SCATTERED_WAIT;
                        timer = delay_after_scatter;
                    }
                }
            }
        }
        break;
    
    // --- ПАУЗА В ЦЕЛЕВОЙ ТОЧКЕ ---
    case BOSS_STATE2.SCATTERED_WAIT:
        timer--;
        if (timer <= 0) {
            state = BOSS_STATE2.GATHER;
            current_order_index = 0;
            timer = 0;
            waiting_for_block = false;
        }
        break;
    
    // --- ВОЗВРАТ БЛОКОВ ---
    case BOSS_STATE2.GATHER:
        if (waiting_for_block) {
            var blk_idx = gather_order[current_order_index - 1];
            if (!blocks[blk_idx].is_moving) {
                waiting_for_block = false;
                timer = delay_between_blocks;
            }
        } else {
            timer--;
            if (timer <= 0) {
                if (current_order_index < array_length(gather_order)) {
                    var blk_idx = gather_order[current_order_index];
                    var blk = blocks[blk_idx];
                    blk.start_move(blk.home_x, blk.home_y);
                    current_order_index++;
                    waiting_for_block = true;
                } else {
                    var last_idx = gather_order[array_length(gather_order) - 1];
                    if (!blocks[last_idx].is_moving) {
                        state = BOSS_STATE2.GATHER_WAIT;
                        timer = delay_after_gather;
                    }
                }
            }
        }
        break;
    
    // --- ПАУЗА ПОСЛЕ СБОРКИ ---
    case BOSS_STATE2.GATHER_WAIT:
        timer--;
        if (timer <= 0) {
            state = BOSS_STATE2.IDLE;
            timer = 30;
        }
        break;
}


if (hp < 1) {
	instance_destroy(self)
	with (oBoss2Part) {
		instance_destroy()
	}
	
	with (oBoss2Eye) {
		instance_destroy()	
	}
}
