extends MeshInstance3D

@export var player: Player

var is_playing: bool = false

func _on_interactable_focused(interactor):
	pass

func _input(event):
	if Input.is_action_just_pressed("jump") && is_playing:
		spacebar_pressed()

func _on_interactable_interacted(interactor):
	is_playing = !is_playing
	if(is_playing):
		var player_position = get_player_position()
		player.place_and_lock_player(player_position, self)
		set_dart_board_interaction_depth(50, 2000)
	else:
		player.unlock_player(self)
		set_dart_board_interaction_depth(8, 300)

func _on_interactable_unfocused(interactor):
	pass

func set_dart_board_interaction_depth(z_origin: float,y_value: float):
	$Interactable.position.z = z_origin
	var current_scale = $Interactable.scale
	$Interactable.scale = Vector3(current_scale.x, y_value, current_scale.z)

func get_player_position() -> Vector3:
	var dartboard_position = self.position
	var x_offset = self.global_transform.basis.z.x*(4/0.03)
	var z_offset = self.global_transform.basis.z.z*(4/0.03)
	return Vector3(dartboard_position.x + x_offset, player.position.y, dartboard_position.z + z_offset)

func spacebar_pressed():
	print("Pressed spacebar in game")
