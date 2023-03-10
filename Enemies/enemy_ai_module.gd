extends Node3D

@export var far_detection_range = 30
@export var near_detection_range = 10
@export_enum("Walk","Fly") var AI_mode
@export var controller = Node.new()
@export_enum("Chase","Evade","Stay Close") var Behavior

var targeted_body = null
var target_close = false
var spawn_point = Vector3()
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_point = global_position
	$"Far Range/Far Collision".shape.radius=far_detection_range
	$"Near Range/Near Collision".shape.radius=near_detection_range

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target_pos
	var desired_speed = controller.speed
	if targeted_body:
		
		match Behavior:
			0:
				target_pos = targeted_body.global_position
				if not target_close:
					desired_speed *= 0.1
				
			2:
				if target_close:
					target_pos = targeted_body.global_position 
					target_pos -= global_position.direction_to(target_pos)*near_detection_range
				else:
					target_pos = targeted_body.global_position
				
		
	else:
		target_pos = spawn_point
		desired_speed = clamp(global_position.distance_to(target_pos), 0, controller.speed)
	
	if target_pos:
		controller.target_location = target_pos
		controller.desired_direction = global_position.direction_to(target_pos)
		controller.desired_speed = desired_speed


func _on_far_range_body_entered(body):
	print(body.get_collision_mask())
	if(body.get_collision_layer_value(2)):
		print("Far Entered")
		targeted_body = body

func _on_far_range_body_exited(body):
	if body == targeted_body:
		print("Far Exited")
		targeted_body = null

func _on_near_range_body_entered(body):
	if(body.get_collision_layer_value(2) and body == targeted_body):
		print("Near Entered")
		target_close = true

func _on_near_range_body_exited(body):
	if body == targeted_body:
		print("Near Exited")
		target_close = false
