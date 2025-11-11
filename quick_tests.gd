extends Node

var faces:int
var rolls = 1000000
var roll_map:Dictionary[int,int] ={}  #face, accumulated times this face has been rolled
var percentage_map:Dictionary[int,float]={}

func _ready():
	pass
	#simulate_rolls()
	#test_ut_dict_to_string()

func test_ut_dict_to_string():
	print( "\n\nQUICK TEST: DICT_TO_STRING ******************************" )
	
	if true:
		
		assert_working( {1:1,2:-34,3:0,4:40} )
		assert_working( {1:10} )
		assert_working( {} )
		
		
		
	print( "DONE ******************************\n\n" )		

func assert_working( d:Dictionary[int,int] ):
		var s = Ut.dict_to_string( d )
		var d2 = Ut.string_to_dict( s )
		print(d)
		print(s)
		print(d2)	
		if d == d2 :
			print( "success" )
		else:
			print( "fail" )
			get_tree().quit()

func simulate_rolls( faces:int ):
	print( "\n\nQUICK TEST: SIMULATE ROLLS ******************************" )
	self.faces = faces
	for i in range(rolls):
		roll()
	print( roll_map )
	print( percentage_map )
	var mxp = get_max_percentage()
	var mnp = get_min_percentage()
	print ("max_percentage = ", mxp)
	print ("min_percentage = ", mnp)
	print ("range = ", str(mxp[1]-mnp[1]))
	print( "DONE ******************************\n\n" )	

func roll():
	var result:int = randi_range(1,faces)
	var val:int = roll_map.get(result,0)
	val += 1
	roll_map.set(result,val)
	var percentage:float = 100*float(val)/float(rolls)
	percentage_map.set( result, percentage )
	
func get_max_percentage()->Array:  #returns [face,max_percentage]
	var mp:float = 0
	var face:int
	for i in range(1,faces+1):
		var p:float = percentage_map.get(i)
		if p >= mp:
			face = i
			mp = p
	return [face,mp]	
	
func get_min_percentage()->Array:  #returns [face,min_percentage]
	var mp:float = 100
	var face:int
	for i in range(1,faces+1):
		var p:float = percentage_map.get(i)
		if p <= mp:
			face = i
			mp = p
	return [face,mp]		
	
