extends AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var min_speed = 20.0
var max_speed = 50.0
var min_db = -70
func _process(delta):
	
	if not get_parent().is_on_floor():
		var speed = get_parent().velocity.length()
		#print (speed)
		if speed > min_speed:
			if not playing:
				play()
			volume_db = lerpf(min_db, max_db, (speed-min_speed) / (max_speed-min_speed))
		else:
			stop()
	else:
		stop()
