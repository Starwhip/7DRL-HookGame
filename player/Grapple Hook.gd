extends Node3D

var firing_hook = false
var hooked = false
var reel_length = 0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")
var hook_velocity = Vector3()

var hook_point_array = []

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
@export var character = CharacterBody3D.new()
@export var HUD = Node.new()

var hooked_enemy = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	HUD.rope_length = get_rope_length()
	HUD.reel_length = reel_length
	HUD.max_length = max_length
	

func get_rope_length():
	var len = 0
	var dupe = []
	#print("Init Dupe" + str(dupe))
	dupe.append(grapple_point.global_position)
	
	#print("Append init hook point" + str(dupe))
	for a in hook_point_array:
		dupe.append(a)
	
	#print("Append hook point array" + str(dupe))
	dupe.append(global_position)
	
	#print("Append global position" + str(dupe))
	#print("Rope Length: " + str(rope_length))
	
	#print("Start loop")
	for i in dupe.size() - 1:
		#print(i)
		var segment = dupe[i].distance_to(dupe[i+1])
		len += segment
		#print("Segment: " + str(segment))
	
	#print(pos)
	#print(global_position)
	#print(len)
	
	#print("Total rope length: " + str(len))
	return len

signal rope_length_update(length)
signal reel_length_update(length)

func reel_rope(amount):
	reel_length = clamp(reel_length + (reel_rate * amount), min_length,max_length)
	reel_length_update.emit(reel_length)
	
func reset_hook(missed):
	$GrappleGun.rotation = Vector3(0,0,0)
	$GrappleGun/GrappleHook.show()
	
	if missed:
		print("Missed Hook")
	else:
		print("Released Hook")	
		character.velocity += -character.transform.basis.z * RELEASE_VEL_BOOST
		$GrappleGun/Trigger.play()
		
	reel_length = 0
	
	raycast.rotation = Vector3(0,0,0)
	raycast.target_position = Vector3(0,0,0)

	hook_point_array = [global_position]
	
	grapple_point.hide()
	firing_hook = false
	hooked = false


func fire_hook():
	$GrappleGun/GrappleHook.hide()
	print("Firing Grapple")
	firing_hook = true
	
	$GrappleGun/Trigger.play()
	$"GrappleGun/Gun Fire".play()
	
	raycast.rotation = Vector3(0,0,0)
	raycast.target_position = Vector3(0,0,0)
	
	reel_length = 0
	grapple_point.global_position = $GrappleGun/GrappleHook.global_position
	hook_point_array = [grapple_point.global_position]
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
	
	hook_point_array[0] = pos
	reel_length = get_rope_length() * ROPE_LENGTH_MOD
	
	$"Grapple Hook Point/Hook Audio".play()
	#print(reel_length)
	#print(hook_pos)

var last_rope_length = 0
func _physics_process(delta):
	if hooked_enemy and not is_instance_valid(hooked_enemy):
		if hooked:
			reset_hook(false)
		hooked_enemy = null
		
	if not hooked:
		if firing_hook:
			hook_point_array[0] += hook_velocity * delta
			hook_velocity += gravity * delta
			
			var rope_length = get_rope_length()
			if(rope_length > max_length):
				reset_hook(true)
				
			else: 
				var new_hook_pos = get_grapple_point()
				if new_hook_pos:
					hook(new_hook_pos)
		
		else: #Not firing hook and not hooked
			hook_point_array = [global_position]
			
		grapple_point.global_position = hook_point_array[0]
		
	var stretch_length = 0
	var tension = Vector3()	
	
	if hooked:
		if hooked_enemy:
			hook_point_array[0] = hooked_enemy.get_grapple_point()
				
		
		grapple_point.global_position = hook_point_array[0]
		
		raycast.look_at(hook_point_array.back())
		check_grapple_occlusion()
		
		var tension_vector = (hook_point_array.back() - global_position).normalized()
		stretch_length = get_rope_length() - reel_length
		
		#Do graphics for the hook and gun
		grapple_point.look_at(tension_vector * 1000)
		$GrappleGun.look_at(hook_point_array.back())
		
		var spring_comp = spring_force * force_curve.sample(stretch_length / (get_rope_length() * max_force_stretch))
		tension = tension_vector * abs(spring_comp)
		if(hooked_enemy):
			#print("Enemy Mass: " + str(hooked_enemy.get_mass()))
			#print("Player Mass: " + str($"../..".get_mass()))
			
			var enemy_mass = hooked_enemy.get_mass() * hooked_enemy.momentum_resistance
			var player_mass = character.get_mass() * character.momentum_resistance
			
			var player_multiplier = float(enemy_mass) / (enemy_mass + player_mass)
			var enemy_multiplier =  float(player_mass) / (enemy_mass + player_mass)
			#print("Ratio: " + str(player_multiplier))
			tension = tension * (player_multiplier)
			
			var enemy_tension_vector = Vector3()
			if (hook_point_array.size() > 1):
				enemy_tension_vector = (hook_point_array[0] - hook_point_array[1]).normalized()
			else:
				enemy_tension_vector = (hook_point_array[0] - global_position).normalized()
				
			var enemy_tension = enemy_tension_vector * abs(spring_comp) * enemy_multiplier
			hooked_enemy.velocity -= enemy_tension * delta
		
		#print(stretch_length)
		#print("Tension: " + str(tension))
		character.velocity += tension * delta
		
	var up_vector = Vector3.UP.lerp(tension.normalized(), clamp(tension.length()/ .5*spring_force, 0, 1))
	
	character.set_up_vector(up_vector)
	
	if get_rope_length() != last_rope_length:
		last_rope_length = get_rope_length()
		rope_length_update.emit(last_rope_length)


func get_grapple_point():
	var target = hook_point_array[0]
	raycast.look_at(target)
	raycast.target_position.z = -global_position.distance_to(target)
	
	#print("Raycast Target Position " + str(raycast.target_position))
	#print("Rope Length: " + str(rope_length))
	#print("Target: " + str(target))
	
	#print("Collision: " + str(raycast.get_collision_point()))
	
	if raycast.is_colliding():
		#print("Hit something")
		if(raycast.get_collider().get_collision_layer_value(3)):
			hooked_enemy = raycast.get_collider()
			hooked_enemy.grapple(raycast.get_collision_point())
			
			print("Grapple hooked enemy: " +str(hooked_enemy))
		else:
			hooked_enemy = null
			
		
		return raycast.get_collision_point() - (global_position.direction_to(target) * 0.05)

func check_grapple_occlusion():
	
	var new_position = is_rope_occluded(global_position,hook_point_array.back())
	if(new_position):		
		hook_point_array.append(new_position)
		print("Append hook new pos")
		#print(hook_pos)
		#print(global_position)
		#print(new_position)
	
	if(hook_point_array.size() > 1):
		var front_new_position = is_rope_occluded(hook_point_array[0], hook_point_array[1])
		if(front_new_position):
			print("Frontal Occlusion")

			hook_point_array.insert(1,front_new_position)
			
		if is_rope_unwrapped(global_position,hook_point_array.back(), hook_point_array[hook_point_array.size()-2]):
			pass
			#If there's a clear sight, pop from stacks to unwrap the line.
			hook_point_array.pop_back()
	
		
		if(hook_point_array.size() > 2):
			if is_rope_unwrapped(hook_point_array[0],hook_point_array[1],hook_point_array[2]):
				print("Unwrapping")
				
				#If there's a clear sight, remove the second index to unwrap the line.
				hook_point_array.pop_at(1)

func is_rope_occluded(from, to):
	const ERR_DISTANCE = 0.075 * 2
	var collision_mask = 0b00000000000000000001
	var space_state = get_world_3d().direct_space_state
	var query_current = PhysicsRayQueryParameters3D.create(from, to, collision_mask)
	var new_hit = space_state.intersect_ray(query_current)
	
	if new_hit and new_hit.get("position").distance_to(to) > ERR_DISTANCE:
		#Nudge the anchor point by a radius away from its surface		
		var nudge = (new_hit.get("normal") + new_hit.get("position").direction_to(to)).normalized() * ERR_DISTANCE
		var new_position = new_hit.get("position") + nudge
		return new_position
		
	else:
		return null

func is_rope_unwrapped(from,anchor,to):
	var clear_sight = true
	
	#Sample many times from current position towards current anchor
	#Check if all can see the point on the top of the stack
	
	const ERR_DISTANCE = 0.01
	var collision_mask = 0b00000000000000000001
	var space_state = get_world_3d().direct_space_state
	
	var samples = 10
	for i in samples:
		var sample_pos = from + (i * (from.direction_to(anchor) * from.distance_to(anchor)) / samples)
		
		var queryLast = PhysicsRayQueryParameters3D.create(sample_pos, to, collision_mask)
		var old_hit = space_state.intersect_ray(queryLast)

		#if there a hit, and it is far from the old anchor, it is still occluded
		if old_hit and old_hit.get("position").distance_to(to) > ERR_DISTANCE:
			clear_sight = false
			break
	
	return clear_sight

func _on_character_body_3d_stun():
	if(hooked == true):
		reset_hook(false)
	else:
		reset_hook(true)
