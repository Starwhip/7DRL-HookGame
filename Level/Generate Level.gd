extends Node3D

const ARENA = preload("res://Level/Components/Platform.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	var path = $Path3D
	path.curve.add_point(Vector3(0,0,0))
	
	var distance = 0
	var vector = Vector3(0,0,-1)
	var last_point = Vector3(0,0,0)
	
	for i in 100:
		print ("Vector: "+str(vector))
		distance = randf_range(50,100)
		print (vector * distance)
		var new_point = last_point + (vector * distance)
		last_point = new_point 
		path.curve.add_point(new_point)
		
		vector = vector.rotated(Vector3.RIGHT, randf_range(-.1,1))
		vector = vector.rotated(Vector3.UP, randf_range(-.5,.1))
	
	for i in 100:
		$Path3D/PathFollow3D.set_progress_ratio(i/100.0)
		var new_arena = ARENA.instantiate()
		new_arena.position = $"Path3D/PathFollow3D/Spawn Position".global_position
		print(new_arena.position)
		add_child(new_arena)
			
	#print(path.curve.get_baked_points())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
