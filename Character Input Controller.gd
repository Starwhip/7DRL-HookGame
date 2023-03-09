extends Node

@export var character = Node3D.new()
@export var character_head = Node3D.new()
@export var grapple_hook = Node3D.new()

@export var mouse_sensitivity = 0.3

@export var speed = 20
@export var acceleration = 2

@export var max_jumps = 2
@export var wall_jumps = 1
@export var jump_velocity = 12
var num_jumps = max_jumps

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handle Jump.
	if character.is_on_floor():
		num_jumps = max_jumps
	
	elif character.is_on_wall():
		if(num_jumps < wall_jumps): #Restore jumps on wall contact
			num_jumps = wall_jumps
		
	if Input.is_action_just_pressed("Jump") or Input.is_action_pressed("Jump") and (character.is_on_floor() or character.is_on_wall()):
		if num_jumps > 0:
			num_jumps = num_jumps - 1
			character.velocity.y = jump_velocity
			
	if Input.is_action_pressed("Reel In"):
		grapple_hook.reel_rope(-1 * delta)
		
	if Input.is_action_pressed("Reel Out"):
		grapple_hook.reel_rope(1 * delta)
		
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var input_vector = Vector3(input_dir.x, 0, input_dir.y)
	var direction = input_vector.normalized()
	
	if direction:
		var desired_direction = (character.global_transform.basis * direction).normalized()
		character.accelerate(desired_direction,speed,acceleration,delta)

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion:
		character.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))	
		character_head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))	
		character_head.rotation.x = clamp(character_head.rotation.x, deg_to_rad(-89), deg_to_rad(89))


