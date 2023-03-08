extends StaticBody3D

@export var damage_per_velocity = 1.5
@export var base_damage = 5 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func do_damage(entity, velocity, normal):
	normal = -normal
	#print(str(self) + " is doing damage to "+str(entity))
	print("Normal: " + str(normal))
	print("Velocity: " + str(velocity))
	var normal_vel = (velocity.dot(normal) / normal.dot(normal)) * normal
	#print("Normalized velocity: "+str(normal_vel))
	
	entity.damage(normal_vel.length() * damage_per_velocity + base_damage)
	entity.velocity += -(normal_vel) * .5
