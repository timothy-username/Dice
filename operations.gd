class_name Operations extends Node

#dice scenes
var four_sided:PackedScene
var six_sided:PackedScene
var eight_sided:PackedScene
var percentile_10:PackedScene
var percentile_100:PackedScene
var twelve_sided:PackedScene
var twenty_sided:PackedScene

@onready var debouncer = %Debouncer
@onready var totals = %Totals
@onready var graphs = %Graphs
@onready var ui = %UI

var counter:int = 0
var node_name_counter:int = 0
var play_throw_sound = true
var different_color_percentiles:bool = false
@onready var percentile_color:int 
var percentile_counter = 0;

func _ready():

	randomize()
	print("preloading..")
	four_sided = preload("res://dice/4_sided_rigid.tscn")
	six_sided = preload("res://dice/6_sided_rigid.tscn")
	eight_sided = preload("res://dice/8_sided_rigid.tscn")
	percentile_10 = preload("res://dice/10_sided_ones_rigid.tscn")
	percentile_100 = preload("res://dice/10_sided_tens_rigid.tscn")
	twelve_sided = preload("res://dice/12_sided_rigid.tscn")
	twenty_sided = preload("res://dice/20_sided_rigid.tscn")
	
	%FaceNormals.unpack("d4", four_sided.instantiate())
	%FaceNormals.unpack("d6", six_sided.instantiate())
	%FaceNormals.unpack("d8", eight_sided.instantiate())
	%FaceNormals.unpack("d10", percentile_10.instantiate())
	%FaceNormals.unpack("d%", percentile_100.instantiate())
	%FaceNormals.unpack("d12", twelve_sided.instantiate())
	%FaceNormals.unpack("d20", twenty_sided.instantiate())
	
	#print(%FaceNormals.map)
	var m:bool = Settings.read(
		"General", 
		"different_color_percentiles")
		
	set_color_percentile_mode( m )	
	clear( false )
	
	
func _physics_process( _tick:float )->void:
		counter += 1
		if counter == 20:
			counter = 0
			totals.update()

func set_color_percentile_mode( m:bool )->void:
	different_color_percentiles = m
	if m:
		%PercentileDifferentColors.text = "d% use different color"
	else:	
		%PercentileDifferentColors.text = "d% use same color"
		
	Settings.write_and_save( 
		"General", 
		"different_color_percentiles", 
		different_color_percentiles )	
			
func toggle_color_percentile_mode()->void:
		set_color_percentile_mode( !different_color_percentiles )
		%PercentileDifferentColors.release_focus()				

func clear_and_pop()->void:
	clear(true)	
	ui._save_everything()		

## remove all dice from the board
func clear( with_sound:bool )->void:
	graphs.update()
	print( "clear")
	debouncer.clear()
	var children:Array[Node] = %Dice.get_children()
	for child:Node3D in children:
		child.queue_free()
		
	var test_children:Array[Node] = %TestDice.get_children()
	for test_child:Node3D in test_children:
		test_child.queue_free()	
		
	node_name_counter = 0
	percentile_color = Settings.read("General", "current_color")
	print( "clearing percentile_color to " , percentile_color )
	percentile_counter = 0
	#print("percentile color set to ")
	%ButtonClear.release_focus()	
	if with_sound:  
		%ClearSound.pitch_scale = randf_range(0.9,1.2)
		%ClearSound.play()	
	
	


func set_percentile_materials( r:RigidBody3D )->void:
	if !different_color_percentiles:
		set_materials(r)
		return
		
	percentile_counter += 1
	if( percentile_counter % 2 == 1 ):
		percentile_color += 1
	if percentile_color > %UI.max_color(): percentile_color = 1
	
	var old_color_button = ui.current_color_button
	ui.current_color_button = percentile_color
	set_materials( r )
	ui.current_color_button = old_color_button

	
func set_materials( r:RigidBody3D )->void:
	var fg_mat = %UI.get_current_fg_material()
	fg_mat.albedo_texture_msdf = false
	var bg_mat = %UI.get_current_bg_material()
	var m:MeshInstance3D = r.get_child(1)
	m.material_override = bg_mat
	m.material_overlay = fg_mat	

## rescales range a,b to that of c,d, and returns t interpolation in the new range.
func _linear(a:float, b:float, c:float, d:float, t:float)->float:
		var s1 = b-a #size of a->b range
		var p = (t-a)/s1  #percent distance t is between [a,b]
		var s2 = d-c #size of d->c range
		var res = s2*p + c  #now the result is the same distance along c,d as t was along a,b
		return res
	

func mass_db_reduction( mass:float )->float:
	#Dice masses range between 1 and 3.
	#3 should give no noise reduction.  1 should reduce db by 6.
	return _linear(3,1, 0,-6, mass)
	
func speed_db_reduction( speed:float )->float:
	#Dice speeds range between ~ 0 and 3.
	#3 should give no noise reduction.  0 should reduce db by 10.
	return _linear(3,0, 0,-10, speed)	
	
func mass_pitch_reduction( mass:float )->float:
	return _linear(1,3, 0.0, -0.5, mass)
	

func collision_happened( n:Node,m:RigidBody3D )->void:
	var accepted = debouncer.check_event(n,m)
	if !accepted:
		#print("rejected collision")
		return
	
	#print( m.name, " collided with ", n.name, " at ", m.position )
	#print( "mass = ", m.mass )
	var speed:float = m.linear_velocity.length()
	var mass:float = m.mass
	#print( "speed = ", speed )
	
	if speed > 0.2:
		if n.name == "FloorStatic":
			#print( "Floor")
			var player = %DiceOnFloorSound
			player.position = m.position
			player.volume_db = -20 + mass_db_reduction( mass ) + speed_db_reduction( speed )
			#print( "db = ", player.volume_db )
			player.play()
			
		elif n.name == "WallsStatic":
			var player
			if m.position.y < 0.27:
				#print("wood")
				player = %DiceOnWoodSound
				player.volume_db = -10 + mass_db_reduction( mass ) + speed_db_reduction( speed )
			else: 
				#print("glass")
				player = %DiceOnWallSound
				player.volume_db = 2 + mass_db_reduction( mass ) + speed_db_reduction( speed )
			player.position = m.position
			
			#print( "db = ", player.volume_db )
			player.play()
			
		else: #dice on dice
			
			var player = %DiceOnDiceSound
			#print("dice")
			#print("collided with ", n.name )
			player.position = m.position
			player.volume_db = -7 + mass_db_reduction( mass ) + speed_db_reduction( speed )
			player.pitch_scale = 1.97 + mass_pitch_reduction( mass )
			#print( "db = ", player.volume_db )
			player.play()			
			
	
	
func setup_signals( rb:RigidBody3D )->void:
	rb.contact_monitor = true;
	rb.max_contacts_reported = 1;
	rb.body_entered.connect(collision_happened.bind(rb))
	
## drop all 7 dice
func all()->void:
	play_throw_sound = false;
	create_4_sided()
	create_6_sided()
	create_8_sided()
	#create_10_sided()
	create_percentile()
	create_12_sided()
	create_20_sided()
	%ButtonAll.release_focus()	
	play_throw_sound = true;
	do_throw_sound()
	#%Totals.print_all_names()
	

func setup_die( node:RigidBody3D, nme:String, mass:float )->void:
	node.name = nme + get_node_name_counter()
	node.get_node("FaceNormals").queue_free()
	node.mass = mass
	setup_signals( node )
	set_materials( node )
	toss( node )
	%Dice.add_child( node )
	totals.update()

func do_throw_sound()->void:
	%ThrowingDice.pitch_scale = randf_range(0.95,1.15)
	%ThrowingDice.play()	

	
func create_4_sided()->void:
	var node:RigidBody3D = four_sided.instantiate()
	setup_die(node,"4_sided_rigid",1)
	%Button_4.release_focus()
	if play_throw_sound: do_throw_sound()
	
func create_6_sided()->void:
	var node:RigidBody3D = six_sided.instantiate()
	setup_die(node,"6_sided_rigid",1.2)
	%Button_6.release_focus()
	if play_throw_sound: do_throw_sound()
	
func create_8_sided()->void:
	var node:RigidBody3D = eight_sided.instantiate()
	setup_die(node,"8_sided_rigid",1.25)
	%Button_8.release_focus()
	if play_throw_sound: do_throw_sound()	
	
func create_12_sided()->void:
	var node:RigidBody3D = twelve_sided.instantiate()
	setup_die(node,"12_sided_rigid",2)
	%Button_12.release_focus()
	if play_throw_sound: do_throw_sound()
	
func create_20_sided()->void:
	var node:RigidBody3D = twenty_sided.instantiate()
	setup_die(node,"20_sided_rigid",3.3)
	%Button_20.release_focus()
	if play_throw_sound: do_throw_sound()
	
func create_10_sided()->void:
	var node:RigidBody3D = percentile_10.instantiate()
	setup_die(node,"10_sided_ones_rigid",1.7)
	%Button_10.release_focus()
	if play_throw_sound: do_throw_sound()
	
func create_percentile()->void:
	var node_10:RigidBody3D = percentile_10.instantiate()
	#setup_die(node_10,"10_sided_ones_rigid",1.7)
	node_10.name = "10_sided_ones_rigid-" + get_node_name_counter()
	node_10.get_node("FaceNormals").queue_free()
	node_10.mass = 1.7
	setup_signals( node_10 )
	set_percentile_materials( node_10 )
	toss( node_10 )
	%Dice.add_child( node_10 )
	
	#create the tens die
	var node_100:RigidBody3D = percentile_100.instantiate()
	node_100.name = "10_sided_tens_rigid-" + get_node_name_counter()
	node_100.get_node("FaceNormals").queue_free()
	node_100.mass = 1.7
	setup_signals( node_100 )
	set_percentile_materials( node_100 )
	toss( node_100 )
	
	#associate the tens die with the ones die
	node_100.sister = node_10
	node_10.brother = node_100
	
	%Dice.add_child( node_100 )
	
	totals.update()	
	%ButtonPercentile.release_focus()	
	if play_throw_sound: do_throw_sound()
	
	
func toss( body:RigidBody3D )->void:
	var a:float = 10
	var lin:float = 4
	body.position.x = 0 + randf_range( 0, 0.5 )
	body.position.z = 0 + randf_range( 0, 0.5 )
	body.position.y = 1.0 + randf_range( 0, 0.5 )
	
	body.rotation_degrees.x = randf_range( -180, 180 )
	body.rotation_degrees.y = randf_range( -180, 180 )
	body.rotation_degrees.z = randf_range( -180, 180 )
	
	
	body.angular_velocity.x = randf_range( -a,a )
	body.angular_velocity.y = randf_range( -a,a )
	body.angular_velocity.z = randf_range( -a,a )
	
	body.linear_velocity.x = randf_range( -lin, lin )
	body.linear_velocity.y = randf_range( -lin, lin )
	body.linear_velocity.z = randf_range( -lin, lin )
	
func get_node_name_counter()->String:
	node_name_counter += 1
	return str(node_name_counter)
	
