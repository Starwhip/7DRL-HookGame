extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

signal dead()
signal spawn()

func _on_life_tracker_dead():
	print("dead")
	dead.emit()
	var death = load("res://Main/death_screen.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_player().velocity = Vector3(0,0,0)
	$"Character Input Controller".stunned = true
	$"Character Input Controller".enabled = false
	$HUD.add_child(death.instantiate())
	
func respawn():
	spawn.emit()

func get_player():
	return $"Physics Character"
	
func on_win():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$HUD.hide()
	$"Upgrade System".show()
	$"Upgrade System/AudioStreamPlayer2".play()

func _on_grapple_length_pressed():
	if ScoreManager.buy(100):
		$"Physics Character/head/Grapple Hook".max_length += 5
		$"Physics Character/head/Grapple Hook".hook_launch_velocity += 5
	pass # Replace with function body.


func _on_grapple_reel_pressed():
	if ScoreManager.buy(100):
		$"Physics Character/head/Grapple Hook".reel_rate += 5
	pass # Replace with function body.


func _on_speed_pressed():
	if ScoreManager.buy(250):
		$"Character Input Controller".speed *= 1.1
		$"Character Input Controller".acceleration *= 1.025
	pass # Replace with function body.


func _on_momentum_pressed():
	if ScoreManager.buy(300):
		$"Physics Character".mass *= 1.125
	pass # Replace with function body.

signal next_level()
	
func _on_continue_button_up():
	$HUD.show()
	$"Upgrade System".hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	next_level.emit()
