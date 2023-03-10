extends Node

@export var character = Node3D.new()
@export var character_head = Node3D.new()

@export var speed = 10
@export var acceleration = 1

@export var max_jumps = 2
@export var wall_jumps = 1
@export var jump_velocity = 12
@export var tracking_rate = 50
@export var head_tracking_rate = 100
var num_jumps = max_jumps

@export var desired_direction = Vector3()
@export var target_location = Vector3()
var desired_speed = speed
var current_tracking_location = Vector3()
var current_head_tracking_location = Vector3()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#rotate(delta)
	
	# Handle Jump.
	if character.is_on_floor():
		num_jumps = max_jumps
	
	elif character.is_on_wall():
		if(num_jumps < wall_jumps): #Restore jumps on wall contact
			num_jumps = wall_jumps
		
	# Get the input direction and handle the movement/deceleration.
	var direction = desired_direction.normalized()
	
	if direction:
		var desired_direction = (character.global_transform.basis * direction).normalized()
		character.accelerate(desired_direction,desired_speed,acceleration,delta)
	
func jump():
	if num_jumps > 0:
		num_jumps = num_jumps - 1
		character.velocity.y = jump_velocity

func rotate(delta):
	current_tracking_location = current_tracking_location.lerp(target_location,tracking_rate*delta)
	current_head_tracking_location = current_head_tracking_location.lerp(target_location,head_tracking_rate*delta)
	character.look_at(current_tracking_location)
	character_head.look_at(current_head_tracking_location)	
	character_head.rotation.x = clamp(character_head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	character_head.rotation.z = clamp(character_head.rotation.z, deg_to_rad(-89), deg_to_rad(89))
