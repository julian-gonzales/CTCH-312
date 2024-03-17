extends CSGCylinder3D

@export var player: Player

var SCORES = [20, 5, 12, 9, 14, 11, 8, 16, 7, 19, 3, 17, 2, 15, 10	, 6, 13, 4, 18, 1]
var is_playing: bool = false

func _on_interactable_focused(interactor):
	pass

func _input(event):
	if Input.is_action_just_pressed("jump") && is_playing:
		throw_dart()

func _on_interactable_interacted(interactor):
	is_playing = !is_playing
	if(is_playing):
		var player_position = get_player_position()
		player.place_and_lock_player(player_position, self)
		player.show_dart()
		set_dart_board_interaction_depth(20)
	else:
		player.unlock_player(self)
		player.hide_dart()
		set_dart_board_interaction_depth(3)
		clean_up_darts()

func _on_interactable_unfocused(interactor):
	pass

func set_dart_board_interaction_depth(height: float) -> void:
	$StartEndInteractable/CollisionShape3D.shape.height = height

func get_player_position() -> Vector3:
	var dartboard_position = $".".position
	var rotation: Vector3 = self.rotation
	
	var x_offset = round((sin(rotation.y) * 4) * 1000) / 1000
	var z_offset = round((cos(rotation.y) * 4) * 1000) / 1000

	return Vector3(dartboard_position.x + x_offset, player.position.y, dartboard_position.z + z_offset)

func clean_up_darts() -> void:
	for dart in $Darts.get_children():
		dart.queue_free()

func throw_dart():
	#Hide hand dart
	player.hide_dart()
	
	#Spawn dart
	var new_dart: RigidBody3D = load("res://Systems/DartGame/Dart.tscn").instantiate()
	
	#Add to tree
	$Darts.add_child(new_dart)
	
	#Place & rotate dart to match hand
	var hand_dart = player.get_node("Head/Camera3D/Dart")
	new_dart.global_position = hand_dart.global_position
	new_dart.global_transform.basis = player.get_node("Head/Camera3D/Dart").global_transform.basis

	#Apply velocity:
	var direction = - new_dart.global_transform.basis.z
	var velocity = direction * 100	
	new_dart.linear_velocity = velocity
	new_dart.gravity_scale = 0.5


func _on_game_board_shape_body_entered(body):
	if !(body is Dart):
		return

	player.show_dart()
	
	#Stop current dart
	body.freeze = true
	body.get_node("Collision").free()
	
	
	var tip = body.get_node('Tip').global_transform.origin
	tip = tip * global_transform
	
	
	var hit_point = Vector2(tip.x, tip.z)
	var distance_to_center = hit_point.length() * 10000
	
	var score
	if(distance_to_center < 9): 	#Bullseye
		score = 50
	elif(distance_to_center < 18.): #Bull ring
		score = 25
	elif(distance_to_center < 100): #Inner ring
		score = get_section_score(hit_point)
	elif(distance_to_center < 110): #Triples ring
		score = 3 * get_section_score(hit_point)
	elif(distance_to_center < 175): #Outer ring
		score = get_section_score(hit_point)
	elif(distance_to_center < 185): #Doubles ring
		score = 2 * get_section_score(hit_point)
	else:							#Out of bounds
		score = 0
	
	print(score)

func get_section_score(hit_point: Vector2) -> int:
	var zero_angle = $ZeroAngle.transform.origin
	var zero_angle_point = Vector2(zero_angle.x, zero_angle.z)
	var angle = hit_point.angle_to(zero_angle_point)
	var section = floor(20 * angle / (PI * 2))
	if(section) < 0:
		section +=20
	return SCORES[section]
