##stops the dice from clacking too much from multiple collisions at nearly the same time.
##call clear() when Tray is cleared,
##and call check_event() during collision event processing to determine 
##whether to play a sound or not  

class_name Debouncer extends Node



## key: [collisionObject1,CollisionObjec2]
## val:  int game time in milliseconds when collision event last occured.
var _log:Dictionary= {}


## records the time that a collision event between two objects occurred,
## and returns false if the last time they collided was too soon ( ie 1/4 second )
func check_event( c1:CollisionObject3D, c2:CollisionObject3D )->bool:
	var key:Dictionary = {c1:1, c2:1}
	
	var current_time:int = Time.get_ticks_msec()
	
	if !_log.has(key):  ##not in the dictionary yet.  Add it and return true.
		_log.set(key,current_time)
		return true
		
	else:
		var last_time:int = _log.get(key)
		if current_time - last_time < 200:
			return false #too soon
		else:
			_log.set(key,current_time)
			return true

	
func clear()->void:
	print("debouncer clear")
	_log.clear()
