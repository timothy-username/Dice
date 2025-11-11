extends Node

@onready var ui = %UI
@onready var quick_tests = %QuickTests

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
		
		

func _on_window_size_changed()->void:
	pass
	#print( "size changed ")
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		%UI._end()
		
	
