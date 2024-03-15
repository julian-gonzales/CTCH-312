extends CSGBox3D



func _on_interactable_focused(interactor):
	print("in focus")


func _on_interactable_interacted(interactor):
	print("interacted")


func _on_interactable_unfocused(interactor):
	print("out of focus")
