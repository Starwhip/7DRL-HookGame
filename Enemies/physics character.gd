extends CharacterBody3D

@export var FRICTION = 3.5
@export var AIR_FRICTION = 0.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var mass = 75
@export var is_wall = true
@export var is_player = true
@export var is_enemy = true
@export var is_hazard = true

@export var hits_wall = true
@export var hits_player = true
@export var hits_enemy = true
@export var hits_hazard = true

@export var momentum_resistance = 1
var desired_up_direction = Vector3.UP
func _ready():
	self.set_collision_layer_value(1,is_wall)
	self.set_collision_layer_value(2,is_player)
	self.set_collision_layer_value(3,is_enemy)
	self.set_collision_layer_value(5,is_hazard)
	
	self.set_collision_mask_value(1,hits_wall)
	self.set_collision_mask_value(2,hits_player)
	self.set_collision_mask_value(3,hits_enemy)
	self.set_collision_mask_value(5,hits_hazard)
	
func _process(delta):
	pass

func _physics_process(delta):
	if rad_to_deg(Vector3.UP.angle_to(up_direction)) > 80:
		up_direction = up_direction.lerp(desired_up_direction, 3 * delta)
	else:
		up_direction = up_direction.lerp(Vector3.UP, 3 * delta)
	
	look_at(global_position - transform.basis.x.cross(up_direction), up_direction)
	
	if is_on_floor():
		velocity.x -= velocity.x * FRICTION * delta
		velocity.z -= velocity.z * FRICTION * delta
	
	else:
		velocity.x -= velocity.x * AIR_FRICTION * delta
		velocity.z -= velocity.z * AIR_FRICTION * delta
		
	velocity.y -= velocity.y * AIR_FRICTION * delta
	velocity.y -= gravity * delta
	
	#print("velocity" + str(velocity))
	var last_velocity = velocity
	move_and_slide()
	
	var past_collisions = []
	for i in get_slide_collision_count():
		
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if past_collisions.has(collider):
			continue
		
		past_collisions.append(collider)

		var normal = get_slide_collision(i).get_normal()
		
		if collider.get_collision_layer_value(1): #Walls
			hit_wall.emit(collider, last_velocity, normal)
			
		if collider.get_collision_layer_value(2): #player
			print("Hit player")
			hit_player.emit(collider, last_velocity, normal)
			momentum_transfer(collider,last_velocity,normal)
		
		if collider.get_collision_layer_value(3): #enemies
			print("Hit Enemy")
			hit_enemy.emit(collider, last_velocity, normal)
			momentum_transfer(collider,last_velocity,normal)
			
		
		if collider.get_collision_layer_value(5): #hazards
			print("Hit Hazard")
			hit_hazard.emit(collider, last_velocity, normal)
			
			var normal_velocity = last_velocity.dot(-normal) / -normal.dot(-normal) * -normal
			var self_normal_momentum = mass * normal_velocity
			
			velocity = (Vector3(0,0,0) - self_normal_momentum) / mass

func accelerate(desired_direction, desired_speed, acceleration, delta):
	#Quake "inspired" movement
	var current_speed = velocity.dot(desired_direction)
	
	var add_speed = desired_speed - current_speed
	if(add_speed > 0):
		var accel_speed = acceleration * delta * desired_speed
		
		if(accel_speed > add_speed):
			accel_speed = add_speed
		
		velocity += accel_speed * desired_direction

func get_momentum():
	return mass * velocity
	
func get_mass():
	return mass
	
func set_up_vector(vector):
	desired_up_direction = vector
	
func get_grapple_point():
	return $"grapple point".global_position
	
func set_grapple_point(point):
	$"grapple point".global_position = point

signal hit_wall(collision, last_velocity, normal)

signal hit_player(collision, last_velocity, normal)
	
signal hit_enemy(collision, last_velocity, normal)

signal hit_hazard(collision, last_velocity, normal)

func _on_physics_player_spawn():
	position = Vector3(0,0,0)
	rotation = Vector3(0,0,0)
	velocity = Vector3(0,0,0)
	
func momentum_transfer(collider,last_velocity,normal):
	
	var other_mass = collider.get_mass() * collider.momentum_resistance
	var self_mass = mass * momentum_resistance
	
	var self_multiplier = float(other_mass) / (other_mass + self_mass)
	var other_multiplier =  float(self_mass) / (other_mass + self_mass)
	
	print(self_multiplier)
	print(other_multiplier)
	
	var normal_velocity = last_velocity.dot(-normal) / -normal.dot(-normal) * -normal
	var collider_normal_velocity = collider.velocity.dot(normal) / normal.dot(normal) * normal
	var self_normal_momentum = mass * normal_velocity
	var collider_normal_momentum = collider.get_mass() * collider_normal_velocity
	velocity = (collider_normal_momentum - self_normal_momentum) / mass * self_multiplier
	collider.velocity = (self_normal_momentum - collider_normal_momentum) / collider.mass / self_multiplier
	
	
