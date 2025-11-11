extends HSlider

var master_index:int
var volume:float

func _ready():
	master_index = AudioServer.get_bus_index("Master")
	var val:float = Settings.read("General", "volume")
	print( "read val ", val, " from settings")
	set_volume( val )
	#print("master audio bus index = ", master_index)


func _on_mouse_exited() -> void:
	release_focus()


func _on_value_changed(val: float) -> void:
	set_volume( val )
	
	
	
func set_volume( val:float )->void:
	volume = clamp(val, 0,1)
	print( "volume ", val )
	set_value_no_signal(volume)
	AudioServer.set_bus_volume_db(master_index, linear_to_db(val))
