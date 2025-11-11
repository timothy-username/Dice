extends HSlider


var brightness:float


func _ready():
	min_value = 0.5
	max_value = 8
	var val:float = Settings.read("General","brightness")
	print("ready() brightness ", val)
	set_brightness(val)
	
	
	


func _on_mouse_exited() -> void:
	release_focus()

#value should be between 0 and 1
func set_brightness( val:float )->void:
	val = clamp(val, min_value,max_value)
	brightness = val
	print( "set_brightness() brightness = ", brightness )
	set_value_no_signal( brightness )
	#print %WorldEnvironment.tonemap_exposure
	%WorldEnvironment.environment.tonemap_exposure = brightness
	
func _on_value_changed(val: float) -> void:
	print("value_changed() brightness = ", val)
	set_brightness( val )
