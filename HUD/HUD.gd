extends CanvasLayer

@export var hit_points = 0
@export var stagger_points = 0

@onready var health_bar = $HP/Health
@onready var stagger_bar = $HP/Stagger

@export var rope_length = 1.0
@onready var rope_bar = $"Center Screen/Crosshair/Rope Length"

@export var bar_rate = 5
# Called when the node enters the scene tree for the first time.

@onready var hurt = $Hurt
func _ready():
	print (health_bar.value)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var test = health_bar.value
	
	health_bar.value = lerpf(health_bar.value, hit_points, bar_rate * delta)
	stagger_bar.value = lerpf(stagger_bar.value, stagger_points, bar_rate * delta)

	rope_bar.value = lerpf(rope_bar.value, rope_length, bar_rate * delta)
	
func _on_timer_timeout():
	hurt.hide()
	pass # Replace with function body.


func _on_character_body_3d_hurt():
	hurt.show()
	$Timer.start()
