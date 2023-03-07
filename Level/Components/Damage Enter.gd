extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _on_body_entered(body):
	body.damage()
	body.velocity = -(0.7 * body.velocity) + (5 * global_position.direction_to(body.global_position) * Vector3(1,0,1))
