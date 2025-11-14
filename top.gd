extends Node

@onready var ui = %UI
@onready var quick_tests = %QuickTests
@onready var world_environment = %WorldEnvironment
@onready var lights_forward_plus = %LightsForwardPlus
@onready var lights_compatibility = %LightsCompatibility


func _ready():
	#quick_tests.simulate_rolls( 6 )
	DisplayServer.window_set_min_size( Vector2i(500,500))
	var wn:Viewport = get_window()
	wn.size_changed.connect(_on_window_size_changed )
	
	var first:bool = Settings.read("Window", "first")
	if first:  #center the window on the screen
		Settings.write_and_save( "Window", "first", false)
		#make it 2/3 of horiz, 3/4 of vert
		var screen_size:Vector2i = DisplayServer.screen_get_size()
		var window_size:Vector2i = Vector2i( \
			screen_size.x * 2 / 3,
			screen_size.y * 3 / 4 )
			
		var window_pos:Vector2i = Vector2i( \
			(screen_size.x - window_size.x) / 2,
			(screen_size.y - window_size.y) /2 )
		
		DisplayServer.window_set_size( window_size )
		DisplayServer.window_set_position( window_pos )
		ui.save_window()
		
	else: #not first time.  User has already set the window size
		var size:Vector2i = Settings.read("Window", "size")
		var pos:Vector2i = Settings.read("Window","position")
		
		DisplayServer.window_set_size(size)
		DisplayServer.window_set_position(pos)	
		
	handle_rendering_method()

## we have different lights, shadow tweaks and world environments for 
## forward+ or opengl compatibility
func handle_rendering_method()->void:
	var method = RenderingServer.get_current_rendering_method()
	## "forward_plus"  or "gl_compatibility"
	print( "render method = " , method )
	if method == "forward_plus":
		setup_forward_plus()
	else:
		setup_gl_compatibility()
		
func setup_forward_plus()->void:
	world_environment.environment = load("res://WorldEnvironment_ForwardPlus.tres")
	lights_forward_plus.visible = true
	lights_compatibility.visible = false
	
func setup_gl_compatibility()->void:
	
	world_environment.environment = load("res://WorldEnvironment_Compatibility.tres")
	lights_forward_plus.visible = false
	lights_compatibility.visible = true	
			
		
	
		
		

func _on_window_size_changed()->void:
	pass
	#print( "size changed ")
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		%UI._end()
		
	
