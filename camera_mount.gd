extends Node3D
# a turntable mount that is controllable via a,d for rotate camera cw,ccw
# and tilt camera up and down with w and s.

enum MODE {FREE_LOOK, SELECT}
var mode = MODE.SELECT

## the degrees per second speed at which the turntable camera view rotates when the user presses the adsw keys
@export var rotation_speed:float = 45

##meters per second
@export var dolly_speed:float = 0.1
@export var mouse_zoom_speed:float = 0.1
@export var mouse_horiz_speed:float = 0.1

## max tilt in x degrees above the horizontal.   [br]
## note that the x tilt values above horizontal are actually negative, but
## we handle that in the code.
@export var max_tilt:float = 75
@export var min_tilt:float = 20
@export var starting_tilt:float = 45
@export var starting_distance:float = 5
@export var starting_angle:float = 210
@export var min_distance:float = 2
@export var max_distance:float = 5

var cam:Camera3D
var d2r = PI/180
var r2d = 180/PI

var old_mouse_pos:Vector2 = Vector2(0,0)


func _ready() -> void:
	cam = $Camera
	
	rotation.x = Settings.read("Camera", "altitude") * d2r * -1
	rotation.y = Settings.read("Camera", "azimuth") * d2r
	cam.position.z = Settings.read("Camera", "zoom")
	
	#rotation.x = -starting_tilt*d2r
	#rotation.y = starting_angle*d2r
	#cam.position.z = starting_distance

func save_camera()->void:
		print("saving camera")
		Settings.write_and_save( "Camera", "zoom", cam.position.z )
		Settings.write_and_save( "Camera", "altitude",
			rotation.x * r2d * -1
		)
			
		Settings.write_and_save( "Camera", "azimuth",
			rotation.y * r2d	
		)			

func _input( event:InputEvent ):
	if event is InputEventMouseButton:		
		#free look / select mode toggle
		
		if event.button_index == MOUSE_BUTTON_MIDDLE \
				or event.button_index == MOUSE_BUTTON_RIGHT:
			if( event.pressed ):  #turntable look mode
				#save the mouse pos so we can return to it after
				old_mouse_pos = %Scene.get_viewport().get_mouse_position()
				#print( "old_mouse_pos  = ", old_mouse_pos )
				mode = MODE.FREE_LOOK
				Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED
			else: #move the mouse around mode.
				mode = MODE.SELECT
				Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE
				#restore the old mouse position
				%Scene.get_viewport().warp_mouse( old_mouse_pos )
			
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#print( "wheel up")
			#dolly the camera closer to the game board
			cam.position.z -= mouse_zoom_speed
			if( cam.position.z < min_distance ):
				cam.position.z = min_distance
			
				
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#print( "wheel down")
			#dolly the camera farther from the game board
			cam.position.z += mouse_zoom_speed
			if( cam.position.z > max_distance ):
				cam.position.z = max_distance	
						
			
	elif event is InputEventMouseMotion:
		if mode == MODE.FREE_LOOK:
			
			var offset:Vector2 = Vector2(event.screen_relative)
			rotation.y += -offset.x * d2r * mouse_horiz_speed;
			rotation.x += -offset.y * d2r * mouse_horiz_speed;
			if( rotation.x > 0 ): rotation.x = 0
			var mxtilt = max_tilt*d2r
			var mntilt = min_tilt*d2r
			if( rotation.x < -mxtilt  ): rotation.x = -mxtilt
			if( rotation.x > -mntilt  ): rotation.x = -mntilt
			
	
			


func _physics_process(delta):
	#we disabled the keyboard handling because there is a memory leak.
	#you should check the similar script in the tak board.
	#it may also have a memory leak.
	
	#note:  tak board is fine.  Perhaps this leak is because
	# we don't have the input map defined?
	if true: return
	
	
	if Input.is_action_pressed("cam_ccw"):
		#rotate the camera mount node ccw about Y (up) axis
		rotation.y += rotation_speed*d2r*delta;
		if( rotation.y > TAU ): rotation.y -= TAU
		
	elif Input.is_action_pressed("cam_cw"):
		#rotate the camera mount node ccw about Y (up) axis
		rotation.y -= rotation_speed*d2r*delta;	
		if( rotation.y < 0 ): rotation.y += TAU
		
	elif Input.is_action_pressed("cam_tilt_up"):
		#tilt the camera up so you are looking more down at the board from above.
		var mxtilt = max_tilt*d2r
		
		#print( "tilt up ", rotation.x)
		rotation.x += -rotation_speed*d2r*delta;	
		if( rotation.x < -mxtilt  ): rotation.x = -mxtilt
		
		
	elif Input.is_action_pressed("cam_tilt_down"):
		#tilt the camera down so you are looking more from the side
		rotation.x -= -rotation_speed*d2r*delta;	
		var mntilt = min_tilt*d2r
		if( rotation.x > -mntilt  ): rotation.x = -mntilt
		
	elif Input.is_action_pressed("cam_closer"):
		#dolly the camera closer to the game board
		cam.position.z -= dolly_speed*delta
		if( cam.position.z < min_distance ):
			cam.position.z = min_distance
		
	elif Input.is_action_pressed("cam_farther"):
		#dolly the camera farther from the game board
		cam.position.z += dolly_speed*delta
		if( cam.position.z > max_distance ):
			cam.position.z = max_distance	
		
		
		
