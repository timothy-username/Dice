extends Button

var planet_g:Dictionary[String,float] = {}
var planet_list:Array[String] = []
var current_planet:int

func _ready():
	planet_list = ["EARTH", "MARS", "MOON", "CERES"]
	planet_g.set("EARTH", 1.0)
	planet_g.set("MARS", 0.38)
	planet_g.set("MOON", 0.166)
	planet_g.set("CERES",0.029)
	
	current_planet = Settings.read("General","current_planet")
	apply_current_planet()
	
	
func next_planet()->void:
	current_planet += 1
	if current_planet >= planet_list.size(): current_planet = 0
	print("current_planet = ", current_planet)
	Settings.write_and_save("General","current_planet",current_planet)
	apply_current_planet()
	
func apply_current_planet()->void:
	var g:float = planet_g.get(planet_list[current_planet])
	set_gravity( g*9.8 )
	update_text()
	release_focus()
	
func update_text()->void:
	var nme:String = planet_list[current_planet]
	text = "Gravity: " + nme
	if nme == "CERES" :
		tooltip_text = "D&D takes forever on Ceres!"
	else:
		tooltip_text = ""
	
	
func set_gravity( g:float )->void:
	PhysicsServer3D.area_set_param(
		get_viewport().find_world_3d().space, 
		PhysicsServer3D.AREA_PARAM_GRAVITY, g)	
		
	
	
	


func _on_button_down() -> void:
	pass # Replace with function body.
