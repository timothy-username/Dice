extends Button

var show_stats:bool
@onready var num_dice = %NumberOfDiceContainer
@onready var totals = %TotalsContainer

func _ready():
	set_stats( Settings.read("General","show_stats"))
	

func set_stats( b:bool )->void:
	show_stats = b
	num_dice.visible = show_stats
	totals.visible = show_stats
	if show_stats:
		text = "Hide Stats"
	else:
		text = "Show Stats"

func _on_button_down() -> void:
	set_stats(not show_stats)

	


func _on_mouse_exited() -> void:
	release_focus()
