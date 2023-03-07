extends Node3D

var mouseSensitivity = 0.3
var cameraAngle = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):	
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouseSensitivity))
		var verticalChange = event.relative.y * mouseSensitivity
		var minAngle = -60
		var maxAngle = 80
		if cameraAngle + verticalChange > minAngle and cameraAngle + verticalChange < maxAngle:
			cameraAngle += verticalChange
			$cameraVertical.rotate_x(deg_to_rad(verticalChange))
