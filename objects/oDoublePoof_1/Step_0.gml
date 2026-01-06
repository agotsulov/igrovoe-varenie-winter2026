spd = 2
lt = 10

if (time_poof == 0 || time_poof == lt) {
	s = instance_create_depth(x,y,depth+1,oStarParticle)
	s.direction = poof_base_angle
	s.speed = spd
	
	s = instance_create_depth(x,y,depth+1,oStarParticle)
	s.direction = poof_base_angle+90
	s.speed = spd
	
	s = instance_create_depth(x,y,depth+1,oStarParticle)
	s.direction = poof_base_angle+90*2
	s.speed = spd
	
	s = instance_create_depth(x,y,depth+1,oStarParticle)
	s.direction = poof_base_angle+90*3
	s.speed = spd
	
	poof_base_angle += 45
}


if time_poof == lt instance_destroy(self)

time_poof += 1

