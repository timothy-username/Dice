extends SubViewportContainer

var rotating:bool
var rotation_rate:float = 1.0 #1 rotation / s
@onready var die:MeshInstance3D = $SubViewport/twelve_sided_shape

func _ready():
	rotating = false
	#print( "hi i'm ", name )

func _on_mouse_entered() -> void:
	#print("here we are in _on_mouse_entered")
	rotating = true


func _on_mouse_exited() -> void:
	#print("mouse has exited " , get_instance_id(), self )
	rotating = false
	
func _physics_process( delta:float ):
	if rotating:
		die.rotation_degrees.y += rotation_rate * 360.0 * delta
		
func _on_gui_input(event: InputEvent) -> void:			
	if event is InputEventMouseButton:
		#print( "click")
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var col:int = int(Ut.get_last_chars(name,1))
				%UI.set_current_color_button(col)  #node name
				Settings.write_and_save("General","current_color",col)

func get_button_bg_color()->Color:
	return die.material_override.albedo_color
	
func get_button_fg_color()->Color:
	return die.material_overlay.albedo_color			
	
func set_button_bg_color( c:Color )->void:
	die.material_override.albedo_color = c;
		
func set_button_fg_color( c:Color )->void:
	die.material_overlay.albedo_color = c;
					
func change_dice_color()->void:
	var bg:Color = get_button_bg_color()
	var fg:Color = get_button_fg_color()
	print( "bgcolor = ", bg, " fgcolor = ", fg )
	%Operations.change_dice_color(fg,bg)
	
				
