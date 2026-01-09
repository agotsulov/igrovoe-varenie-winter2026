breaktimer = -1


function trigger() {
	audio_play_sound(sfxCrystalBreak,1,0,1.3)
	instance_destroy(other)
	breaktimer = 45
	
	
}