#Utilities 

extends Node

func get_last_chars(s:String, num:int)->String:
	return s.substr(s.length()-num,s.length())	

##finds the interpolation between a and b, given the
##parameter t which is the proportional distance from
##a to b.   at a, t = 0.  at b, t = 1
func lerp( a:float, b:float, t:float)->float:
	return a + (b-a)*t

##solves for the t parameter, given the interpolation between b and a
##Note to self: GlobalScope has lerp().  It also has a remap() function that 
##lerps and unlerps in one operation, dumbass
func unlerp( a:float, b:float, _lerp:float )->float:
	if b-a == 0: return 0
	var t:float = (_lerp-a)/(b-a)
	return t

## Font methods don't return tight bounds of a string, more like line-height.
## so they are useless for centering text in graphs and stuff like that.
##
## this is an attempt to use the font server to get accurate string bounds.
## it will only measure a single line.  Don't have \n in your string.	
##
## NOTE! THIS DOESN'T WORK YET!  Y Values are wrong.  NEEDS TESTING

func get_tight_bounds( txt:String, font:Font, font_size:float )->Vector2:
	var text_server = TextServerManager.get_primary_interface()
	var paragraph = TextParagraph.new()
	paragraph.add_string(txt, font, font_size)
	var line_rid = paragraph.get_line_rid(0)
	var glyphs = text_server.shaped_text_get_glyphs(line_rid)  #returns an array of dictionaries
	var line_tight_rect = Rect2()
	var x = 0
	var y = 0
	for glyph in glyphs:
		var glyph_font_rid = glyph.get('font_rid', RID())
		var glyph_font_size = Vector2i(glyph.get('font_size', 8), 0)
		var glyph_index = glyph.get('index', -1)
		var glyph_offset = text_server.font_get_glyph_offset(glyph_font_rid, glyph_font_size, glyph_index)
		var glyph_size = text_server.font_get_glyph_size(glyph_font_rid, glyph_font_size, glyph_index)	
		var glyph_rect = Rect2(Vector2(x, y) + glyph_offset, glyph_size)
		if not line_tight_rect.has_area():
			# initialize the tight rect with the first glyph rect if it's empty
			line_tight_rect = glyph_rect
		else:
			# or merge the glyph rect
			line_tight_rect = line_tight_rect.merge(glyph_rect)
	return line_tight_rect.size
	

##for the settings.ini file.  The standard way
#that the ConfigFile writes Dictionaries takes too 
#many lines	
func dict_to_string( d:Dictionary[int,int] )->String:
		var res:String = ""
		for key in d:
			res = res + str(key) + ":" + str(d.get(key))+","
		
		res = res.rstrip(",")
		return res	
		
func string_to_dict( s:String )->Dictionary[int,int]:
		var res:Dictionary[int,int] = {}
		var sa:Array = s.split( ",",false )
		for entry:String in sa:
			var entry_array:Array = entry.split(":",false)
			res.set( int(entry_array[0]), int(entry_array[1]) )
		return res
		
