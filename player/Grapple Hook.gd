extends Node3D

var hooked = false
var hook_pos = Vector3()
var hook_length = 0
@export var spring_force = 30
var spring_damp = 0.8
@export var max_length  = 100
var min_length = 1
var reel_rate = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hook()
	$"Grapple Hook Point".global_position = hook_pos
	
func _physics_process(delta):
	if hooked:
				
		if Input.is_action_pressed("Reel In"):
			hook_length += -reel_rate * delta
		
		if Input.is_action_pressed("Reel Out"):
			hook_length += reel_rate * delta
		
		hook_length = clamp(hook_length, min_length, max_length)
		
		var length_error = global_position.distance_to(hook_pos) - hook_length
		var up_vector = (hook_pos - global_position).normalized()
		$"../..".set_up_vector(up_vector) 
		
		print(length_error)
		
		var delta_v =  up_vector * clamp(length_error, 0, max_length) * spring_force * delta
		$"../..".velocity += delta_v
	
	else:
		$"../..".set_up_vector(Vector3.UP) 
	
func hook():
	if Input.is_action_just_released("Left Mouse"):
		hooked = false
		
	if Input.is_action_pressed("Left Mouse"):
		if not hooked:
			var new_hook_pos = get_hook_pos()
			if new_hook_pos:
				
				hooked = true
				hook_pos = new_hook_pos
			
				hook_length = global_position.distance_to(hook_pos)
				print(hook_length)
				print(hook_pos)

func get_hook_pos():
	if $RayCast3D.is_colliding():
		return $RayCast3D.get_collision_point()
