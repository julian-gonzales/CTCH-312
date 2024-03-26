extends Area3D

@export var curr_speed: float = 0.1
@export var up: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	
	if position.x >= 2.596:
		up = false
	if position.x <= -2.825:
		up = true
	
	if up == true:
		position.x += curr_speed
	if up == false:
		position.x -= curr_speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
