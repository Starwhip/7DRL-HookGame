extends Node3D

@export var width = 70
@export var height = 15

@export var cell_width = 8
@export var cell_height = 8

@export var offset = 1


const COLUMN = preload("res://assets/Pretty Models/Platform Column.tscn")
const CENTER = preload("res://assets/Pretty Models/Platform Center.tscn")
const CORNER = preload("res://assets/Pretty Models/Platform Corner.tscn")
const EDGE = preload("res://assets/Pretty Models/Platform Edge.tscn")

class Cell:
	var position: Vector3
	var rotation: Vector3
	enum type {CENTER, CORNER, EDGE}
	var cell_type: type
		
var cells = []

signal level_generated(cells,platforms)

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_dungeon()

func generate_dungeon():
	cells = []
	for child in self.get_children():
		#print(child.get_parent())
		child.queue_free()
	
	var spaces = Rect2i(0,0,width,height)
	var split_spaces = binary_space_partition(spaces,4,4)
	#for space in split_spaces:
		#print("Space: "+str(space.position) + ", " + str(space.size))
	create_platforms(split_spaces, cells)

	#Spawn meshes for the platforms
	for cell in cells:
		var new_scene
		match cell.cell_type:
			Cell.type.CENTER:
				new_scene = CENTER.instantiate()
			Cell.type.CORNER:
				new_scene = CORNER.instantiate()
			Cell.type.EDGE:	
				new_scene = EDGE.instantiate()
				
		var offset_size = Vector3(1, 1, 1)
		#new_mesh.mesh.size = offset_size * Vector3(cell_width, 1, cell_height)
		new_scene.position = cell_to_global(cell)#offset_pos * Vector3(cell_width, 1, cell_height)
		new_scene.rotation = cell.rotation
		
		
		add_child(new_scene)
		
		if cell.cell_type == Cell.type.CENTER:
			var column = COLUMN.instantiate()
			
			column.position = cell_to_global(cell) + Vector3(0,-102,0)
			add_child(column)	
	
	level_generated.emit(cells,split_spaces)

func cell_to_global(cell: Cell) -> Vector3:
	return Vector3((cell.position.x + 0.5) * cell_width, cell.position.y, (cell.position.z + 0.5) * cell_height)

func cell_vec_to_global(vec: Vector3) -> Vector3:
	return Vector3((vec.x + 0.5) * cell_width, vec.y, (vec.z + 0.5) * cell_height)
	
func get_rand_cell_in_platform(platform):
	var target_cells = []
	for a_cell in cells:
		if platform.end.x >= a_cell.position.x and platform.position.x <= a_cell.position.x:
			if platform.end.y >= a_cell.position.z and platform.position.y <= a_cell.position.z:	
				target_cells.append(a_cell)
	
	return target_cells.pick_random()
	
func create_platforms(spaces: Array, cells: Array):
	for space in spaces:
		var vertical_offset = randf_range(10,75);
		if 2 * offset >= space.size.x or 2 * offset >= space.size.y:
			return
			
		print(space)
		
		var col_start = offset
		var col_end = space.size.x - offset
		var row_start = offset
		var row_end = space.size.y - offset
		
		for col in range(col_start, col_end):
			for row in range(row_start, row_end):
				var new_pos: Vector3i = Vector3(space.position.x + col, vertical_offset, space.position.y + row)
				var new_cell: Cell = Cell.new()
				new_cell.position = new_pos
				
				new_cell.rotation = Vector3(0,0,0)
				if (col == col_start or col == col_end-1) and (row == row_start or row == row_end-1):
					new_cell.cell_type = Cell.type.CORNER
					if(col == col_start and row == row_start):
						new_cell.rotation = Vector3(0,deg_to_rad(0),0)
					elif(col == col_end-1 and row == row_start):
						new_cell.rotation = Vector3(0,deg_to_rad(270),0)
					elif(col == col_start and row == row_end-1):
						new_cell.rotation = Vector3(0,deg_to_rad(90),0)
					else:
						new_cell.rotation = Vector3(0,deg_to_rad(180),0)
						
						
				elif(col == col_start or col == col_end-1) or (row == row_start or row == row_end-1):
					new_cell.cell_type = Cell.type.EDGE
					
					if(col == col_start):
						new_cell.rotation = Vector3(0,deg_to_rad(90),0)
					elif(col == col_end-1):
						new_cell.rotation = Vector3(0,deg_to_rad(270),0)
					elif(row == row_end-1):
						new_cell.rotation = Vector3(0,deg_to_rad(180),0)
					else:
						new_cell.rotation = Vector3(0,deg_to_rad(0),0)
				
				else:
					new_cell.cell_type = Cell.type.CENTER
				cells.append(new_cell)
		
				
func walk(num_steps, x, y):
	print("walking")
	if num_steps <= 0:
		return
		
	var direction = randi_range(1,4)
	match direction:
		1:
			y -= 1
		2:
			y += 1
		3:
			x -= 1
		4:
			x += 1

	if out_of_bounds(x,y):
		return
	
	cells[x][y] = 0
	#print(str(x) + ", "+str(y))
	walk(num_steps - 1, x, y)
	
func percent_open():
	var sum = 0
	for row in height:
		for col in width:
			sum += cells[row][col]
	
	return width * height - sum
	
func get_cell_in_dungeon():
	while(true):
		var x = randi_range(1,width-2)
		var y = randi_range(1,height-2)
		
		var center_x = width / 2
		var center_y = height / 2
		
		var direction_vector = Vector2(center_x - x, center_y - y).normalized()
		var step_length = 0.5
		
		while(true):
			x += direction_vector.x * step_length
			y += direction_vector.y * step_length
			
			if out_of_bounds(x,y):
				break;
				
			if(cells[floor(y)][floor(x)] == 0):
				return Vector2(floor(x),floor(y))

func out_of_bounds(x,y):
	#print(x)
	#print(y)
	if x <= 0 or x >= width-1:
		return true
	if y <= 0 or y >= height-1:
		return true
	
	return false
	
func binary_space_partition(spaceToSplit: Rect2i, min_width: int, min_height: int) -> Array:
	var space_queue = []
	var new_spaces = []
	
	space_queue.append(spaceToSplit)

	while (space_queue.size() > 0):
		#print("Space Queue:" + str(space_queue))
		#print("Finished Spaces:" + str(new_spaces))

		var space : Rect2i = space_queue.pop_front()
		var size = abs(space.size)
		if size.x > min_width and size.y > min_height:
			if randf_range(0.0,1.0) < 0.5:
				if(size.y >= min_height * 2):
					split_horizontally(min_height,space_queue,space)
					
				elif(size.x >= min_width * 2):
					split_vertically(min_width,space_queue,space)
					
				elif(size.x >= min_width and size.y >= min_height):
					new_spaces.append(space)
			else:
				if(size.x >= min_width * 2):
					split_vertically(min_width,space_queue,space)
					
				elif(size.y >= min_height * 2):
					split_horizontally(min_height,space_queue,space)
					
				elif(size.x >= min_width and size.y >= min_height):
					new_spaces.append(space)
				
	return new_spaces

func split_horizontally(min_height: int, space_queue: Array, space: Rect2i):
	var y_split: int = randi_range(1,space.size.y-1)
	#var y_split: int = randi_range(min_height,space.size.y-min_height)
	var space1: Rect2i = Rect2i(space.position, Vector2i(space.size.x, y_split))	
	var space2: Rect2i = Rect2i(space.position + Vector2i(0, y_split), Vector2i(space.size.x, space.size.y - y_split))
	space_queue.append(space1)
	space_queue.append(space2)
	

func split_vertically(min_width: int, space_queue: Array, space: Rect2i):
	var x_split: int = randi_range(1,space.size.x-1)
	#var x_split: int = randi_range(min_width,space.size.x-min_width)
	var space1: Rect2i = Rect2i(space.position, Vector2i(x_split, space.size.y))	
	var space2: Rect2i = Rect2i(space.position + Vector2i(x_split, 0), Vector2i(space.size.x - x_split, space.size.y))
	space_queue.append(space1)
	space_queue.append(space2)
	
func display_walked_dungeon():
	#var walk_distance = (width * height) * .05
	#walk(walk_distance, randi_range(1,width-2), randi_range(1,height-2))	
	#while percent_open() < (width * height * .3):
	#	var pos = get_cell_in_dungeon()
	#	walk(walk_distance, pos.x, pos.y)
	
	#var spawn = get_cell_in_dungeon()
	#$"Player Spawn".position = Vector3(spawn.x * cell_width,(ceiling_height-floor_height)/2,spawn.y * cell_height)
	
	for row in height:
		for col in width:
			if cells[row][col] == 0:
				pass
#				var depth = randf_range(floor_height,dungeon_depth-1)
#				var height = randf_range(ceiling_height,dungeon_height-1)
#
#				#var new_cell_top = MeshInstance3D.new()
#				var new_cell_bot = MeshInstance3D.new()
#				new_cell_bot.mesh = BoxMesh.new()
#				#ew_cell_top.mesh = BoxMesh.new()
#				new_cell_bot.mesh.size = Vector3(cell_width, dungeon_depth - depth, cell_height)
#				#new_cell_top.mesh.size = Vector3(cell_width, dungeon_height - height, cell_height)
#				new_cell_bot.position = Vector3(cell_width * col, -(dungeon_depth/2) - (depth/2), cell_height * row)
#				#new_cell_top.position = Vector3(cell_width * col, (dungeon_height/2) + height/2, cell_height * row)
#
#				new_cell_bot.create_convex_collision()
#				#new_cell_top.create_convex_collision()
#
#				add_child(new_cell_bot)
#				#add_child(new_cell_top)
			else:
				pass
#				var new_cell_bot = MeshInstance3D.new()
#				new_cell_bot.mesh = BoxMesh.new()
#				new_cell_bot.mesh.size = Vector3(cell_width, dungeon_depth + dungeon_height, cell_height)
#				new_cell_bot.position = Vector3(cell_width * col, (dungeon_height / 2) - (dungeon_depth / 2), cell_height * row)
#				new_cell_bot.create_convex_collision()
#				add_child(new_cell_bot)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
