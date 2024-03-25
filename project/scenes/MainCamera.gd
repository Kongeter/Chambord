extends Camera3D

const zoomSpeed = 2
const moveSpeed = 0.8
const minHeight = 5

signal previewTileClicked(x,y)

func _process(delta):
	controlls(delta)
	
func _input(event):
	var mouse = Vector2()
	if event is InputEventMouse:
		mouse = event.position
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_selection(mouse)

func get_selection(mouse):
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 1000)
	var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
	if result:
		previewTileClicked.emit(result.position[0],result.position[2])

func _unhandled_input(event):
	if event.is_action_pressed("cam_zoom_in"):
		position.y = max(position.y-zoomSpeed,minHeight)
	if event.is_action_pressed("cam_zoom_out"):
		position.y = position.y+zoomSpeed

func controlls(delta):
	if Input.is_action_pressed("cam_down"):
		position.z += moveSpeed
		position.x += moveSpeed
	if Input.is_action_pressed("cam_up"):
		position.z -= moveSpeed
		position.x -= moveSpeed
	if Input.is_action_pressed("cam_left"):
		position.x -= moveSpeed
		position.z += moveSpeed
	if Input.is_action_pressed("cam_right"):
		position.x += moveSpeed
		position.z -= moveSpeed

