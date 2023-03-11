extends Node

@export var player = Node3D.new()
@export var level_goal = Node3D.new()
@export var generator = Node3D.new()

@export var min_enemies_per_platform = 0
@export var max_enemies_per_platform = 2
@export var min_hazards_per_platform = 0
@export var max_hazards_per_platform = 3
@export var min_free_space_per_platform = 3

const ENEMY = preload("res://Enemies/physics enemy template.tscn")
const SPIKE_HAZARD = preload("res://Level/Components/spike_pillar.tscn")
const FLOOR_HAZARD = preload("res://Level/Components/spike floor.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_end_zone_body_entered(body):
	get_tree().paused = true
	$"../Physics Player".on_win()
	for child in get_children():
		child.queue_free()
	

func _on_dungeon_generator_level_generated(cells, platforms):
	var closest_cell
	var furthest_cell
	for cell in cells:
		if(not closest_cell or closest_cell.position.z > cell.position.z):
			closest_cell = cell			
			
		if(not furthest_cell or furthest_cell.position.z < cell.position.z):
			furthest_cell = cell
	
	var spawn_platform = get_platform_of_cell(furthest_cell, platforms)
	player.global_position = generator.cell_vec_to_global(Vector3(spawn_platform.get_center().x, furthest_cell.position.y + 35, spawn_platform.get_center().y))
	player.respawn()
	
	level_goal.position = generator.cell_to_global(closest_cell) + Vector3(0,8,0)

	for a_platform in platforms:
		if a_platform == spawn_platform:
			continue ##Ignore spawn platform
		var num_spaces = (a_platform.size.x * a_platform.size.y) - min_free_space_per_platform
		var taken_cells = []
		if num_spaces > 0:
			var num_enemies = randi_range(min_enemies_per_platform,clamp(max_enemies_per_platform,0,num_spaces))
			num_spaces -= num_enemies
			for i in num_enemies:
				var try_cell = generator.get_rand_cell_in_platform(a_platform)
				if not taken_cells.has(try_cell):
					taken_cells.append(try_cell)
					var new_enemy = ENEMY.instantiate()
					new_enemy.global_position = generator.cell_to_global(try_cell) + Vector3(0,12,0)
					add_child(new_enemy)
			
			var num_hazards = randi_range(min_hazards_per_platform, clamp(max_hazards_per_platform, 0, num_spaces))
			num_spaces -= num_hazards
			
			for i in num_hazards:
				var try_cell = generator.get_rand_cell_in_platform(a_platform)
				if not taken_cells.has(try_cell) and not try_cell == closest_cell:
					taken_cells.append(try_cell)
					
					var new_hazard
					match randi_range(0,1):
						0:
							new_hazard = SPIKE_HAZARD.instantiate()
						1:
							new_hazard = FLOOR_HAZARD.instantiate()
							
					new_hazard.global_position = generator.cell_to_global(try_cell) + Vector3(0,8,0)
					add_child(new_hazard)
					
					
func get_platform_of_cell(cell, platforms):
	for a_platform in platforms:
		print("Platform: " +str(a_platform.position) +", "+str(a_platform.end))
		print("Cell: "+str(cell.position))
		if a_platform.end.x >= cell.position.x and a_platform.position.x <= cell.position.x:
			if a_platform.end.y >= cell.position.z and a_platform.position.y <= cell.position.z:	
				print("Platform found: "+str(a_platform))
				return a_platform


func _on_physics_player_next_level():
	get_tree().paused = false
	generator.generate_dungeon();
