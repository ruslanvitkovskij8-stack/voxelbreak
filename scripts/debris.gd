extends RigidBody3D

@onready var mesh_instance = $MeshInstance3D

func _ready():
	# BoxMesh для обломка
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.3, 0.3, 0.3)
	mesh_instance.mesh = box_mesh
	
	# Случайное направление
	linear_velocity = Vector3(randf_range(-2, 2), randf_range(2, 5), randf_range(-2, 2))
	angular_velocity = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	
	# Удаляем через 3 секунды
	await get_tree().create_timer(3.0).timeout
	queue_free()
