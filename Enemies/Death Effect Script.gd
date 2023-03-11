extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


@export var death_effect = preload("res://Enemies/enemy_death.tscn")

func die(position):
	var effect = death_effect.instantiate()
	get_parent().add_child(effect)
	effect.global_position = position
	effect.emitting = true
	ScoreManager.award(10)
	queue_free()
