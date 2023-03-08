extends Node

@export var hit_points = 100
@export var max_hit_points = 100
@export var stamina_points = 100
@export var heal_rate = 2

@onready var HUD = $"../HUD"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	HUD.hit_points = hit_points
	HUD.stamina_points = stamina_points
	
	if hit_points < max_hit_points:
		hit_points += heal_rate * delta

func reset():
	hit_points = 100
	stamina_points = 100
