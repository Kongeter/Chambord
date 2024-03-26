extends Camera3D

const zoomSpeed = 2
const moveSpeed = 0.01
const minHeight = 5
var mouseDown = false
var startCamPos : Vector3
var startMousePos : Vector2
var maxDistFromStart := 0.0
var timePressed := 0.0
var targetPosition: Vector3

signal previewTileClicked(x,y)

func _ready():
	targetPosition = position
func _process(delta):
	mouseHandler(delta)
	controlls(delta)
	lerpCam(delta)

func mouseHandler(delta):
	var curMousePos: Vector2 
	if mouseDown:
		timePressed += delta
		curMousePos = get_viewport().get_mouse_position()
		var dist = (curMousePos - startMousePos).length()
		if dist > maxDistFromStart:
			maxDistFromStart = dist
		if timePressed > 0.1:
			moveCamera(curMousePos, startMousePos)
	if Input.is_action_just_pressed("left_click"):
		startCamPos = position
		maxDistFromStart = 0
		timePressed = 0
		mouseDown = true
		startMousePos = get_viewport().get_mouse_position()
		
	if Input.is_action_just_released("left_click"):
		if maxDistFromStart <= 3 || timePressed<0.1:
			get_selection(get_viewport().get_mouse_position())
		mouseDown = false
		
#func _input(event):
	#var mouse = Vector2()
	#if event is InputEventMouse:
		#mouse = event.position
	#if event is InputEventMouseButton and event.pressed:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#get_selection(mouse)
func moveCamera(curMousePos, startMousePos):
	var b = get_y_plane_intersection(curMousePos)
	var a = get_y_plane_intersection(startMousePos)
	var dif = a-b
	targetPosition.x = startCamPos.x + dif.x
	targetPosition.z = startCamPos.z + dif.y
	pass

func get_y_plane_intersection(mouse) -> Vector2:
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 1000)
	var dir = end-start
	dir = dir.normalized()
	
	var t = -start.y/dir.y
	var point = start + t*dir
	return Vector2(point.x - position.x, point.z-position.z)
	
	
func get_selection(mouse):
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 1000)
	var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
	if result:
		previewTileClicked.emit(result.position[0],result.position[2])

func _unhandled_input(event):
	if event.is_action_pressed("cam_zoom_in"):
		targetPosition.y= max(targetPosition.y-zoomSpeed,minHeight)
	if event.is_action_pressed("cam_zoom_out"):
		targetPosition.y = targetPosition.y+zoomSpeed

func controlls(delta):
	var speed = moveSpeed * targetPosition.y
	if Input.is_action_pressed("cam_down"):
		targetPosition.z += speed
		targetPosition.x += speed
	if Input.is_action_pressed("cam_up"):
		targetPosition.z -= speed
		targetPosition.x -= speed
	if Input.is_action_pressed("cam_left"):
		targetPosition.x -= speed
		targetPosition.z += speed
	if Input.is_action_pressed("cam_right"):
		targetPosition.x += speed
		targetPosition.z -= speed

func lerpCam(delta):
	position = position.lerp(targetPosition, delta*20)
