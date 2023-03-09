extends CanvasLayer

var hit_points = 0

@onready var health_bar = $HP/Health
@onready var stamina_bar = $HP/Stamina

var rope_length = 1.0
var reel_length = 1.0
var max_length = 1.0
@onready var rope_bar = $"Center Screen/Crosshair/Rope Length"
@onready var reel_bar = $"Center Screen/Crosshair/Reel Length"

@export var bar_rate = 15
# Called when the node enters the scene tree for the first time.

@onready var hurt = $Overlays/Hurt
@onready var stun = $Overlays/Stun

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var test = health_bar.value
	
	animate_bar(health_bar, hit_points, delta)
	animate_bar(rope_bar, rope_length, delta)
	animate_bar(reel_bar, reel_length, delta)
	
func animate_bar(bar, new, delta):
	bar.value = lerpf(bar.value, new, bar_rate*delta)
	
func _on_hurt_timer_timeout():
	hurt.hide()
		
func _on_stun_timer_timeout():
	stun.hide()

func _on_life_tracker_hit_points_update(hit_points):
	self.hit_points = hit_points

func _on_grapple_hook_reel_length_update(length):
	reel_length = length

func _on_grapple_hook_rope_length_update(length):
	rope_length = length

func _on_life_tracker_hurt():
	hurt.show()
	$"Overlays/Hurt Timer".start()

func _on_life_tracker_stun():
	stun.show()
	$"Overlays/Stun Timer".start()
