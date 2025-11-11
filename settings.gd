extends Node

var config:ConfigFile
const PATH:String =  "user://settings.ini"
const default_brightness:float = 3.2

func _ready():
	if !FileAccess.file_exists( PATH ):
		create_initial_config_file()
	else:
		load_config_file()
	
##should be called only when the Node3D's are all ready.			
func apply_config_settings()->void:
	%UI.set_color_buttons_from_settings()
	
	
func write( section:String, key:String, value:Variant )->void:
	config.set_value( section, key, value )
	
	
func write_and_save( section:String, key:String, value:Variant )->void:
	config.set_value( section, key, value )
	config.save( PATH )	
	
func save()->void:
	config.save(PATH)

func read( section:String, key:String )->Variant:
	return config.get_value( section, key )

func load_config_file()->void:
		print("loading config file ", PATH )
		config = ConfigFile.new()
		config.load(PATH)
		
		
		
	
func create_initial_config_file()->void:
	print( "creating initial config file in " , PATH)
	config = ConfigFile.new()
	write("General", "percentile_mode", "00-0")
	write("General", "current_color", 2)
	write("General", "different_color_percentiles", false)
	write("General", "show_stats", true)
	write("General", "current_planet", 0)
	write("General", "show_graphs", false)
	write("General", "brightness", default_brightness)
	write("General", "volume", 0.7)
	
	write("Camera", "azimuth", 210)
	write("Camera", "altitude", 45)
	write("Camera", "zoom", 5)
	
	write("Window", "first", true)
	
	_write_color_section( "DefaultColors")
	_write_color_section( "Colors")
	config.save(PATH)
	
func restore_default_colors()->void:
	_write_color_section("Colors")
	write("General", "brightness", default_brightness )
	
	config.save(PATH)	

func _write_color_section( s:String )->void:
	write(s,"color1_fg",Color(0.051971, 0.051971, 0.051971, 1))
	write(s,"color1_bg",Color(0.419813, 0.419813, 0.419813, 1))
	
	write(s,"color2_fg",Color(0.537011, 0.537011, 0.537011, 1))
	write(s,"color2_bg",Color(0.564091, 0.186905, 0, 1))
	
	write(s,"color3_fg",Color(0.404511, 0.404511, 0.404511, 1))
	write(s,"color3_bg",Color(0, 0.13243, 0.046237, 1))
	
	write(s,"color4_fg",Color(0.41, 0.265953, 0.1312, 1))
	write(s,"color4_bg",Color(0.0295066, 0.0295066, 0.0295066, 1))
	
	write(s,"color5_fg",Color(0.41598, 0.41598, 0.41598, 1))
	write(s,"color5_bg",Color(0.0, 0.344, 0.328, 1)	)
