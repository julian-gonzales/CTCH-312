extends CSGCylinder3D

@export var player: Player

var SCORES = [20, 5, 12, 9, 14, 11, 8, 16, 7, 19, 3, 17, 2, 15, 10	, 6, 13, 4, 18, 1]
var is_playing: bool = false
var is_throwing: bool = false

var darts_used = 0
var score_remaining = 501

func _ready():
	pass

func _on_interactable_focused(interactor):
	pass

func _input(event):
	if(score_remaining==0):
		return
	
	if ((Input.is_action_just_pressed("shoot") || Input.is_action_just_pressed("jump")) && is_playing && !is_throwing):
		if(darts_used==3):
			clean_up_darts()
			clear_turn_score()
			darts_used = 0
		throw_dart()
		darts_used += 1
		is_throwing = true

func _on_interactable_interacted(interactor) -> void:
	is_throwing = false
	toggle_label_visibility()
	
	is_playing = !is_playing
	if(is_playing):
		var player_position = get_player_position()
		player.place_and_lock_player(player_position, self)
		
		player.show_dart()
		set_dart_board_interaction_depth(20)
		
		score_remaining = 501
		darts_used = 0
		$TotalScoreLabel.text = "Score: " + str(score_remaining)
		$TotalScoreLabel.modulate = Color.WHITE
		clear_turn_score()
	else:
		player.unlock_player(self)
		player.hide_dart()
		set_dart_board_interaction_depth(3)
		clean_up_darts()

func _on_interactable_unfocused(interactor):
	pass

func toggle_label_visibility():
	$TotalScoreLabel.visible = !$TotalScoreLabel.visible
	$RoundScores.visible = !$RoundScores.visible

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

func clear_turn_score() -> void:
	for score in $RoundScores.get_children():
		score.queue_free()

func dart_timer_timeout() -> void:
	darts_used -=1
	player.show_dart()
	is_throwing = false

func throw_dart() -> void:
	#Hide hand dart
	player.hide_dart()
	
	#Spawn dart
	var new_dart: Dart = load("res://Systems/DartGame/Dart.tscn").instantiate()
	new_dart.timeout_despawn.connect(dart_timer_timeout)
	
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
	
	#Start timeout
	new_dart.start_timer()

func _on_game_board_shape_body_entered(body) -> void:
	if !(body is Dart):
		return
	
	#Stop current dart & prevent despawn
	body.freeze = true
	body.get_node("Collision").free()
	body.stop_timer()
	
	#Get position of dart on 2d plane
	var tip = body.get_node('Tip').global_transform.origin
	tip = tip * global_transform
	
	
	var hit_point = Vector2(tip.x, tip.z)
	var distance_to_center = hit_point.length() * 10000
	
	var score
	var is_winnable: bool = false
	if(distance_to_center < 9): 	#Bullseye
		score = 50
		is_winnable = true
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
		is_winnable = true
	else:							#Out of bounds
		score = 0
	
	update_score(score, is_winnable)
	player.show_dart()
	is_throwing = false

func get_section_score(hit_point: Vector2) -> int:
	var zero_angle = $ZeroAngle.transform.origin
	var zero_angle_point = Vector2(zero_angle.x, zero_angle.z)
	var angle = hit_point.angle_to(zero_angle_point)
	var section = floor(20 * angle / (PI * 2))
	if(section) < 0:
		section +=20
	return SCORES[section]

func update_score(score: int, is_winnable: bool) -> void:
	#Scoring logic
	var bust: bool = true
	if(score_remaining - score > 1):
		score_remaining -= score
		bust = false
	elif(score_remaining - score == 0 and is_winnable):
		score_remaining -= score
		$TotalScoreLabel.modulate = Color.GREEN
		bust = false
	
	#Update UI
	$TotalScoreLabel.text = "Score: " + str(score_remaining)
	
	var new_label = Label3D.new()
	new_label.font = load("res://Art/Fonts/SpaceMono/SpaceMono-Regular.ttf")
	new_label.font_size = 2000
	new_label.outline_size = 127
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	new_label.text = "-" + str(score)
	new_label.global_position = $RoundScores.global_position
	new_label.global_position.y -= (darts_used * 10)
	if(bust):
		new_label.modulate = Color.RED
	$RoundScores.add_child(new_label)

	#Prevent additional throws on a turn
	if(bust):
		darts_used = 3
