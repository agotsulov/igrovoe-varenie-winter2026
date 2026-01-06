show_debug_message("ASIDJHAS:DASHDLJASD")
switch (event_data[? "message"])
{
    case "player_grab":
		if (!inventory)
			pickup()
    break;
	case "player_toss":
		shoot()
	break;
}