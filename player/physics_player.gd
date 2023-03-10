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
	
func respawn():
	spawn.emit()

func get_player():
	return $"Physics Character"
