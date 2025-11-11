extends Button

@onready var confirmation_dialog = %DefaultColorsConfirmation

func show_confirmation_dialog()->void:
	#print( "hi there!")
	confirmation_dialog.title = "Restore Default Colors?"
	confirmation_dialog.visible = true
	


func _on_mouse_exited() -> void:
	release_focus()
