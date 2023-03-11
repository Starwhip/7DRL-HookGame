extends ProgressBar

@onready var mirror = get_child(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	mirror.value = value
