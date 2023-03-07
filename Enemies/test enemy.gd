extends CharacterBody3D

const ACCEL = 15
const SPEED = 5
const CHARGE_ACCEL = 40
const CHARGE_SPEED = 35
const JUMP_VELOCITY = 4.5
const FRICTION = 0.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var target = CharacterBody3D.new()
@onready var raycast = $RayCast3D
@onready var animplayer = $AnimationPlayer

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

var path = []
var path_node = 0

var last_state = -5

var hit_points = 1

func damage():
	hit_points -= 1
	if hit_points <= 0:
		die()

func die():
	queue_free()
	
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
	move_and_slide()

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
	var bounce = global_transform.origin.direction_to(body.global_transform.origin) + Vector3(0,1,0)
	var momentum = (body.velocity - velocity).length() * 1
	#print(bounce)
	#print(momentum)
	var force = bounce * momentum
	if velocity.length() > body.velocity.length():
		body.velocity += force * 2
	else:
		velocity -= force * 3
		state = STUNNED
		stun_timer.start()
	


