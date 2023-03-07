extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func respawn():
	$CharacterBody3D.position = Vector3(0,0,0)
	$CharacterBody3D.velocity = Vector3(0,0,0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $CharacterBody3D.global_position.y < -150:
		respawn()

func _on_character_body_3d_dead():
	print("Respawning")
	respawn()
