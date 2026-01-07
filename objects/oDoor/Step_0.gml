gp_index = 0;
var gp_connected = gamepad_is_connected(gp_index);
var btn_up = keyboard_check(vk_up) || (gp_connected && gamepad_button_check(gp_index, gp_padu));

if (btn_up && place_meeting(x,y,oPlayer)) {
    room_goto(Room1);
}