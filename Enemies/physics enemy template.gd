extends Node3D

@export var collision = CollisionShape3D.new()
@export var model = MeshInstance3D.new()

@export var ACCEL = 15
@export var SPEED = 5
@export var CHARGE_ACCEL = 40
@export var CHARGE_SPEED = 15
@export var JUMP_VELOCITY = 4.5

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Physics Character".mesh = model
	$"Physics Character".collision = collision
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
