extends Node3D

var firing_hook = false
var hooked = false
var hook_pos = Vector3()
var rope_length = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")
var hook_init_pos = Vector3()
var hook_velocity = Vector3()

var hook_point_array = Array()
var rope_length_array = Array()

@export var max_length  = 20
@export var hook_launch_velocity = 40
@export var min_length = 2
@export var spring_force = 60
@export var max_force_stretch = .05 #The percent of stretch in the rope where the force is maximized
@export var reel_rate = 5

@export var force_curve = Curve.new()

@export var ROPE_LENGTH_MOD = 0.75
@export var RELEASE_VEL_BOOST = 0

@onready var raycast = $GrappleGun/RayCast3D
@onready var grapple_point = $"Grapple Hook Point"
@onready var character = $"../.."

var initial_hook_point = Vector3()
enum GRAPPLE_MODE{
	CLICK,
	HOLD
}
var control_mode = GRAPPLE_MODE.HOLD

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"../../HUD".rope_length = (max_length - get_rope_length()) / max_length
	
	match control_mode:
		GRAPPLE_MODE.HOLD:
			if Input.is_action_pressed("Fire Grapple"):
				if not (hooked or firing_hook):
					fire_hook()
			else:
				if firing_hook:
					reset_hook(true)
				elif hooked:
					reset_hook(false)
					
		GRAPPLE_MODE.CLICK:
			if Input.is_action_just_pressed("Fire Grapple"):
				if not (hooked or firing_hook):
					fire_hook()
				else:
					if firing_hook:
						reset_hook(true)
					elif hooked:
						reset_hook(false)

func get_rope_length():
	var len = rope_length
	#print("Rope Length: " + str(rope_length))
	for i in rope_length_array.size()-1:
		len += rope_length_array[i]
		
	#print("Total rope length: " + str(len))
	return len


func reset_hook(missed):
	$GrappleGun.rotation = Vector3(0,0,0)
	$GrappleGun/GrappleHook.show()
	if missed:
		print("Missed Hook")
	else:
		print("Released Hook")	
		character.velocity += -character.transform.basis.z * RELEASE_VEL_BOOST
	
	rope_length = 0
	
	raycast.rotation = Vector3(0,0,0)
	raycast.target_position = Vector3(0,0,0)

	hook_point_array = Array()
	rope_length_array = Array()
	
	grapple_point.hide()
	firing_hook = false
	hooked = false


func fire_hook():
	$GrappleGun/GrappleHook.hide()
	print("Firing Grapple")
	firing_hook = true
	
	raycast.rotation = Vector3(0,0,0)
	raycast.target_position = Vector3(0,0,0)
	
	rope_length = 0
	grapple_point.global_position = $GrappleGun/GrappleHook.global_position
	hook_pos = grapple_point.global_position
	hook_velocity = -global_transform.basis.z.normalized() * hook_launch_velocity
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

	initial_hook_point = pos
	grapple_point.global_position = initial_hook_point
	rope_length = global_position.distance_to(hook_pos) * ROPE_LENGTH_MOD
	print(rope_length)
	print(hook_pos)


func _physics_process(delta):			
	if firing_hook:
		hook_pos += hook_velocity * delta
		hook_velocity += gravity * delta
		
		grapple_point.global_position = hook_pos
		rope_length = global_position.distance_to(grapple_point.global_position)
		if(rope_length > max_length):
			reset_hook(true)
			
		else: 
			var new_hook_pos = get_grapple_point()
			if new_hook_pos:
				hook(new_hook_pos)
		
		
	var stretch_length = 0
	var tension = Vector3()
	
	if hooked:
		check_grapple_occlusion()
		grapple_point.global_position = initial_hook_point
		raycast.look_at(hook_pos)
		
		if Input.is_action_pressed("Reel In"):
			if(get_rope_length() > min_length):
				rope_length += -reel_rate * delta
		
		if Input.is_action_pressed("Reel Out"):
			if(get_rope_length() < max_length):
				rope_length += reel_rate * delta
		
		#if get_rope_length() > max_length:
		#	rope_length -= get_rope_length() - max_length 
		
		var tension_vector = (hook_pos - global_position)
		stretch_length = tension_vector.length() - rope_length
		
		#Do graphics for the hook and gun
		grapple_point.look_at(tension_vector * 1000)
		$GrappleGun.look_at(hook_pos)
		
		var spring_comp = spring_force * force_curve.sample(stretch_length / (get_rope_length() * max_force_stretch))
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
	const ERR_DISTANCE = 0.01
	var collision_mask = 0b00000000000000000001
	var space_state = get_world_3d().direct_space_state
	var query_current = PhysicsRayQueryParameters3D.create(global_position, hook_pos, collision_mask)
	var new_hit = space_state.intersect_ray(query_current)	
			
	if new_hit and new_hit.get("position").distance_to(hook_pos) > ERR_DISTANCE:
		#Nudge the anchor point by a radius away from its surface		
		var new_position = new_hit.get("position") + new_hit.get("normal") * ERR_DISTANCE
		
		#Compute length taken by wrap
		var length_taken = hook_pos.distance_to(new_position)
		
		#Store the old values into their stacks
		hook_point_array.append(hook_pos)
		rope_length_array.append(length_taken)
		
		print("Rope Len: " + str(rope_length))
		print("Total Len: " + str(get_rope_length()))
		print("Taken: " + str(length_taken))
			
		if rope_length < length_taken:
			print("ALERT")
			
			
		#Set new positions
		hook_pos = new_position
		rope_length = rope_length - length_taken
	
	if(hook_point_array.size() > 0):
		var last_point = hook_point_array.back()
		var clear_sight = true
		
		#Sample many times from current position towards current anchor
		#Check if all can see the point on the top of the stack
		
		var samples = 10
		for i in samples:
			var sample_pos = global_position + (i * (global_position.direction_to(hook_pos) * global_position.distance_to(hook_pos)) / samples)
			
			var queryLast = PhysicsRayQueryParameters3D.create(sample_pos, last_point, collision_mask)
			var old_hit = space_state.intersect_ray(queryLast)

			#if there a hit, and it is far from the old anchor, it is still occluded
			if old_hit and old_hit.get("position").distance_to(last_point) > ERR_DISTANCE:
				clear_sight = false
				break
			
		if clear_sight == true:
			#If there's a clear sight, pop from stacks to unwrap the line.
			hook_pos = hook_point_array.pop_back()
			rope_length += rope_length_array.pop_back()

