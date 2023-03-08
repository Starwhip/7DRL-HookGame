extends CharacterBody3D


const SPRINT_SPEED = 20
const WALK_SPEED = 10
const SURF_FRICTION = 1.7
const SLIDE_FRICTION = 0.2
const AIR_FRICTION = 0.25
const ACCEL = 1
const JUMP_VELOCITY = 12

@export var hitpoints = 100
@export var stagger = 100

@export var HEIGHT = 1.5
@export var CROUCH_HEIGHT = 0.5
@export var HEAD_OFFSET = -0.2

var num_jumps = 1
var MAX_JUMPS = 2
var WALL_JUMPS = 1
const GRAV_JUMP_MULT = 0.75

var up_vector = Vector3(0,1,0)
var stunned = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sensitivity = 0.2
@onready var head = $head
@onready var hitbox = $CollisionShape3D

@export var mass = 100

func set_up_vector(v):
	var ang_error = rad_to_deg(Vector3.UP.angle_to(v))
	
	#print(ang_error)
	if ang_error > 80:
		v = Vector3.UP
	
	up_vector = up_vector.lerp(v,0.025)

func pushed_by_enemy(enemy):
	print(enemy)
	var deltaV = (get_momentum() - enemy.get_momentum()) / get_mass()
	
	if get_momentum().length() < enemy.get_momentum().length():
		$StunTimer.start()
		stun.emit()
		stunned = true
	else: 
		deltaV = deltaV * 0.25
	
	velocity -= deltaV
	
func _on_stun_timer_timeout():
	print("Time done")
	stunned = false

func get_mass():
	return mass

func get_momentum():
	return mass * velocity
	
signal stun()

signal dead()

signal hurt()

func damage(damage):
	if $InvincibilityTimer.is_stopped():
		print("ow")
		$LifeTracker.hit_points -= damage
		hurt.emit()
		
		$InvincibilityTimer.start()
		
		if $LifeTracker.hit_points <= 0:
			dead.emit()
			$LifeTracker.reset()
	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))	
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))	
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	

func can_jump():
	return num_jumps > 0

func jump():
	if can_jump():
		num_jumps = num_jumps - 1
		velocity.y = JUMP_VELOCITY
	
func _physics_process(delta):
	look_at(global_position - transform.basis.x.cross(up_vector), up_vector)
	#print(global_rotation)
	
	#Handle friction
	var friction
	if is_on_floor():
		friction = Vector3(SURF_FRICTION, AIR_FRICTION, SURF_FRICTION)

	else:
		friction = Vector3(AIR_FRICTION, AIR_FRICTION, AIR_FRICTION)
	
	#Add friction
	velocity.x -= velocity.x * friction.x * delta
	velocity.y -= velocity.y * friction.y * delta
	velocity.z -= velocity.z * friction.z * delta
	
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("Jump") and velocity.y > 0:
			velocity.y -= gravity * delta * GRAV_JUMP_MULT
		else:
			velocity.y -= gravity * delta
	
	if not stunned:
		# Handle Jump.
		if is_on_floor():
			num_jumps = MAX_JUMPS
		
		elif is_on_wall():
			if(num_jumps < WALL_JUMPS): #Restore jumps on wall contact
				num_jumps = WALL_JUMPS
			
		if Input.is_action_just_pressed("Jump") or Input.is_action_pressed("Jump") and (is_on_floor() or is_on_wall()):
			jump()

		# Get the input direction and handle the movement/deceleration.
		var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
		var input_vector = Vector3(input_dir.x, 0, input_dir.y)
		var direction = input_vector.normalized()
		
		
		if direction:
			#Quake "inspired" movement
			var speed = SPRINT_SPEED
			var desired_direction = (global_transform.basis * direction).normalized()
			var desired_speed = speed
			
			var current_speed = velocity.dot(desired_direction)
			
			var add_speed = desired_speed - current_speed
			if(add_speed > 0):
				var accel_speed = ACCEL * delta * desired_speed
				
				if(accel_speed > add_speed):
					accel_speed = add_speed
				
				velocity += accel_speed * desired_direction
	
	var last_velocity = velocity
	move_and_slide()
	
	for i in get_slide_collision_count():
		var body = get_slide_collision(i).get_collider()
		var angle = get_slide_collision(i).get_normal()
		
		if body.get_collision_layer_value(5):
			body.do_damage(self, last_velocity, angle)
			




