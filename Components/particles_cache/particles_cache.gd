class_name ParticlesCache extends Node3D

# This script is designed to load in all the particle materials
# and run them so they get cached, to avoid a performance hit
# the first time particle effects occur in the game.
# This script is inspired by this reddit post:
# https://www.reddit.com/r/SoloDevelopment/comments/kyj6tf/godot_particles_lag_when_displayed_the_first_time/
# As well as this video:
# https://www.youtube.com/watch?v=kbDj9V2MZvw

# Emitted when particles are finished loading
#signal particles_loaded

# This is also needed in case the loading is very fast and
# the signal fires off before the main scene has time to
# check for the signal.
#var finished_loading:bool = false

func spawn_particles() -> void:
	var dir:DirAccess = DirAccess.open("res://materials/particles")
	if dir == null:
		printerr("Could not open folder 'res://materials/particles'")
		return
	dir.list_dir_begin()
	for file:String in dir.get_files():
		var resource:Resource = load(dir.get_current_dir() + "/" + file)
		#print(resource)
		var particles_instance:GPUParticles3D = GPUParticles3D.new()
		particles_instance.set_process_material(resource)
		particles_instance.set_one_shot(true)
		# Make it transparent
		# Yeah, this doesn't work
		# TODO particles_instance.set_modulate(Color(1,1,1,0))
		particles_instance.set_emitting(true)
		# Is this needed? (The original tutorials were for 2D)
		#particles_instance.position = Vector2(50,50)
		# Speed up the particle? Why not go even faster?
		#particles_instance.speed_scale = 2
		add_child(particles_instance)
	
	# Signal when finished
	#particles_loaded.emit()
	#finished_loading = true
