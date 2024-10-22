extends WorldEnvironment

# Preload both cube scenes
var blue_cube_scene = preload("res://SceneInstance/BlueCube.tscn")  # Path to the blue cube scene
var red_cube_scene = preload("res://SceneInstance/RedCube.tscn")  # Path to the red cube scene

var timer = Timer.new()

func _ready() -> void:
	# Configure the timer
	timer.wait_time = randf_range(0.5, 2.0)  # Random time interval between 0.5 and 2 seconds
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	
	# Connect the timeout signal to the custom function for spawning cubes
	timer.timeout.connect(self._on_timer_timeout)

# Function that gets called every time the timer reaches its timeout
func _on_timer_timeout() -> void:
	# Randomly select between blue and red cubes
	var cube_scene = blue_cube_scene if randf() < 0.5 else red_cube_scene

	# Instantiate the selected cube scene
	var cube_instance = cube_scene.instantiate()  
	add_child(cube_instance)  # Add the cube instance to the current scene

	# Optionally, if you want to attach a movement script or adjust collision layers:
	if cube_instance.has_method("set_target"):
		# Assuming you have a movement script that expects to set a target, such as the player position
		cube_instance.call("set_target", Vector3.ZERO, 5.0)  # Example of passing a target (replace with player position if needed)
	
	# If you want to manipulate the cube's collision, for example:
	if cube_instance.has_node("CollisionShape3D"):
		cube_instance.get_node("CollisionShape3D").set_collision_layer_value(10, true)
	
	# Randomize the next spawn interval
	timer.wait_time = randf_range(0.5, 2.0)
