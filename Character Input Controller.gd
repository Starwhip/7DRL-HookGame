extends Node

@export var character := CharacterBody3D.new()
@export var character_head = Node3D.new()
@export var grapple_hook = Node3D.new()

@export var mouse_sensitivity = 0.3

@export var speed = 20
@export var acceleration = 2

@export var max_jumps = 2
@export var wall_jumps = 1
@export var jump_velocity = 12

var stun_effect = preload("res://Enemies/stun_effect.tscn")

var enabled = false
var stunned = false

var num_jumps = max_jumps

enum GRAPPLE_MODE{
	CLICK,
	HOLD
}
@export var control_mode = GRAPPLE_MODE.HOLD

@export var camera = Camera3D.new()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not enabled:
		if character.is_on_floor():
			enabled = true
		else:
			return
			
	if stunned:
		return
	
#	if Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
#		var cam_accel = 40
#		camera.top_level = true
#		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(character_head.global_transform.origin, cam_accel * delta)
#		camera.rotation.y = character.rotation.y
#		camera.rotation.x = character_head.rotation.x
#	else:
#		camera.top_level = false
#		camera.global_transform = character_head.global_transform
	
	match control_mode:
		GRAPPLE_MODE.HOLD:
			if Input.is_action_pressed("Fire Grapple"):
				if not (grapple_hook.hooked or grapple_hook.firing_hook):
					grapple_hook.fire_hook()
			else:
				if grapple_hook.firing_hook:
					grapple_hook.reset_hook(true)
				elif grapple_hook.hooked:
					grapple_hook.reset_hook(false)
					
		GRAPPLE_MODE.CLICK:
			if Input.is_action_just_pressed("Fire Grapple"):
				if not (grapple_hook.hooked or grapple_hook.firing_hook):
					grapple_hook.fire_hook()
				else:
					if grapple_hook.firing_hook:
						grapple_hook.reset_hook(true)
					elif grapple_hook.hooked:
						grapple_hook.reset_hook(false)
						
		
	# Handle Jump.
	if character.is_on_floor():
		num_jumps = max_jumps
	
	elif character.is_on_wall():
		if(num_jumps < wall_jumps): #Restore jumps on wall contact
			num_jumps = wall_jumps
		
	if Input.is_action_just_pressed("Jump") or Input.is_action_pressed("Jump") and (character.is_on_floor()):
		if num_jumps > 0:
			$"../Physics Character/Jump".play()
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
	
	#get mouse input for camera rotation
	if event is InputEventMouseMotion and Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		#print(event.relative)
		character.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		character_head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		character_head.rotation.x = clamp(character_head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
func _on_physics_player_spawn():
	if grapple_hook.hooked:
		grapple_hook.reset_hook(true)
	enabled = false

signal stun()

func set_stun(enable):
	if enable and not stunned:
		grapple_hook.reset_hook(true)
		$"../Stun Timer".start()
		var new_effect = stun_effect.instantiate()
		character.add_child(new_effect)
		new_effect.global_position = character.global_position
		new_effect.emitting = true
		stun.emit()
		stunned = true
	else:
		stunned = false


func _on_physics_character_was_hit(collider, last_velocity, normal):
	print(collider)
	print(character)
	if character.get_last_momentum().length() < collider.get_last_momentum().length():
		set_stun(true)


func _on_stun_timer_timeout():
	set_stun(false)
