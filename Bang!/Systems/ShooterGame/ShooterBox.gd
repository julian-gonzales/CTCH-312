extends CSGBox3D

@export var player: Player
@export var camera: Camera3D
var is_playing: bool = false
var is_throwing: bool = false
var Ray_Range = 2000

func _on_interactable_focused(interactor):
	print("in focus")
	
func _input(event):
	if event.is_action("shoot") and is_playing:
		get_camera_collision()

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
	
	var x_offset = round((sin(rotation.y) * 2.5) * 1000) / 1000
	var z_offset = round((cos(rotation.y) * 2.5) * 1000) / 1000

	return Vector3(box_pos.x + x_offset, player.position.y, box_pos.z + z_offset)

func get_camera_collision():
	var centre = camera.get_viewport().get_size()/2
	
	var ray_origin = camera.project_ray_origin(centre)
	var ray_end = ray_origin + camera.project_ray_normal(centre) * Ray_Range
	
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var intersection = camera.get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	if not intersection.is_empty():
		print(intersection.collider.name)
		intersection.collider.hide()
		intersection.collider.get_parent().hide()
	else:
		print("Nothing")

