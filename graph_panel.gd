## keeps track of statistics and
## draws a bar graph for a single type of dice.
class_name GraphPanel extends Panel

#set the title and the step on creation.   
#the other variables are calculated from that.
var title:String
var faces_count:int
var step:int=1  #x axis step


##key: face number, value: number of times it has occurred.
var counts:Dictionary[int,int] = {}


var number_font = load( "res://external/comme.regular.ttf" )
var text_font = load( "res://external/super_normal_font.ttf" )
var graph_upper:float  #the uppermost y position of the graph 
var graph_lower:float  #the lowermost y position of the graph


var bar_colors:Array = [Color.AQUAMARINE,Color.GOLDENROD,Color.CADET_BLUE]


func setup( _title:String, _faces:int, _step:int, _size:Vector2 )->void:
	self.title = _title
	self.faces_count = _faces
	self.step = _step
	custom_minimum_size = _size
	#_insert_test_data()
	queue_redraw()

func clear()->void:
	counts.clear()
	
func update( face:int )->void:
	var c:int = counts.get(face,0)
	c += 1
	counts.set( face, c )


func _ready():
	pass

	
	
func _insert_test_data():
	var n = faces_count
	for i in range(1,n+1):
		counts.set( i, randi_range(1,10))

## gets the current numbers of times the given face has come up
func get_face_total( face_num:int )->int:
	return counts.get( face_num, 0)
	
## gets all the face totals added together.
func get_total_rolls()->int:
	var res:int = 0 #result
	for face:int in range(1,faces_count+1):
		res += counts.get(face, 0)
	return res


## returns the proportion of the number of times the given face
## has been rolled, compared to the total number of rolls.
## Over time, the proportions of all the faces should 
## grow closer to 1/get_face_count(), if the dice is fair.

func get_proportion( face_num:int )->float:
	var total:float = get_total_rolls()
	var face:float = get_face_total( face_num )
	return face/total
	
func get_max_proportion()->float:
	var _max:float = 0
	for face in range(1,faces_count+1):
		_max = max( _max, get_proportion( face ))
	return _max
	
func get_min_proportion()->float:
	var _min:float = 100
	for face in range(1,faces_count+1):
		_min = min( _min, get_proportion( face ))
	return _min
	
func get_expected_proportion()->float:
	return 1.0/faces_count		
		
	
func _draw()->void:
	#print( "_draw!")
	
	var ins:int = 5  #general inset
	
	##bar graph margins
	var m_top:float = 25 #top margin
	var m_left:float = 29
	var m_right:float = 2
	var m_base:float = 15
	
	#draw the title
	var title_size:int = 16
	draw_string( text_font, 
		Vector2(ins+m_left,ins+title_size),
		title,
		HORIZONTAL_ALIGNMENT_LEFT,40,title_size)	
		
	#draw the total rolls
	var total_rolls_font_size:int = 10
	var total_rolls_width:int = 200
	var total_rolls = get_total_rolls()
	draw_string( number_font, 
		Vector2(
			m_left + 40,
			ins+title_size),
		"Total Rolls:  " + str(total_rolls),
		HORIZONTAL_ALIGNMENT_RIGHT,
		-1,
		total_rolls_font_size)			
	
	var graph_x:float = ins + m_left
	var graph_y:float = ins + m_top
	var graph_w:float = size.x - m_left - m_right - ins*2
	var graph_h:float = size.y - m_top - m_base - ins*2
	graph_upper = graph_y
	graph_lower = graph_y + graph_h
	
	var mx:float = get_max_proportion()*100
	var mn:float = get_min_proportion()*100
	if total_rolls == 0:
		mx = 100
		mn = 0
	var _exp:float = get_expected_proportion()*100
	var extra:float = (mx-mn)*0.1
	var mxx:float = min(100, mx + extra)
	var mnn:float = max(0, mn - extra)
	
	if total_rolls == 0:
		mx = 100
		mn = 0
	

	#draw the individual bars
	var bar_w = graph_w / faces_count
	for face:int in range(1,faces_count+1):
		var bar_x:float = graph_x + (face-1)*bar_w
		var bar_y:float = get_height(mxx, mnn, get_proportion(face)*100)
		var bar_h:float = graph_lower - bar_y
		
		var bar_rect:Rect2 = Rect2(bar_x, bar_y, bar_w, bar_h )
		draw_rect( bar_rect, bar_colors[face%2], true, -1, false )
	

	#draw the expected line
	var y_exp:float = get_height( mxx,mnn,_exp )
	
	draw_line( 
		Vector2(graph_x, y_exp), 
		Vector2(graph_x+graph_w, y_exp),
		Color.WHITE)
	

	#draw the border rect
	var graph_rect = Rect2(graph_x, graph_y, graph_w, graph_h)
	draw_rect( graph_rect, Color(1,1,1), false, 1, false )
		
	
	#draw the face numbers along the x axis
	var x_font_size = 10
	
	var n_y:float = graph_lower + x_font_size
	for num in range( 0, faces_count+1, step ):
		if num == 0 : continue
	
		var num_str:String = str(num)
		var str_w:float = number_font.get_string_size(
			num_str,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			x_font_size
			).x
		var n_x = graph_x + (num-1)*bar_w + bar_w*0.5 - str_w*0.5
		#if num > 9: n_x -= 2
		draw_string( number_font,
			Vector2(n_x,n_y),
			str(num),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			x_font_size)
		
		
	#draw the side numbers
	
	var text_x:float = graph_x - 2
	var text_w:float = ins+m_left+10
	
	
		
	#max
	draw_side_number( mxx, mnn, mx, text_x, text_w, true)
	
	#min
	draw_side_number( mxx, mnn, mn, text_x, text_w, true)
	
	#expected
	draw_side_number( mxx, mnn, _exp, text_x, text_w, true)
	
	
func draw_side_number(
		mx:float,
		mn:float,
		num:float,
		x:float,
		w:float,
		write_percent:bool = false
		)->void:
	
	var y_font_size:int = 10		
	var txt:String
	if write_percent:
		if num <= 0.0 : txt = "0%"
		elif num >= 100.0 : txt = "100%"
		else : 
			txt = "%3.1f" % (num) + "%"
	else:
		if num <= 0.0 : txt = "0"
		elif num >= 100.0 : txt = "100"
		else : txt = "%3.1f" % (num)
	
	
	var str_w:float = number_font.get_string_size(
			txt,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			y_font_size
			).x
	
	var y:float = get_height( mx,mn,num)
	
	
	draw_string( number_font, 
		Vector2(x-str_w,y+y_font_size/2-2),
		txt,
		HORIZONTAL_ALIGNMENT_RIGHT,-1,y_font_size)		
	
	

func get_height( mx:float, mn:float, val:float )->float:
		var t:float = Ut.unlerp(mx,mn, val)
		var y:float = Ut.lerp(graph_upper, graph_lower,t)	
		return y
