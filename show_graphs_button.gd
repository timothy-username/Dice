extends Button
@onready var graphs_container = %GraphsContainer

func _ready():
	show_graphs( Settings.read( "General", "show_graphs"))

func toggle_graphs()->void:
	graphs_container.visible = not graphs_container.visible
	_update_text()

func show_graphs( b:bool )->void:
	graphs_container.visible = b
	_update_text()

func _update_text()->void:
	if graphs_container.visible:
		text = "Hide Graphs"
	else:
		text = "Show Graphs"

func _on_mouse_exited() -> void:
	release_focus()
