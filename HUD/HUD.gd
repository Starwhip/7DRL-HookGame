extends CanvasLayer

@export var hit_points = 0
@export var stamina_points = 0

@onready var health_bar = $HP/Health
@onready var stamina_bar = $HP/Stamina

var rope_length = 1.0
var reel_length = 1.0
var max_length = 1.0
@onready var rope_bar = $"Center Screen/Crosshair/Rope Length"
@onready var reel_bar = $"Center Screen/Crosshair/Reel Length"

@export var bar_rate = 15
# Called when the node enters the scene tree for the first time.

@onready var hurt = $Hurt
@onready var stun = $Stun

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var test = health_bar.value
	
	animate_bar(health_bar, hit_points, delta)
	animate_bar(stamina_bar, stamina_points, delta)
	animate_bar(rope_bar, rope_length, delta)
	animate_bar(reel_bar, reel_length, delta)
	
	rope_bar.max_value = max_length
	reel_bar.max_value = max_length
	
func animate_bar(bar, new, delta):
	bar.value = lerpf(bar.value, new, bar_rate*delta)
	
func _on_timer_timeout():
	hurt.hide()
	pass # Replace with function body.


func _on_character_body_3d_hurt():
	hurt.show()
	$Timer.start()
	
func _on_character_body_3d_stun():
	stun.show()

func _on_stun_timer_timeout():
	stun.hide()
