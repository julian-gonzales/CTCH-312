extends CSGCylinder3D

@export var player: Player

const SCORES = [20, 5, 12, 9, 14, 11, 8, 16, 7, 19, 3, 17, 2, 15, 10, 6, 13, 4, 18, 1]
var is_playing: bool = false
var is_throwing: bool = false
var is_setup: bool = true

var total_darts_thrown = 0
var round_darts_used = 0
var score_remaining = 501
var dart_game_mode = Global.DART_MODE.FIVE_HUNDRED_ONE

var perfect_win_count = 0
var perfect_win_color_state = 0
const PERFECT_WIN_COLORS = [Color.RED, Color.ORANGE_RED, Color.YELLOW, Color.GREEN, Color.BLUE, Color.DODGER_BLUE, Color.INDIGO]

signal update_score(score: int, is_double: bool, is_triple: bool)
signal update_high_score(mode: int)
signal toggle_crosshair()

func _ready():
	#Ensure labels start with hidden
	$SelectionLabels.visible = false
	$GameLabels.visible = false
	Global.initialize_dart_scores()

func _input(event):
	if(score_remaining==0):
		return
	
	if ((Input.is_action_just_pressed("shoot") || Input.is_action_just_pressed("jump")) && is_playing && !is_throwing):
		if(is_setup):
			throw_dart()
			return

		if(round_darts_used==3):
			clean_up_darts()
			clear_turn_score()
			round_darts_used = 0
		throw_dart()
		round_darts_used += 1
		total_darts_thrown +=1
		is_throwing = true

func _on_interactable_interacted(interactor) -> void:
	is_throwing = false
	
	
	is_playing = !is_playing
	if(is_playing):
		var player_position = get_player_position()
		player.place_and_lock_player(player_position, self)
		
		player.show_dart()
		set_dart_board_interaction_depth(20)
		
		total_darts_thrown = 0
		round_darts_used = 0
		clear_turn_score()
		
		toggle_selection_label_visibility()
		toggle_crosshair.emit()
	else:
		player.unlock_player(self)
		player.hide_dart()
		set_dart_board_interaction_depth(3)
		$PerfectWinTimer.stop()
		clean_up_darts()
		
		#Hide current label
		if(is_setup):
			toggle_selection_label_visibility()
		else:
			toggle_game_label_visibility()
		
		#Reset for next game
		is_setup = true
		score_remaining = 501
		if(update_score.is_connected(update_score_game_total_to_0)):
			update_score.disconnect(update_score_game_total_to_0)
		elif(update_score.is_connected(update_score_game_around_the_world)):
			update_score.disconnect(update_score_game_around_the_world)
			
		toggle_crosshair.emit()

func toggle_selection_label_visibility():
	$SelectionLabels.visible = !$SelectionLabels.visible

func toggle_game_label_visibility():
	$GameLabels.visible = !$GameLabels.visible

func reset_game_labels():
	$GameLabels/ScoreCountLabel.text = str(score_remaining)
	$GameLabels/DartsCountLabel.text = str(total_darts_thrown)
	$GameLabels/TotalDartsLabel.modulate = Color.WHITE
	$GameLabels/DartsCountLabel.modulate = Color.WHITE
	$GameLabels/TotalScoreLabel.modulate = Color.WHITE
	$GameLabels/ScoreCountLabel.modulate = Color.WHITE

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
	for score in $GameLabels/RoundScores.get_children():
		score.queue_free()

func dart_timer_timeout() -> void:
	round_darts_used -=1
	total_darts_thrown -=1
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
	var is_double: bool = false
	var is_triple: bool = false
	if(distance_to_center < 9): 	#Bullseye
		score = 50
	elif(distance_to_center < 18.): #Bull ring
		score = 25
	elif(distance_to_center < 100): #Inner ring
		score = get_section_score(hit_point)
	elif(distance_to_center < 110): #Triples ring
		score = 3 * get_section_score(hit_point)
		is_triple = true
	elif(distance_to_center < 175): #Outer ring
		score = get_section_score(hit_point)
	elif(distance_to_center < 185): #Doubles ring
		score = 2 * get_section_score(hit_point)
		is_double = true
	else:							#Out of bounds
		score = 0
	
	if(is_setup):
		var original_score = score
		
		#Remove triple/double to just get slice
		if(is_double):original_score /= 2
		elif(is_triple):original_score /= 3
		
		player.show_dart()
		is_throwing = false
		start_game(original_score)
		return
	
	update_score.emit(score, is_double, is_triple)
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

func change_label_colors_win():
	$GameLabels/TotalScoreLabel.modulate = Color.GREEN
	$GameLabels/ScoreCountLabel.modulate = Color.GREEN
	if(total_darts_thrown == perfect_win_count):
		perfect_win_color_state = 0
		$PerfectWinTimer.start()

func _on_perfect_win_timer_timeout():
	$GameLabels/TotalDartsLabel.modulate = PERFECT_WIN_COLORS[perfect_win_color_state]
	$GameLabels/DartsCountLabel.modulate = PERFECT_WIN_COLORS[perfect_win_color_state]
	
	if(perfect_win_color_state == 6):
		perfect_win_color_state = 0
	else:
		perfect_win_color_state += 1

func update_score_game_total_to_0(score: int, is_double: bool, is_triple: bool) -> void:
	#Scoring logic
	var bust: bool = true
	if(score_remaining - score > 1):
		score_remaining -= score
		bust = false
	elif(score_remaining - score == 0 and (is_double || score == 50)):
		score_remaining -= score
		Global.find_and_replace_dart_score(total_darts_thrown, dart_game_mode)
		update_high_score.emit(dart_game_mode)
		change_label_colors_win()
		bust = false
	
	#Update UI
	$GameLabels/ScoreCountLabel.text = str(score_remaining)
	$GameLabels/DartsCountLabel.text = str(total_darts_thrown)
	add_round_score_label(score, bust)

	#Prevent additional throws on a turn
	if(bust):
		round_darts_used = 3

func update_score_game_around_the_world(score: int, is_double: bool, is_triple: bool):
	#Give slice value
	if(is_double): score /= 2
	elif(is_triple): score /=3
	
	
	#Scoring logic
	var bust: bool = true
	if(score==score_remaining && score == 20):
		score_remaining = 0
		Global.find_and_replace_dart_score(total_darts_thrown, dart_game_mode)
		update_high_score.emit(dart_game_mode)
		change_label_colors_win()
		bust = false
	elif(score==score_remaining):
		score_remaining +=1
		bust = false
	
	#Update UI
	$GameLabels/ScoreCountLabel.text = str(score_remaining)
	$GameLabels/DartsCountLabel.text = str(total_darts_thrown)
	add_round_score_label(score, bust)

func add_round_score_label(score: int, is_bust = true):
	var new_label = Label3D.new()
	new_label.font = load("res://Art/Fonts/SpaceMono/SpaceMono-Regular.ttf")
	new_label.font_size = 2000
	new_label.outline_size = 127
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	new_label.text = "-" + str(score)
	new_label.global_position = $GameLabels/RoundScores.global_position
	new_label.global_position.y -= (round_darts_used * 10)
	if(is_bust):
		new_label.modulate = Color.RED
	$GameLabels/RoundScores.add_child(new_label)

func start_game(score: int):
	#Invalid input
	if (score < 1 || score >4):
		return
	
	#Reset text to default:
	$GameLabels/TotalScoreLabel.text = "SCORE:"

	#701 to 0
	if(score == 1):
		update_score.connect(update_score_game_total_to_0)
		score_remaining = 701
		perfect_win_count = 12
		dart_game_mode = Global.DART_MODE.SEVEN_HUNDRED_ONE
	#501 to 0
	elif(score == 2):
		update_score.connect(update_score_game_total_to_0)
		score_remaining = 501
		perfect_win_count = 9
		dart_game_mode = Global.DART_MODE.FIVE_HUNDRED_ONE
	#301 to 0
	elif(score == 3):
		update_score.connect(update_score_game_total_to_0)
		score_remaining = 301
		perfect_win_count = 6
		dart_game_mode = Global.DART_MODE.THREE_HUNDRED_ONE
	#Around the World
	elif(score == 4):
		update_score.connect(update_score_game_around_the_world)
		score_remaining = 1
		perfect_win_count = 20
		dart_game_mode = Global.DART_MODE.AROUND_THE_WORLD
		$GameLabels/TotalScoreLabel.text = "NEXT:"
	
	#Timeout to show dart
	await get_tree().create_timer(0.2).timeout
	
	#Cleanup and reset
	clean_up_darts()
	reset_game_labels()
	toggle_selection_label_visibility()
	toggle_game_label_visibility()
	is_setup = false
