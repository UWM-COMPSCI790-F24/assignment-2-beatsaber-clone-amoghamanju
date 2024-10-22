extends Node3D

@export var red_cube_scene: PackedScene  # Red cube scene
@export var blue_cube_scene: PackedScene  # Blue cube scene
@export var spawn_rate_min: float = 0.5  # Minimum spawn rate
@export var spawn_rate_max: float = 1.5  # Maximum spawn rate
@export var spawn_distance: float = 10.0  # Distance from player
@export var spawn_height_range: Vector2 = Vector2(1, 3)  # Y-axis range
@export var spawn_x_positions: Array = [-2.0, 2.0]  # X-axis positions for cubes
@export var cube_speed: float = 5.0  # Speed at which cubes move

var player_position: Vector3
var spawn_timer: Timer

func _ready():
	# Get the player's position (assuming XR origin or Camera)
	if has_node("/root/XROrigin3D"):
		player_position = get_node("/root/XROrigin3D").global_transform.origin
	else:
		print("XROrigin3D not found in the scene!")
		return

	# Initialize spawn timer
	spawn_timer = Timer.new()
	spawn_timer.set_one_shot(false)
	spawn_timer.connect("timeout", Callable(self, "_spawn_cube"))
	add_child(spawn_timer)
	_start_spawn_timer()

# Function to start the spawn timer with random intervals
func _start_spawn_timer():
	var wait_time = randf_range(spawn_rate_min, spawn_rate_max)
	spawn_timer.set_wait_time(wait_time)
	spawn_timer.start()

# Function to spawn red or blue cubes alternately
func _spawn_cube():
	var is_red_on_left = randf() < 0.5  # Randomly determine which cube is on the left

	# Determine cube scenes and positions
	var left_cube_scene = is_red_on_left if red_cube_scene else blue_cube_scene
	var right_cube_scene = is_red_on_left if blue_cube_scene else red_cube_scene

	# Spawn the left cube
	_spawn_at_position(left_cube_scene, Vector3(spawn_x_positions[0], _random_y(), -spawn_distance), is_red_on_left)

	# Spawn the right cube
	_spawn_at_position(right_cube_scene, Vector3(spawn_x_positions[1], _random_y(), -spawn_distance), not is_red_on_left)

	_start_spawn_timer()  # Restart timer for next spawn

# Helper function to spawn a cube at a specific position and set the collision layer
func _spawn_at_position(cube_scene: PackedScene, spawn_position: Vector3, is_red: bool):
	var cube_instance = cube_scene.instantiate() as Node3D
	add_child(cube_instance)
	cube_instance.global_position = player_position + spawn_position

	# Set cube target to move towards the player (should be handled in the cube's script)
	if cube_instance.has_method("set_target"):
		cube_instance.call("set_target", player_position, cube_speed)

	# Set collision layers based on cube color
	var collision_shape = cube_instance.get_node("CollisionShape3D")  # Adjust if your node structure differs
	if collision_shape != null:
		if is_red:
			collision_shape.set_collision_layer(10)
			collision_shape.set_collision_mask(1 << 10)
		else:
			collision_shape.set_collision_layer(9)
			collision_shape.set_collision_mask(1 << 9)
	else:
		print("Error: CollisionShape3D not found in cube instance")

# Utility function to get random Y position
func _random_y() -> float:
	return randf_range(spawn_height_range.x, spawn_height_range.y)
