extends CanvasLayer


var current_color_button:int
var percentile_mode:String = "00-0"


var color_buttons:Dictionary #{int:ColorButton}
@onready var bg_color_picker:ColorPickerButton  = %BgColorPicker
@onready var fg_color_picker:ColorPickerButton  = %FgColorPicker
@onready var default_colors_button:Button  = %DefaultColorsButton
@onready var graphs_container  = %GraphsContainer
@onready var graphs  = %Graphs
@onready var operations = %Operations

func _ready():
	color_buttons.set( 1, %ColorButton1 )
	color_buttons.set( 2, %ColorButton2 )
	color_buttons.set( 3, %ColorButton3 )
	color_buttons.set( 4, %ColorButton4 )
	color_buttons.set( 5, %ColorButton5 )
	
	set_color_buttons_from_settings()
	percentile_mode = Settings.read("General", "percentile_mode")
	%PercentileModeToggle.text = "Percentile mode: " + percentile_mode
	
	print("curr color = ", current_color_button)


func _process( _tick:float ):
	if Input.is_action_just_pressed( "clear"):operations.clear( true )
	elif Input.is_action_just_pressed( "d4"):operations.create_4_sided()
	elif Input.is_action_just_pressed( "d6"):operations.create_6_sided()
	elif Input.is_action_just_pressed( "d8"):operations.create_8_sided()
	elif Input.is_action_just_pressed( "d10"):operations.create_10_sided()
	elif Input.is_action_just_pressed( "d12"):operations.create_12_sided()
	elif Input.is_action_just_pressed( "d20"):operations.create_20_sided()
	elif Input.is_action_just_pressed( "d%"):operations.create_percentile()
	elif Input.is_action_just_pressed( "all"):operations.all()
	elif Input.is_action_just_pressed( "quit"):_end()
	
func _end()->void:
	_save_everything()
	print( "bye-bye")
	get_tree().quit()	
	
func _save_everything()->void:
	%CameraMount.save_camera()
	save_window()
	save_sliders()
	Settings.write( "General", "show_stats", %ToggleStats.show_stats)
	Settings.write( "General", "show_graphs", %GraphsContainer.visible)
	graphs.save_counts()
	Settings.save()
	print( "saved everything" )	

func save_sliders()->void:
	print("UI: saving brightness ", %BrightnessSlider.value)
	Settings.write( "General", "brightness", %BrightnessSlider.value)
	Settings.write( "General", "volume", %VolumeSlider.value)
	Settings.save()

func save_window()->void:
	print("saving window")
	var pos:Vector2i = DisplayServer.window_get_position()
	var size:Vector2i = DisplayServer.window_get_size()
	Settings.write("Window","position", pos )
	Settings.write("Window","size", size)
	Settings.save()


## returns the number of colors available.  
## color buttons are numbered from 1 to max_color
func max_color()->int:
	return color_buttons.size()
	


func toggle_percentile_mode()->void:
	if percentile_mode == "00-0" : percentile_mode = "90-0"
	else: percentile_mode = "00-0"
	%Operations.clear(true)
	%PercentileModeToggle.release_focus()
	
	%PercentileModeToggle.text = "Percentile mode: " + percentile_mode
	Settings.write_and_save( "General", "percentile_mode", percentile_mode )

func set_current_color_button( num:int )->void:
	current_color_button = num
	%Operations.percentile_color = current_color_button
	#make every button that isn't selected smaller.
	for i in range(1,6):
		var b = color_buttons.get(i)
		var t = b.get_node( "SubViewport/twelve_sided_shape")
		if i == current_color_button: t.position.z = 0.0
		else: t.position.z = -0.3
		
	#update the color pickers
	bg_color_picker.color = get_current_bg_material().albedo_color
	fg_color_picker.color = get_current_fg_material().albedo_color
		

			
			
	
	
	

func get_color_button( nme:String )->SubViewportContainer:
	return get_node( nme )

func get_current_button()->SubViewportContainer:
	return color_buttons.get(current_color_button)
	
func get_current_fg_material()->Material:
	return get_current_button().die.material_overlay
	
func get_current_bg_material()->Material:
	var mat = get_current_button().die.material_override
	#mat.roughness = 0.1
	return get_current_button().die.material_override	

func set_color_buttons_from_settings()->void:
	print("setting button colors from settings ")
	for i in range(1,6):
		
		var bg:String = "color"+str(i)+"_bg"
		var fg:String = "color"+str(i)+"_fg"
		color_buttons.get(i).set_button_bg_color( Settings.read("Colors",bg))
		color_buttons.get(i).set_button_fg_color( Settings.read("Colors",fg))
		color_buttons.get(i).die.material_override.roughness = 0.1
		color_buttons.get(i).die.material_overlay.albedo_texture_msdf = false;

	
	current_color_button = int(Settings.read("General","current_color"))
	set_current_color_button( current_color_button )

func restore_default_colors()->void:
	print("restoring colors")
	Settings.restore_default_colors()
	set_color_buttons_from_settings()
	default_colors_button.release_focus()
	%BrightnessSlider.set_brightness(Settings.default_brightness)
	
func _on_fg_color_picker_color_changed(color: Color) -> void:
	#change the color
	var b = get_current_button()
	b.set_button_fg_color( color )
	
	#write it to settings
	var key:String = "color" + str(current_color_button) + "_fg"
	print("saving :", key, ":", color)
	Settings.write_and_save("Colors",key,color)

func _on_bg_color_picker_color_changed(color: Color) -> void:
	#change the color
	var b = get_current_button()
	b.set_button_bg_color( color )
	
	#write it to settings
	var key:String = "color" + str(current_color_button) + "_bg"
	print("saving :", key, ":", color)
	Settings.write_and_save("Colors",key,color)
	
func get_last_char(s:String)->String:
	return s.substr(s.length()-1,s.length())	
