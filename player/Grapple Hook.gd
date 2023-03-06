extends Node3D

var firing_hook = false
var hooked = false
var hook_pos = Vector3()
var rope_length = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")
var hook_init_pos = Vector3()
var hook_vector = Vector3()

var hook_point_array = Array()

@export var max_length  = 20
@export var hook_launch_velocity = 40
@export var min_length = 2
@export var spring_force = 60
@export var max_force_stretch = .05 #The percent of stretch in the rope where the force is maximized
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
	pass

func reset_hook(missed):
	if missed:
		print("Missed Hook")
	else:
		print("Released Hook")	
	
	raycast.rotation = Vector3(0,0,0)
	raycast.target_position = Vector3(0,0,0)

	hook_point_array = Array()
	grapple_rope.hide()
	grapple_point.hide()
	firing_hook = false
	hooked = false

func fire_hook():
	print("Firing Grapple")
	firing_hook = true
	
	raycast.rotation = Vector3(0,0,0)
	raycast.target_position = Vector3(0,0,0)
	
	
	rope_length = 0
	grapple_point.global_position = global_position
	hook_init_pos = grapple_point.global_position
	hook_vector = -global_transform.basis.z.normalized()
	grapple_rope.show()
	grapple_point.show()
	#print(rope_length)
	#print(grapple_point.global_position)
	#print(hook_init_pos)
	#print(hook_vector)
	
func hook(pos):
	print("Hooked!")
	hooked = true
	firing_hook = false
	hook_pos = pos
	
	grapple_point.global_position = pos
	rope_length = global_position.distance_to(hook_pos)
	print(rope_length)
	print(hook_pos)
	
func _physics_process(delta):
	if Input.is_action_just_pressed("Fire Grapple"):
		if hooked or firing_hook:
			reset_hook(false)
		else:
			fire_hook()
			
	if firing_hook:
		rope_length += hook_launch_velocity * delta
		if(rope_length > max_length):
			reset_hook(true)
			
		else: 
			var new_hook_pos = get_grapple_point()
			if new_hook_pos:
				hook(new_hook_pos)
	
	if firing_hook:
		grapple_point.global_position = hook_init_pos + (rope_length * hook_vector)
		
	var stretch_length = 0
	var tension = Vector3()
	
	if hooked:
		#check_grapple_occlusion()
		grapple_point.global_position = hook_pos
		
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
		
	var up_vector = Vector3.UP.lerp(tension.normalized(), clamp(tension.length()/ .5*spring_force, 0, 1))
	
	character.set_up_vector(up_vector)

func get_grapple_point():
	var target = grapple_point.global_position
	raycast.look_at(target)
	raycast.target_position.z = -rope_length
	
	#print("Raycast Target Position " + str(raycast.target_position))
	#print("Rope Length: " + str(rope_length))
	#print("Target: " + str(target))
	
	#print("Collision: " + str(raycast.get_collision_point()))
	
	if raycast.is_colliding():
		#print("Hit something")
		return raycast.get_collision_point()

func check_grapple_occlusion():
	
	var target = hook_pos
	var space_state = get_world_3d().direct_space_state
	var queryCurrent = PhysicsRayQueryParameters3D.create(global_position, hook_pos)
	var new_hit = space_state.intersect_ray(queryCurrent)	
			
	if new_hit and abs((new_hit.get("position") - hook_pos).length()) > 0.01:
		print("Added Point")
		hook_point_array.append(hook_pos)
		print(new_hit)
		hook_pos = new_hit.get("position")
		rope_length = global_position.distance_to(hook_pos)
	
	if(hook_point_array.size() > 0):
		var last_point = hook_point_array.back()
		var queryLast = PhysicsRayQueryParameters3D.create(global_position, last_point)
		var old_hit = space_state.intersect_ray(queryLast)

		var v1 = (global_position - hook_pos).normalized()
		var v2 = (hook_pos - last_point).normalized()
		var axis = v1.cross(v2).normalized()
		var angle = acos(v1.dot(v2)) # radians, not degrees
		
		print("Angle: "+str(angle))
		if angle < 0.00:
			print("Removed Point")
			hook_pos = hook_point_array.pop_back()
			rope_length = global_position.distance_to(hook_pos)
			return

