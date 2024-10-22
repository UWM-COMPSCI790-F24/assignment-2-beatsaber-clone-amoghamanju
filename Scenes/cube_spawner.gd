extends Node3D

@export var red_cube_scene: PackedScene  # The scene for the red cube
@export var blue_cube_scene: PackedScene  # The scene for the blue cube
@export var spawn_rate_min: float = 0.5  # Minimum time between spawns
@export var spawn_rate_max: float = 2.0  # Maximum time between spawns
@export var spawn_distance: float = 10.0  # Distance from the player where the cubes will spawn
@export var spawn_height_range: Vector2 = Vector2(1, 3)  # Height range for cube spawning
@export var cube_speed: float = 5.0  # Speed at which cubes move towards the player

var player_position: Vector3
var spawn_timer: Timer

func _ready():
	# Get the player's position (assuming XR Origin or Camera)
	if has_node("/root/XROrigin3D"):
		player_position = get_node("/root/XROrigin3D").global_transform.origin
	else:
		print("XROrigin3D not found in the scene!")
		return

	# Initialize the spawn timer
	spawn_timer = Timer.new()
	spawn_timer.set_wait_time(randf_range(spawn_rate_min, spawn_rate_max))  # Set initial wait time
	spawn_timer.set_one_shot(false)  # Keep the timer running
	spawn_timer.connect("timeout", Callable(self, "_spawn_cube"))
	add_child(spawn_timer)  # Add the timer to the scene
	spawn_timer.start()  # Start the timer

# Function to spawn a cube
func _spawn_cube():
	# Randomly choose between the red cube and the blue cube
	var cube_scene = red_cube_scene if randf() < 0.5 else blue_cube_scene

	# Instantiate the chosen cube
	var cube_instance = cube_scene.instantiate() as Node3D
	if cube_instance != null:
		add_child(cube_instance)  # Add the cube to the scene

		# Set a random position for the cube
		var spawn_height = randf_range(spawn_height_range.x, spawn_height_range.y)
		var spawn_offset = Vector3(0, spawn_height, -spawn_distance)
		cube_instance.global_position = player_position + spawn_offset

		# Move the cube towards the player (you can handle this in the cube's script)
		if cube_instance.has_method("set_target"):
			cube_instance.call("set_target", player_position, cube_speed)

	# Reset timer with a new random spawn rate
	spawn_timer.set_wait_time(randf_range(spawn_rate_min, spawn_rate_max))

# Utility function to get a random float in a range
func randf_range(min: float, max: float) -> float:
	return randf() * (max - min) + min
