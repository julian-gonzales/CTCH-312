class_name Dart extends RigidBody3D

signal timeout_despawn

func start_timer():
	$Timer.start()

func stop_timer():
	$Timer.stop()

func _on_timer_timeout():
	timeout_despawn.emit()
	self.queue_free()
