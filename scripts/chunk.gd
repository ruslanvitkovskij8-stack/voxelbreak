extends Node3D

# Мир — чанк 32×32×32 вокселей. Хранится как PackedByteArray (1 = блок есть, 0 = пусто).
const CHUNK_SIZE = 32
var voxels = PackedByteArray()

# Сцена
@onready var mesh_instance = $MeshInstance3D
@onready var collision_shape = $CollisionShape3D
@onready var surface_tool = SurfaceTool.new()

func _ready():
	voxels.resize(CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE)
	# Заполняем тестовым кубом
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			for z in range(CHUNK_SIZE):
				if x > 10 and x < 22 and y > 5 and y < 25 and z > 10 and z < 22:
					voxels.set(get_index(x, y, z), 1)
	update_mesh()

func get_index(x: int, y: int, z: int) -> int:
	return x + y * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE

func get_voxel(x: int, y: int, z: int) -> int:
	if x < 0 or x >= CHUNK_SIZE or y < 0 or y >= CHUNK_SIZE or z < 0 or z >= CHUNK_SIZE:
		return 0 # Пусто за границами
	return voxels.get(get_index(x, y, z))

func set_voxel(x: int, y: int, z: int, value: int) -> void:
	if x < 0 or x >= CHUNK_SIZE or y < 0 or y >= CHUNK_SIZE or z < 0 or z >= CHUNK_SIZE:
		return
	voxels.set(get_index(x, y, z), value)

func update_mesh() -> void:
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			for z in range(CHUNK_SIZE):
				if get_voxel(x, y, z) == 1:
					add_cube_faces(x, y, z)
	
	surface_tool.generate_normals()
	surface_tool.commit(mesh_instance)
	
	# Обновляем коллизию (ConcavePolygonShape3D)
	var polygon = ConcavePolygonShape3D.new()
	# В реальной реализации здесь собираются те же вершины в полигоны
	# Для простоты на первом этапе используем массив вершин из surface_tool
	polygon.faces = surface_tool.get_index_array() # Псевдокод, в Godot нужно конвертировать в полигоны
	collision_shape.shape = polygon

func add_cube_faces(x: int, y: int, z: int) -> void:
	# Добавляем грани, если сосед пустой
	var size = 1.0
	var offset = Vector3(x, y, z) * size
	
	# Пример: верхняя грань
	if get_voxel(x, y + 1, z) == 0:
		surface_tool.set_normal(Vector3.UP)
		surface_tool.add_vertex(offset + Vector3(0, size, 0))
		surface_tool.add_vertex(offset + Vector3(size, size, 0))
		surface_tool.add_vertex(offset + Vector3(size, size, size))
		surface_tool.add_vertex(offset + Vector3(0, size, size))
		# ... остальные вершины и треугольники для всех 6 граней ...
		# (полная реализация граней будет добавлена в следующем этапе)

func destroy_voxels(center: Vector3, radius: int) -> void:
	var changed = false
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			for z in range(-radius, radius + 1):
				var cx = int(center.x) + x
				var cy = int(center.y) + y
				var cz = int(center.z) + z
				if get_voxel(cx, cy, cz) == 1:
					set_voxel(cx, cy, cz, 0)
					changed = true
	if changed:
		update_mesh()
