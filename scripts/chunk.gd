extends Node3D

# Мир — чанк 32×32×32 вокселей. Хранится как PackedByteArray (1 = блок есть, 0 = пусто).
const CHUNK_SIZE = 32
var voxels = PackedByteArray()

# Сцена
@onready var mesh_instance = $MeshInstance3D
@onready var collision_shape = $CollisionShape3D
@onready var surface_tool = SurfaceTool.new()

# Вершины для коллизии (собираем в процессе построения меша)
var collision_vertices = PackedVector3Array()

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
	collision_vertices.clear()
	
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			for z in range(CHUNK_SIZE):
				if get_voxel(x, y, z) == 1:
					add_cube_faces(x, y, z)
	
	surface_tool.generate_normals()
	mesh_instance.mesh = surface_tool.commit()
	
	# Обновляем коллизию (ConcavePolygonShape3D)
	var shape = ConcavePolygonShape3D.new()
	# В Godot 4 ConcavePolygonShape3D использует массив граней (треугольников)
	# Формат: PackedVector3Array, где каждые 3 вершины — треугольник
	shape.set_faces(collision_vertices)
	collision_shape.shape = shape

func add_cube_faces(x: int, y: int, z: int) -> void:
	# Добавляем грани, если сосед пустой
	var size = 1.0
	var offset = Vector3(x, y, z) * size
	
	# Помощник для добавления грани (2 треугольника, 6 вершин)
	func add_face(normal: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3):
		surface_tool.set_normal(normal)
		# Треугольник 1
		surface_tool.add_vertex(v1)
		surface_tool.add_vertex(v2)
		surface_tool.add_vertex(v3)
		# Треугольник 2
		surface_tool.add_vertex(v1)
		surface_tool.add_vertex(v3)
		surface_tool.add_vertex(v4)
		
		# Для коллизии (каждый треугольник — 3 вершины)
		collision_vertices.append(v1)
		collision_vertices.append(v2)
		collision_vertices.append(v3)
		collision_vertices.append(v1)
		collision_vertices.append(v3)
		collision_vertices.append(v4)

	# Верх (Y+)
	if get_voxel(x, y + 1, z) == 0:
		add_face(Vector3.UP,
			offset + Vector3(0, size, 0),
			offset + Vector3(size, size, 0),
			offset + Vector3(size, size, size),
			offset + Vector3(0, size, size))
	
	# Низ (Y-)
	if get_voxel(x, y - 1, z) == 0:
		add_face(Vector3.DOWN,
			offset + Vector3(0, 0, 0),
			offset + Vector3(size, 0, 0),
			offset + Vector3(size, 0, size),
			offset + Vector3(0, 0, size))
	
	# Перед (Z+)
	if get_voxel(x, y, z + 1) == 0:
		add_face(Vector3.FORWARD,
			offset + Vector3(0, 0, size),
			offset + Vector3(size, 0, size),
			offset + Vector3(size, size, size),
			offset + Vector3(0, size, size))
	
	# Зад (Z-)
	if get_voxel(x, y, z - 1) == 0:
		add_face(Vector3.BACK,
			offset + Vector3(0, 0, 0),
			offset + Vector3(size, 0, 0),
			offset + Vector3(size, size, 0),
			offset + Vector3(0, size, 0))
	
	# Право (X+)
	if get_voxel(x + 1, y, z) == 0:
		add_face(Vector3.RIGHT,
			offset + Vector3(size, 0, 0),
			offset + Vector3(size, size, 0),
			offset + Vector3(size, size, size),
			offset + Vector3(size, 0, size))
	
	# Лево (X-)
	if get_voxel(x - 1, y, z) == 0:
		add_face(Vector3.LEFT,
			offset + Vector3(0, 0, 0),
			offset + Vector3(0, size, 0),
			offset + Vector3(0, size, size),
			offset + Vector3(0, size, size))

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

