extends StaticBody3D

@export var damage_per_velocity = 1.5
@export var base_damage = 5 
@export var velocity_damp = 0.5
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func damage(entity, velocity, normal):
	normal = -normal
	var normal_vel = (velocity.dot(normal) / normal.dot(normal)) * normal

	return normal_vel.length() * damage_per_velocity + base_damage #Damage calculation
