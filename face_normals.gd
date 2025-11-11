##unpacks the collision shapes of the dice
##to get at the face normals

extends Node

## {dice-name: faceInfo}
## faceInfo = { face_number: [center_point,normal] }
var map:Dictionary = {}
var R2D:float = 180/PI

## calulates which face has which number from the invisible facenormal objects,
## and also calculates the actual normals of the faces from those.
##
## This is all necessary because there is no way to add metadata to faces in blender
## and have it imported into godot
func unpack( label:String, dice:RigidBody3D)->void:
	var dict:Dictionary = {}  #{die_face : [point, normal]}

	#print("found the following FaceNormals:")
	var face_normals:Node3D = dice.get_node("FaceNormals")
	for child:MeshInstance3D in face_normals.get_children():
		var lst:Array = []		
		var n:int = int(get_last_char(child.name,2))  #the number written on the dice
		#print("face " , n)
		var mdt = MeshDataTool.new()
		mdt.create_from_surface(child.mesh, 0)
		#print( "found ", mdt.get_vertex_count(), " vertices" )
		
		## meshdatatool adds many extra duplicate vertices.  we need to get rid of these
		for i in range(mdt.get_vertex_count()):
			var v:Vector3 = mdt.get_vertex(i)
			if not contains( lst, v ):
				lst.append(v)
		#print( "found " , len(lst), " unique vertices")
		#print(lst)
		
		#collect into two triangles.
		var far:Array[Vector3] = []
		var near:Array[Vector3] = []
		for v in lst:
			if v.length() > 0.6:
				far.append(v)
			else:
				near.append(v)	
		
		#print( "near = ", near )
	#	print( "far = ", far)
		
		#find their average ( center ).  these become the center point and the normal of the face.
		var pnt:Vector3 = average_v(near)
		var norm:Vector3 = (average_v(far)-pnt).normalized()
		
		#print("pnt = ", pnt)
		#print("norm = ", norm)
		
		dict.set(n, [pnt,norm])
		
	map.set(label,dict)	
	
	#print( map )
	
	
#returns the face number of the face with normal vector close to 0,-1,0.
#if it doesn't find this, returns -1 for a cocked throw.

func get_upface( die:String, euler:Vector3 )->int:
	#print( "doing " + die )
	var y:float = 1.0
	if die == "d4" : y = -1.0
	var up:Vector3 = Vector3(0,y,0)
	var q:Quaternion = Quaternion.from_euler(euler).normalized()
	var dict:Dictionary = map.get(die)
	var min_angle:float = 179
	var _min_face = 21
	for n in dict:  #n = numbers on faces
		var v_rot:Vector3 = q*dict.get(n)[1].normalized()  #we need a function called get_face_normal!
		#print( "rotated = ", v_rot )
		var angle:float = v_rot.angle_to(up)*R2D
		#print( n, "has angle ", angle )
		if angle < min_angle:
			min_angle = angle
			_min_face = n
	
		#print( "angle from vertical = ", angle)
		if(angle < 15.0):
		#if approx_eq(v_rot, Vector3(0,y,0)):
			return n
			
	
	#it is cocked.  no face normals were less than 3 degrees from the vertical.
	#print( "minimum angle from vertical was ", min_angle, " for face ", min_face )
	return -1
		
		
	

func contains( lst:Array, v:Vector3 )->bool:
	for i in lst:
		if approx_eq( i, v ):
			return true
	return false		
	
func approx_eq( a:Vector3, b:Vector3 )->bool:
	return approx(a.x, b.x) and approx(a.y, b.y) and approx(a.z, b.z)
	
func approx( a:float, b:float )->bool:
	return abs(a-b) < 0.03
	
func get_last_char(s:String, num:int)->String:
	return s.substr(s.length()-num,s.length())	
	
	
func average_f( lst:Array )->float:
	var c:float = 0
	for i in lst: c += i
	return c/len(lst)
	
func average_v( lst:Array[Vector3] )->Vector3:
	var xa:Array = []
	var ya:Array = []	
	var za:Array = []
	for v in lst:
		xa.append(v.x)
		ya.append(v.y)
		za.append(v.z)
	
	return Vector3(average_f(xa), average_f(ya), average_f(za))
	
	
	
