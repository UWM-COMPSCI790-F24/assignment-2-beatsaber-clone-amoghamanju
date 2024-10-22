extends Node3D  # Assuming this is attached to the Moving Cube

@export var speed: float = 2.0
@export var destroy_distance: float = 1.0
var player_position: Vector3
var original_size: Vector3
@export var z_threshold: float = -10.0 

@onready var xr_interface = XRServer.find_interface("OpenXR")  # Access the OpenXR interface
@onready var player = $Player  # Change this to your actual player or camera node
@export var cube_color: Color
@onready var audio_player = $AudioStreamPlayer3D

func _ready():
	# Connect to the 'on_pose_recentered' signal
	if xr_interface != null:
		xr_interface.connect("on_pose_recentered", Callable(self, "_on_pose_recentered"))
	else:
		print("OpenXR interface not found!")

	# Set the original size based on the current size of the cube mesh
	var mesh_instance = $MeshInstance3D  # Ensure you have a MeshInstance3D attached to the cube
	if mesh_instance != null:
		original_size = Vector3(0.5, 0.5, 0.5) 
	else:
		print("MeshInstance3D not found, cannot get size!")

	# Get the player's position (assuming XR origin)
	if has_node("/root/XROrigin3D"):
		player_position = get_node("/root/XROrigin3D").global_transform.origin
	else:
		print("XROrigin3D not found in the scene!")
		return

func _process(delta):
	# Move the cube towards the player
	global_position.z -= speed * delta

	# Check if the cube is close enough to the player
	if global_transform.origin.distance_to(player_position) < destroy_distance:
		split_cube()  # Call the function to split the cube
	# Check if the cube has passed the user and reached the z threshold
	if global_position.z < z_threshold:
		queue_free()  # Destroy the cube without playing the sound


func split_cube():
	# Calculate the half size of the cube
	if audio_player != null:
		audio_player.play()
	#to push the right half away

	# Remove the original cube
	queue_free()

# Helper function to create a smaller half-cube
func create_half_cube(size: Vector3) -> RigidBody3D:
	var half_cube = RigidBody3D.new()  # Create a new RigidBody3D for the half-cube

	# Create the mesh for the half-cube
	var mesh_instance = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	cube_mesh.size = size  # Set the size for the half-cube
	mesh_instance.mesh = cube_mesh
	half_cube.add_child(mesh_instance)

	# Add a collision shape to the half cube
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = size / 2  # The collision shape should match the half-cube size
	collision_shape.shape = box_shape
	half_cube.add_child(collision_shape)

	# Add the half-cube to the scene
	get_parent().add_child(half_cube)

	return half_cube

# This function is called when the "Oculus" button is pressed, and pose is recentered	


func _on_visibility_changed() -> void:
	print("Pose recentered! Repositioning the player to face the cube.")

	# Calculate the direction from the player's current position to the cube
	var player_position = player.global_transform.origin
	var direction_to_cube = (global_transform.origin - player_position).normalized()

	# Set the player's global_transform to face the cube
	var new_transform = player.global_transform
	new_transform.origin = global_transform.origin - (direction_to_cube * 5)  # Position the player 5 units away from the cube
	new_transform.basis = Basis(direction_to_cube)  # Adjust player's orientation to face the cube

	# Apply the new transform to the player
	player.global_transform = new_transform # Replace with function body.
