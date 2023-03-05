extends MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh = ImmediateMesh.new()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	# Prepare attributes for add_vertex.
	mesh.surface_set_normal(Vector3(0, 0, 1))
	mesh.surface_set_uv(Vector2(0, 0))
	# Call last for each vertex, adds the above attributes.
	mesh.surface_add_vertex(Vector3(0,0,0))
	
	mesh.surface_set_uv(Vector2(0, 1))
	mesh.surface_add_vertex($"../Grapple Hook Point".position)


	# End drawing.
	mesh.surface_end()
	
