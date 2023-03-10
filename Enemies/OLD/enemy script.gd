extends CharacterBody3D

const ACCEL = 15
const SPEED = 5
const CHARGE_ACCEL = 40
const CHARGE_SPEED = 15
const JUMP_VELOCITY = 4.5
const FRICTION = 0.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var target = CharacterBody3D.new()
@onready var raycast = $RayCast3D
@onready var animplayer = $AnimationPlayer

@export var max_hitpoints = 20
@export var hitpoints = 20

enum {
	SPAWN,
	DIE,
	IDLE,
	FOLLOW,
	CHARGE,
	STUNNED
}

var in_range = false

var state = IDLE
@onready var stun_timer = $"Stun Timer"
@onready var attacked_timer = $"Attacked Timer"

var path = []
var path_node = 0

var last_state = -5

var can_attack = false
@export var mass = 75

func get_max_hp():
	return max_hitpoints

func get_hp():
	return hitpoints
	
func damage(damage):
	hitpoints -= damage
	print(hitpoints)
	if hitpoints <= 0:
		die()

signal die_signal()

func die():
	die_signal.emit()
	if(not attacked_timer.is_stopped()):
		killed()
		
	queue_free()

func killed():
	print("I was killed")
	pass
	
func _process(delta):
	if last_state != state:
		last_state = state
		print("State change")
		match state:
			SPAWN:
				animplayer.play("spawn")
			FOLLOW:
				animplayer.play("walk")
			IDLE:
				animplayer.play("idle")
			DIE:
				animplayer.play("die")
			CHARGE:
				animplayer.play("run")

func _physics_process(delta):
	if(can_attack and $"Attack Delay Timer".is_stopped()):
		attack(target)
		$"Attack Delay Timer".start()
		
	#print()
	var nav_target = target.global_transform.origin
	
	if is_on_floor():
		velocity.x -= velocity.x * FRICTION * delta
		velocity.z -= velocity.z * FRICTION * delta
		
	if nav_target and (state == FOLLOW or state == CHARGE):
		var time_to_target = (global_position.distance_to(nav_target) / velocity.length())
		var prediction_offset = target.velocity * time_to_target
		#print(time_to_target)
		#nav_target = nav_target + prediction_offset
		#print (nav_target)
	
		#print(nav_target)
		var direction = (nav_target - global_transform.origin).normalized()
		var accel = ACCEL
		
		if raycast.is_colliding():
			direction = direction * CHARGE_SPEED
			accel = CHARGE_ACCEL
			state = CHARGE
		else:
			direction = direction * SPEED
			state = FOLLOW
			
		direction.y = 0
		#print (direction)
		velocity.x = move_toward(velocity.x, direction.x, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z, accel * delta)
		
		look_at(nav_target +  + Vector3(0,1,0))
	
	velocity.y -= gravity * delta
	var last_velocity = velocity
	move_and_slide()
	
	for i in get_slide_collision_count():
		var body = get_slide_collision(i).get_collider()
		var angle = get_slide_collision(i).get_normal()
		
		if body.get_collision_layer_value(5):
			body.do_damage(self, last_velocity, angle)

func _on_timer_timeout():
	if(in_range):
		state = FOLLOW
	else:
		state = IDLE

func _on_detector_body_entered(body):
	print("DETECTED " + str(body))
	target = body
	in_range = true
	state = FOLLOW

func _on_detector_body_exited(body):
	in_range = false
	state = IDLE

func _on_bounce_body_entered(body):
	can_attack = true

func _on_bounce_body_exited(body):
	can_attack = false
	
func attack(body):
	#var bounce = global_transform.origin.direction_to(body.global_transform.origin) + Vector3(0,1,0)
	var body_momentum = body.get_momentum()
	var momentum = get_momentum()
	#print(bounce)
	#print(momentum)
	#var force = bounce * momentum
	
	var deltaV = (momentum - body_momentum) / mass
	body.pushed_by_enemy(self)
	
	#Lose momentum contest
	if body_momentum.length() > momentum.length():
		stun(1.5)
	else:
		deltaV = deltaV
		stun(0.75)
	
	velocity -= deltaV
	
func get_momentum():
	return mass * velocity
	
func get_mass():
	return mass

func stun(time):
	attacked_timer.start()
	state = STUNNED
	stun_timer.wait_time = time
	stun_timer.start()
	
func get_grapple_point():
	return $"grapple point".global_position
	
func set_grapple_point(point):
	$"grapple point".global_position = point


