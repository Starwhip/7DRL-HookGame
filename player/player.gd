extends CharacterBody3D

@export var moveSpeed = 10
@export var moveAccel = 10
@export var jumpVelocity = 3
@export var GRAVITY = Vector3(0,-9.81,0)

var _snap_vector = Vector3.DOWN




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _clamp_float(x, min, max):
	if x > max:
		x = max
	if x < min:
		x = min
	return x
	
func _physics_process(delta):
	
	var velocityUpdate = Vector3(0,0,0)
	
	velocityUpdate.x = delta * (int(Input.is_action_pressed("Left")) - int(Input.is_action_pressed("Right"))) * moveSpeed
	velocityUpdate.z = delta * (int(Input.is_action_pressed("Forward")) - int(Input.is_action_pressed("Back"))) * moveSpeed
	
	velocityUpdate += delta * GRAVITY

	#velocityUpdate.x = _clamp_float(velocity.x, -moveSpeed, moveSpeed)
	#velocityUpdate.z = _clamp_float(velocity.z, -moveSpeed, moveSpeed)
	
	var is_jumping = is_on_floor() and Input.is_action_just_pressed("Jump")
	var just_landed = is_on_floor() and _snap_vector == Vector3.ZERO
		
	if is_jumping:
		velocityUpdate.y = jumpVelocity
		_snap_vector = Vector3.ZERO
	elif just_landed:
		_snap_vector = Vector3.DOWN
	
	#print(velocity)
	#print(delta)
	
	velocity = velocity + velocityUpdate
	
	move_and_slide()
		
