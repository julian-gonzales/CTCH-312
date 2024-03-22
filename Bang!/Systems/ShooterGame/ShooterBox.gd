extends CSGBox3D

@export var player: Player
var is_playing: bool = false
var is_throwing: bool = false

func _on_interactable_focused(interactor):
	print("in focus")

func _on_interactable_interacted(interactor):
	print("interacted")
	is_playing = !is_playing
	if(is_playing):
		var player_position = get_player_position()
		player.place_and_lock_player(player_position, self)
		player.show_revolver()
	else:
		player.unlock_player(self)
		player.hide_revolver()


func _on_interactable_unfocused(interactor):
	print("out of focus")

func get_player_position() -> Vector3:
	var box_pos = $".".position
	var rotation: Vector3 = self.rotation
	
	var x_offset = round((sin(rotation.y) * 3) * 1000) / 1000
	var z_offset = round((cos(rotation.y) * 3) * 1000) / 1000

	return Vector3(box_pos.x + x_offset, player.position.y, box_pos.z + z_offset)
