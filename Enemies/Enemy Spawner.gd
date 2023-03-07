extends Node3D

@export var enemy = load("")
@export var time = 10

@onready var timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = time
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	var new = enemy.instantiate()
	#new.global_position = global_position
	add_child(new)
	
	pass # Replace with function body.
