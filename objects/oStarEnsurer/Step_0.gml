if (distance_to_object(oPlayer) < 120)
	if (!instance_exists(oPickable))
		instance_create_depth(x,y,depth+1,oPickable)