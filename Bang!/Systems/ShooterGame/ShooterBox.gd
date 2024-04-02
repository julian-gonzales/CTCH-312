extends CSGBox3D

@export var player: Player
@export var camera: Camera3D
var is_playing: bool = false
var is_throwing: bool = false
var Ray_Range = 100

var targets = []
var score: int = 0
var bullets: int = 6

signal update_high_score()

func _on_interactable_focused(interactor):
	#print("in focus")
	pass

func _ready():
	targets.append(get_node("ShootingTarget"))
	targets.append(get_node("ShootingTarget2"))
	targets.append(get_node("ShootingTarget3"))
	targets.append(get_node("ShootingTarget4"))
	targets.append(get_node("ShootingTarget5"))
	targets.append(get_node("ShootingTarget6"))
	$Score.text = str(score)
	$Bullets.text = "Bullets: " + str(bullets)
	
func _input(event):
	if event.is_action_pressed("shoot") and is_playing:
		get_camera_collision()
		if (score % 6) == 0:
			for target in targets:
				target.show()

func _on_interactable_interacted(interactor):
	is_playing = !is_playing
	if is_playing :
		random_starting_pos()
		var player_position = get_player_position()
		player.place_and_lock_player(player_position, self)
		player.show_revolver()
		$Score.show()
		$Bullets.show()
		for target in targets:
			target.show()
	else:
		player.unlock_player(self)
		player.hide_revolver()
		for target in targets:
			target.hide()
		Global.find_and_replace_shooter_score(score)
		update_high_score.emit()
		score = 0
		bullets = 6
		$Score.hide()
		$Bullets.hide()
		$Score.text = str(score)
		$Bullets.text = "Bullets: " + str(bullets)


func _on_interactable_unfocused(interactor):
	#print("out of focus")
	pass

func get_player_position() -> Vector3:
	var box_pos = $".".position
	var rotation: Vector3 = self.rotation
	
	var x_offset = round((sin(rotation.y) * 2.5) * 1000) / 1000
	var z_offset = round((cos(rotation.y) * 2.5) * 1000) / 1000

	return Vector3(box_pos.x + x_offset, player.position.y, box_pos.z + z_offset)

func get_camera_collision():
	$AudioStreamPlayer.play()
	var centre = camera.get_viewport().get_size()/2
	
	var ray_origin = camera.project_ray_origin(centre)
	var ray_end = ray_origin + camera.project_ray_normal(centre) * Ray_Range
	
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var intersection = camera.get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	if not intersection.is_empty():
		print(intersection.collider.name)
		if intersection.collider.name == "Target":
			intersection.collider.get_parent().hide()
			score += 1
	else:
		print("Nothing")
	bullets -= 1
	$Score.text = str(score)
	$Bullets.text = "Bullets: " + str(bullets)
	
	if bullets == 0 and (score % 6 == 0) and score != 0:
		bullets += 6
	
	if bullets == 0:
		is_playing = false
		player.unlock_player(self)
		player.hide_revolver()
		for target in targets:
			target.hide()
		Global.find_and_replace_shooter_score(score)
		update_high_score.emit()
		score = 0
		bullets += 6
		$Score.hide()
		$Bullets.hide()
	$Score.text = str(score)
	$Bullets.text = "Bullets: " + str(bullets)

func get_random_pos() -> float:
	var rng = RandomNumberGenerator.new()
	print(rng.randf_range(-2.825, 2.596))
	return rng.randf_range(-2.825, 2.596)

func random_starting_pos():
	$ShootingTarget.position.x = get_random_pos()
	$ShootingTarget2.position.x = get_random_pos()
	$ShootingTarget3.position.x = get_random_pos()
	$ShootingTarget4.position.x = get_random_pos()
	$ShootingTarget5.position.x = get_random_pos()
	$ShootingTarget6.position.x = get_random_pos()
