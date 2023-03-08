extends Node3D

@export var line_radius = 0.1
@export var line_resolution = 180

@onready var hook_point = $"../../Grapple Hook Point"
	
# Called when the node enters the scene tree for the first time.
func _ready():
	var circle = PackedVector2Array()
	for degree in line_resolution:
		var x = line_radius * sin(PI * 2 * degree/line_resolution)
		var y = line_radius * -cos(PI * 2 * degree/line_resolution)
		var coords = Vector2(x,y)
		circle.append(coords)
		
	$CSGPolygon3D.polygon = circle
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if hook_point.is_visible_in_tree():
		show()

		var points = $"../..".hook_point_array.duplicate()
		var start = Vector3(0,0,0)
		var end = to_local(hook_point.global_position)
		var curve = Curve3D.new() 
		curve.add_point(start)
		
		for i in points.size()-1:
			curve.add_point(self.to_local(points.pop_back()))
			
		curve.add_point(end)
		
		$"Grapple Hook Rope".curve = curve
	else:
		hide()	
	
