extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().title = "Untitled Hook Game"
	pass # Replace with function body.


func _on_play_pressed():
	get_tree().change_scene_to_file("res://Level/Procedural Dungeon/Dungeon Generator.tscn")


func _on_quit_pressed():
	get_tree().quit()
