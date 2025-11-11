extends Control

@onready var totals_object = %Totals
@onready var graphs_layout = %GraphsLayout
var graph_template:PackedScene = preload("res://graph_panel.tscn")
var graphs:Dictionary[String,GraphPanel] = {}

func _ready():
	var small_size = Vector2( 248,125 )
	var big_size = Vector2(500,125 )
	
	create_graph( "d4", 4, 1, small_size )
	create_graph( "d6", 6, 1, small_size )
	create_graph( "d8", 8, 1, small_size )
	create_graph( "d10", 10, 1, small_size )
	create_graph( "d12", 12, 1, small_size )
	create_graph( "d20", 20, 2, small_size )
	create_graph( "d%", 100, 5, big_size )
	
	load_counts()
	
func create_graph( title:String, faces:int, step:int, _size:Vector2 )->void:
	var g:GraphPanel = graph_template.instantiate()
	g.setup( title,faces,step,_size )
	graphs.set( title, g )
	graphs_layout.add_child( g )	
	
	
func update()->void:
	if totals_object == null : return
	for entry in totals_object._graph_tally :
		var die_type:String = entry[0]
		var face:int = entry[1]
		if face <= 0 : continue #cocked
		var graph:GraphPanel = graphs.get(die_type)
		graph.update(face)
		graph.queue_redraw()
	
func save_counts()->void:
	print( "saving counts" )
	for graph_name:String in graphs:
		var graph:GraphPanel = graphs.get(graph_name)
		Settings.write( "Counts", graph_name + "_counts", Ut.dict_to_string(graph.counts) )
	
	
func load_counts()->void:
	print( "loading counts" )
	for graph_name:String in graphs:
		var key:String = graph_name + "_counts"
		var counts_string = Settings.read( "Counts", key )
		if counts_string == null : continue
		var graph:GraphPanel = graphs.get(graph_name)
		graph.counts = Ut.string_to_dict( counts_string )
		
func reset_counts()->void:
	print( "reset counts" )
	var d:Dictionary[int,int] = {}
	for graph_name:String in graphs:
		var graph:GraphPanel = graphs.get(graph_name)
		for face:int in range(1,graph.faces_count+1):
			graph.counts.set(face,0)
		graph.queue_redraw()	
	save_counts()
	Settings.save()				
		

	
	
