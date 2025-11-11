extends Node


@onready var total_label:Label = %TotalLabel
@onready var totals_container = %TotalsContainer
@onready var max_label:Label = %MaxLabel
@onready var min_label:Label = %MinLabel
@onready var nodc_label:Container = %NumberOfDiceContainer
@onready var toggle_stats = %ToggleStats
@onready var dice = %Dice
@onready var face_normals = %FaceNormals
@onready var ui = %UI

var _total:int = 0
var _max:int = 0
var _min:int = 1
var _cocked:bool = false

## every roll currently on the board is recorded here for the grapher.
## for example:  [ ["d4":2], ["d6":1], ["d6":5] ]
var _graph_tally:Array = []

var num_dice_labels:Dictionary[String,Label] = {}
var num_dice_array:Array[String]  #for ordering.




func _ready()->void:
	reset()
	update_totals_labels()
	
	num_dice_array = ["d4", "d6", "d8", "d10", "d12", "d20", "d%"]
	#these are labels that will be added to NumberOfDiceContainer as needed.
	var d4 = preload( "res://number_of_dice_label.tscn").instantiate()
	var d6 = preload( "res://number_of_dice_label.tscn").instantiate()
	var d8 = preload( "res://number_of_dice_label.tscn").instantiate()
	var d10 = preload( "res://number_of_dice_label.tscn").instantiate()
	var d12 = preload( "res://number_of_dice_label.tscn").instantiate()
	var d20 = preload( "res://number_of_dice_label.tscn").instantiate()
	var dpcnt = preload( "res://number_of_dice_label.tscn").instantiate()
	
	d4.type = "d4"
	d6.type = "d6"
	d8.type = "d8"
	d10.type = "d10"
	d12.type = "d12"
	d20.type = "d20"
	dpcnt.type = "d%"
	
	num_dice_labels.set("d4", d4)
	num_dice_labels.set("d6", d6)
	num_dice_labels.set("d8", d8)
	num_dice_labels.set("d10", d10)
	num_dice_labels.set("d12", d12)
	num_dice_labels.set("d20", d20)
	num_dice_labels.set("d%", dpcnt)
	
	


func reset()->void:
	_total = 0
	_max = 0
	_min = 1
	_cocked = false
	_graph_tally.clear()
	update_totals_labels()
	
func update_totals_labels()->void:
	if not toggle_stats.show_stats : return
	if dice.get_child_count() == 0:
		totals_container.visible = false
	else:
		totals_container.visible = true
		
	if _cocked:
		total_label.text = "?"
		max_label.text = "?"
		min_label.text = "?"
	else:	
		total_label.text = str(_total) 
		max_label.text = str(_max)
		min_label.text = str( _min)
	
func update()->void:
	var _dict:Dictionary[String,int] = {} 
	reset()
	
	var first:bool = true
	for child:RigidBody3D in dice.get_children():
	
		#update the stats
		var upface:int = face_normals.get_upface( child.DIE_TYPE, child.rotation )
		if upface == -1:
			_cocked = true
			
		
		#we handle counting a linked d10 when we get to its associated d%
		if child.DIE_TYPE == "d10" && child.brother != null : continue 
		
		#a d10 on its own always counts the 0 as a 10.
		if child.DIE_TYPE == "d10" && upface == 0  : upface = 10
		
		if child.DIE_TYPE == "d%":
			var sis = child.sister
			var sis_upface = face_normals.get_upface( sis.DIE_TYPE, sis.rotation )
		
	
			#now we must consider the percentile mode because 
			#there are 2 different adding up methods.	
			var mode:String = ui.percentile_mode
			if mode == "00-0":
				if upface == 0 && sis_upface == 0:  upface = 100
				else: upface = upface + sis_upface
			else: # "90-0"
				if sis_upface == 0: sis_upface = 10
				upface = upface + sis_upface
		
		##record this result in the _graph_tally
		_graph_tally.append( [child.DIE_TYPE, upface] )
		
		#create a list of the number and types of all dice currently visible
		inc(_dict,child.DIE_TYPE)
		#this dictionary has everything we need to display the number of dice rolled.
		#print( _dict )
		
		if first:
			_min = upface
			first = false
		#print( "upface = ", upface)
		
		if _cocked :
			pass
		else :	
			_total += upface  
			_max = max( _max, upface )
			_min = min( _min, upface )
		
	update_totals_labels()	
	update_number_of_dice(_dict)
	#print( _graph_tally )
	
func update_number_of_dice( d:Dictionary[String,int]):
	for child in nodc_label.get_children():
		nodc_label.remove_child( child )
	for nme:String in num_dice_array:
		if not d.has(nme): continue
		var count = d.get(nme)
		var lbl:Label = num_dice_labels.get(nme)
		lbl.text = str(count) + " " + nme
		nodc_label.add_child( lbl )
		

##helper function for update()
func inc( d:Dictionary[String,int], key:String )->void:
	if d.has(key):
		var c:int = d.get(key)
		d.set(key, c+1)
	else:
		d.set(key,1)

##helper function for update()
func get_count( d:Dictionary[String,int], key:String )->int:
	if not d.has(key) : return 0
	else : return d.get(key)
	
