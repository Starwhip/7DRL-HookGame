extends ProgressBar

@onready var entity = $"../.."
@onready var anchor = $".."

@export var bar_rate = 15
var offset = Vector2(-size.x/2,-size.y/2)
# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = entity.get_max_hp()
	value = entity.get_hp()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = lerpf(value, entity.get_hp(), bar_rate*delta)
	
	var camera = get_viewport().get_camera_3d()
	if camera.is_position_behind(anchor.global_position):
		hide()
	else:
		show()
		position = camera.unproject_position(anchor.global_position) + offset
