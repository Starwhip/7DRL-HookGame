extends Node3D

@export var player = Node3D.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func respawn():
	print("Respawn Triggered")
	player.respawn()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(player.get_player().global_position)
	if player.get_player().global_position.y < 0:
		respawn()

func _on_physics_player_dead():
	print("respawning")
	respawn()
