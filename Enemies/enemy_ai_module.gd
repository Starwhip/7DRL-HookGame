extends Node3D

@export var far_detection_range = 30
@export var near_detection_range = 10
@export_enum("Walk","Fly") var AI_mode
@export var controller = Node.new()
@export_enum("Chase","Evade","Stay Close") var Behavior

var stun_effect = preload("res://Enemies/stun_effect.tscn")

var targeted_body = null
var target_close = false
var spawn_point = Vector3()
var retreat_pos = Vector3()

@export var attack_delay_time = 1.5
@export var slow_multiplier = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_point = global_position
	$"Far Range/Far Collision".shape.radius=far_detection_range
	$"Near Range/Near Collision".shape.radius=near_detection_range
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $"../../Stun Timer".is_stopped():
		return
		
	var target_pos
	var desired_speed = controller.speed
	if targeted_body:
		if $"Attack Delay".is_stopped():
			
			match Behavior:
				0:
					target_pos = targeted_body.global_position
					if not target_close:
						desired_speed *= slow_multiplier
					
				2:
					if target_close:
						target_pos = targeted_body.global_position 
						target_pos -= global_position.direction_to(target_pos)*near_detection_range
					else:
						target_pos = targeted_body.global_position
		else:
			target_pos = retreat_pos
		
	else:
		target_pos = spawn_point
	
	if target_pos:
		if target_pos == spawn_point or target_pos == retreat_pos:
			desired_speed = clamp(global_position.distance_to(target_pos)/controller.speed, 0, controller.speed)
			
		if AI_mode == 0:
			controller.target_location = target_pos
			controller.desired_direction = global_position.direction_to(target_pos) * Vector3(1,0,1)
			controller.desired_speed = desired_speed
			
		if AI_mode == 1:
			controller.target_location = target_pos
			controller.desired_direction = global_position.direction_to(target_pos)
			controller.desired_speed = desired_speed


func _on_far_range_body_entered(body):
	targeted_body = body		

func _on_far_range_body_exited(body):
	if body == targeted_body:
		targeted_body = null
		
func _on_near_range_body_entered(body):
	if(body == targeted_body):
		attack()
		target_close = true

func _on_near_range_body_exited(body):
	if body == targeted_body:
		target_close = false
		
func _on_physics_character_got_grappled():
	set_stun(true)

func _on_stun_timer_timeout():
	set_stun(false)


func _on_life_tracker_dead():
	$"../..".die(get_parent().global_position)


func _on_attack_window_timeout():
	print("Timeout")
	retreat()

func attack():
	if $"Attack Delay".is_stopped():
		$"Attack Window".start()
	
func retreat():
	$"Attack Delay".wait_time = attack_delay_time
	$"Attack Delay".start()
	retreat_pos = global_position + (Vector3.UP * 3)

func set_stun(enable):
	if enable:
		var new_effect = stun_effect.instantiate()
		add_child(new_effect)
		new_effect.position = Vector3(0,0,0)
		new_effect.emitting = true
		$"../../Stun Timer".start()
		controller.set_enabled(false)
	else:
		controller.set_enabled(true)
	
func _on_physics_character_was_hit(collision, last_velocity, normal):
	if get_parent().get_last_momentum().length() < collision.get_last_momentum().length():
		set_stun(true)
	
	retreat()
