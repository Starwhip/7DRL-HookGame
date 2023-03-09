extends Node

@export var hit_points = 100
@export var max_hit_points = 100
@export var heal_rate = 2
@export var character = CharacterBody3D.new()
var stunned = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var last_hit_points = hit_points
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hit_points < max_hit_points:
		heal(heal_rate * delta)

	if hit_points <= 0:
		dead.emit()
	
	hit_points_update.emit(hit_points)

signal hit_points_update(hit_points)
signal hurt()
signal stun()

func damage(amount):
	hit_points -= amount
	hurt.emit()
		
func heal(amount):
	hit_points += amount
	
func spawn():
	print("Spawning")
	hit_points = 100

signal dead()

func _on_physics_player_spawn():
	spawn()

func _on_physics_character_hit_hazard(collision, last_velocity, normal):
	damage(collision.damage(character,last_velocity, normal))
