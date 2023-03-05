extends CharacterBody3D


const SPEED = 20.0
const FRICTION = 5
const ACCEL = 25
const JUMP_VELOCITY = 15

var num_jumps = 2
const MAX_JUMPS = 2
const WALL_JUMPS = 1
const GRAV_JUMP_MULT = 0.5

@export var up_vector = Vector3(0,1,0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sensitivity = 0.2
@onready var head = $head

func set_up_vector(v):
	var ang_error = rad_to_deg(Vector3.UP.angle_to(v))
	print("Deg: " + str(ang_error))
	
	if ang_error > 90:
		v = Vector3.UP
	
	up_vector = up_vector.lerp(v,0.1)
	
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
	look_at(global_transform.origin - transform.basis.z, up_vector)
	
	# Handle Jump.
	if is_on_floor():
		num_jumps = MAX_JUMPS
		
	elif is_on_wall():
		num_jumps = WALL_JUMPS
		
	if Input.is_action_just_pressed("Jump"):
		jump()

	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("Jump") and velocity.y > 0:
			velocity.y -= gravity * delta * GRAV_JUMP_MULT
		else:
			velocity.y -= gravity * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var direction
	
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		
			
		velocity.z = clamp(velocity.z + delta * direction.z * ACCEL, -SPEED, SPEED)
		velocity.x = clamp(velocity.x + delta * direction.x * ACCEL, -SPEED, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		velocity.z = move_toward(velocity.z, 0, FRICTION * delta)
		#velocity.y = move_toward(velocity.y, 0, FRICTION * delta)
	
	move_and_slide()
	
	
	
