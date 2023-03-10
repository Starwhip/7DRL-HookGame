extends Node3D

@export var entity_life = Node.new()
@onready var bar = $"Health Bar"

@export var bar_rate = 15
var offset
# Called when the node enters the scene tree for the first time.
func _ready():
	offset =  Vector2(-bar.size.x/2,-bar.size.y/2)
	bar.max_value = entity_life.max_hit_points
	bar.value = entity_life.hit_points
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	bar.value = lerpf(bar.value, entity_life.hit_points, bar_rate*delta)
	
	var camera = get_viewport().get_camera_3d()
	if camera.is_position_behind(global_position):
		hide()
	else:
		show()
		bar.position = camera.unproject_position(global_position) + offset
