extends WorldEnvironment

# Preload both cube scenes
var blue_cube_scene = preload("res://SceneInstances/BlueCube.tscn")  # Path to the blue cube scene
var red_cube_scene = preload("res://SceneInstances/RedCube.tscn")  # Path to the red cube scene

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
	
	# Get the cube's collision shape and set the appropriate layer and mask
	var collision_shape = cube_instance.get_node("CollisionShape3D")  # Adjust if your node structure differs
	if collision_shape != null:
		if cube_scene == blue_cube_scene:
			# If it's a blue cube, set it to collision layer 9 (interacts with left sword)
			collision_shape.set_collision_layer(9)
			collision_shape.set_collision_mask(1 << 9)  # Only interacts with the left sword on layer 9
		else:
			# If it's a red cube, set it to collision layer 10 (interacts with right sword)
			collision_shape.set_collision_layer(10)
			collision_shape.set_collision_mask(1 << 10)  # Only interacts with the right sword on layer 10
	else:
		print("Error: CollisionShape3D not found in cube instance")

	# Assuming you have a movement script that expects to set a target, such as the player position
	if cube_instance.has_method("set_target"):
		cube_instance.call("set_target", Vector3.ZERO, 5.0)  # Example of passing a target (replace with player position if needed)

	# Randomize the next spawn interval
	timer.wait_time = randf_range(0.5, 2.0)
	
# Utility function to generate a random float between min and max
func randf_range(min: float, max: float) -> float:
	return randf() * (max - min) + min
