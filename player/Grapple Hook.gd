extends Node3D

var firing_hook = false
var hooked = false
var hook_pos = Vector3()
var rope_length = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")
var hook_init_pos = Vector3()
var hook_vector = Vector3()

@export var max_length  = 20
@export var hook_launch_velocity = 40
@export var min_length = 2
@export var spring_force = 60
@export var max_force_stretch = .1 #The percent of stretch in the rope where the force is maximized
@export var reel_rate = 5

@export var force_curve = Curve.new()

@onready var raycast = $RayCast3D
@onready var grapple_point = $"Grapple Hook Point"
@onready var grapple_rope = $"Grapple Hook Rope"
@onready var character = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if firing_hook:
		rope_length += hook_launch_velocity * delta
		if(rope_length > max_length):
			reset_hook(true)
			
		else: 
			var new_hook_pos = get_grapple_point()
			if new_hook_pos:
				hook(new_hook_pos)
	
	if hooked:
		grapple_point.global_position = hook_pos
	elif firing_hook:
		grapple_point.global_position = hook_init_pos + (rope_length * hook_vector)
		
	if Input.is_action_just_pressed("Fire Grapple"):
		if hooked or firing_hook:
			reset_hook(false)
			
		else:
			fire_hook()
	
	

func reset_hook(missed):
	if missed:
		print("Missed Hook")
	else:
		print("Released Hook")	
		
	rope_length = 0
	grapple_rope.hide()
	grapple_point.hide()
	firing_hook = false
	hooked = false

func fire_hook():
	print("Firing Grapple")
	firing_hook = true
	rope_length = 0
	grapple_point.global_position = global_position
	hook_init_pos = grapple_point.global_position
	hook_vector = -global_transform.basis.z.normalized()
	grapple_rope.show()
	grapple_point.show()
	
func hook(pos):
	print("Hooked!")
	hooked = true
	firing_hook = false
	hook_pos = pos
	
	rope_length = global_position.distance_to(hook_pos)
	print(rope_length)
	print(hook_pos)
	
func _physics_process(delta):
	var stretch_length = 0
	var tension = Vector3()
	
	if hooked:
				
		if Input.is_action_pressed("Reel In"):
			rope_length += -reel_rate * delta
		
		if Input.is_action_pressed("Reel Out"):
			rope_length += reel_rate * delta
		
		rope_length = clamp(rope_length, min_length, max_length)
		
		var tension_vector = (hook_pos - global_position)
		stretch_length = tension_vector.length() - rope_length
		
		var spring_comp = spring_force * force_curve.sample(stretch_length / (rope_length * max_force_stretch))
		tension = tension_vector.normalized() * abs(spring_comp)
		
		#print("Tension: " + str(tension))
		character.velocity += tension * delta
		
	var up_vector = Vector3.UP.lerp(tension.normalized(), clamp(tension.length()/ .5*spring_force, 0, .5))
	character.set_up_vector(up_vector)

func get_grapple_point():
	var target = grapple_point.global_position
	raycast.look_at(target)
	raycast.target_position.z = -rope_length
	
	print("Hook Length: " + str(rope_length))
	print("Target: " + str(target))
	
	if raycast.is_colliding():
		return raycast.get_collision_point()
