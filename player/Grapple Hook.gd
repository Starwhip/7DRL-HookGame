extends Node3D

var hooked = false
var hook_pos = Vector3()
var hook_length = 0
@export var spring_force = 60
var spring_damp = 0.25
var max_length  = 50
var min_length = 1
var reel_rate = 15

@export var force_curve = Curve.new()
var max_force_distance = .3


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var raycast = $RayCast3D
@onready var grapple_point = $"Grapple Hook Point"
@onready var grapple_rope = $"Grapple Hook Rope"
@onready var character = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hook()
	grapple_point.global_position = hook_pos
	
func _physics_process(delta):
	var length_error = 0
	var tension_vector = Vector3.UP
	
	if hooked:
				
		if Input.is_action_pressed("Reel In"):
			hook_length += -reel_rate * delta
		
		if Input.is_action_pressed("Reel Out"):
			hook_length += reel_rate * delta
		
		hook_length = clamp(hook_length, min_length, max_length)
		
		tension_vector = (hook_pos - global_position)
		length_error = tension_vector.length() - hook_length
		
		print(length_error)
		
		#Get cos between gravity and tension vector
		#var force = length_error * spring_force
				
		var spring_comp = (spring_force * force_curve.sample(length_error / (hook_length * max_force_distance)))
		var tension = tension_vector.normalized() * abs(spring_comp)
		
		print("Tension: " + str(tension))
		character.velocity += tension * delta
	
		tension_vector = tension
		
	var up_vector = Vector3.UP.lerp(tension_vector.normalized(), clamp(tension_vector.length()/ .5*spring_force, 0, .5))
	character.set_up_vector(up_vector)
	
func hook():

	if Input.is_action_just_pressed("Fire Grapple"):
		if hooked:
			hooked = false
			grapple_point.hide()
			grapple_rope.hide()
			
		else:
			var new_hook_pos = get_hook_pos()
			if new_hook_pos:
				
				hooked = true
				hook_pos = new_hook_pos
				
				grapple_point.show()
				grapple_rope.show()
			
				hook_length = global_position.distance_to(hook_pos)
				print(hook_length)
				print(hook_pos)

func get_hook_pos():
	if raycast.is_colliding():
		return raycast.get_collision_point()
