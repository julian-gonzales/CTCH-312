extends Area3D

@export var curr_speed: int = 1
@export var speed_change: int = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	
	#position.x += curr_speed
	
	if position.x >= 5:
		curr_speed -= speed_change
	
	if position.x <= -5:
		curr_speed += speed_change


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
