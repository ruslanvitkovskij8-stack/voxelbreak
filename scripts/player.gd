extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8
@export var camera_sensitivity: float = 0.002

@onready var camera = $Camera3D
@onready var chunk_node = $../Chunk/ChunkScript

var mouse_delta = Vector2.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		camera.rotation_degrees.x -= mouse_delta.y * camera_sensitivity
		rotation_degrees.y -= mouse_delta.x * camera_sensitivity
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		direction += -global_transform.basis.z
	if Input.is_key_pressed(KEY_S):
		direction += global_transform.basis.z
	if Input.is_key_pressed(KEY_A):
		direction += -global_transform.basis.x
	if Input.is_key_pressed(KEY_D):
		direction += global_transform.basis.x
	
	direction = direction.normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	# Гравитация
	velocity.y -= gravity * delta
	
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = jump_velocity
	
	move_and_slide()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		fire_ray()

func fire_ray():
	# Луч из камеры через PhysicsDirectSpaceState3D.intersect_ray()
	# camera смотрит в -basis.z, поэтому направление -basis.z
	var space_state = get_world_3d().direct_space_state
	var from = camera.global_transform.origin
	var to = from + (-camera.global_transform.basis.z) * 100.0
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		print("Hit at: ", result.position)
		# Вызываем destroy_voxels у чанка
		chunk_node.destroy_voxels(result.position, 2)

