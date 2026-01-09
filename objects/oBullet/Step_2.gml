lifetime -= 1;
if (lifetime <= 0) {
    instance_destroy();
    exit;
}

x += hsp * sp;
y += vsp * sp;


if (place_meeting(x+hsp, y+vsp, oSolidCrystal)) {
	o = instance_nearest(x,y,oSolidCrystal)
	o.trigger()
}

if (place_meeting(x, y, oSolid)) {
    instance_destroy();
}
