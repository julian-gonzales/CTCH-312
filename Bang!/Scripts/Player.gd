class_name Player extends CharacterBody3D

@onready var head = $Head

var can_move : bool = true

var curr_speed : float = 5.0
var walking_speed : float = 5.0
var sprint_speed : float = 8.0

const JUMP_VELOCITY : float = 4.5
const MOUSE_SENS : float = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENS))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	
	if Input.is_action_pressed("sprint"):
		curr_speed = sprint_speed
	else:
		curr_speed = walking_speed
	
	if Input.is_action_pressed("mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and can_move:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * curr_speed
		velocity.z = direction.z * curr_speed
	else:
		velocity.x = move_toward(velocity.x, 0, curr_speed)
		velocity.z = move_toward(velocity.z, 0, curr_speed)

	if can_move:
		move_and_slide()

func place_and_lock_player(player_position: Vector3, target: Node3D):
	#Place player
	self.position = player_position
	
	#Face target
	var direction = target.global_transform.origin - $Head/Camera3D.global_transform.origin
	global_transform.basis = Basis().looking_at(direction, Vector3(0, 1, 0))
	
	#Lock
	can_move = false

func unlock_player(target):
	can_move = true

func show_dart():
	$Head/Camera3D/Dart.show()

func hide_dart():
	$Head/Camera3D/Dart.hide()
