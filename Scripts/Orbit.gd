extends MeshInstance3D

# Variables to control the animation
@export var angle = 0.0
var radius = 5.0  # How far the object is from the center (the player)
var speed = 1.0   # Speed of revolution

# Called every frame
func _process(delta):
	# Increment the angle to make the object revolve
	angle += speed * delta

	# Update the position of the object based on the angle and radius
	var x = radius * cos(angle)
	var z = radius * sin(angle)

	# Update the object's position to revolve around the player
	position = Vector3(x, 0, z)
