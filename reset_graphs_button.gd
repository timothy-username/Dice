extends Button
@onready var ui = %UI
@onready var confirmation_dialog = %ClearGraphsConfirmation

func show_confirmation_dialog()->void:
	confirmation_dialog.visible = true
	
func _on_mouse_exited() -> void:
	release_focus()
	

	
