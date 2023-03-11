extends Node


var score = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reset():
	score = 0
	
func award(amount):
	score += amount
	print(score)

func buy(amount):
	if amount <= score:
		score -= amount
		return true
	return false
