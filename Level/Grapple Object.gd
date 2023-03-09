extends CharacterBody3D

@export var mass = 100
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var friction = 3
@onready var grapple_point = $"grapple point"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_mass():
	return mass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity -= velocity * friction * delta
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

func set_grapple_point(pos):
	grapple_point.global_position = pos

func get_grapple_point():
	return grapple_point.global_position
	
signal die_signal()

func stun(a):
	pass
