extends AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var last_foot_pos = Vector3(0,0,0)
@export var stride_length = 2
func _process(delta):
	var distance = get_parent().global_position.distance_to(last_foot_pos)
	
	if get_parent().is_on_floor() and not playing and distance >= stride_length:
		play()
		last_foot_pos = get_parent().global_position
	
