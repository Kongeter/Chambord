extends Camera3D



var zoomSpeed = 2
var moveSpeed = 0.8

func _ready():
	pass


func _input(event):
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	controlls(delta)
	pass
	
func _unhandled_input(event):
	if event.is_action_pressed("cam_zoom_in"):
		position.y -= zoomSpeed
	if event.is_action_pressed("cam_zoom_out"):
		position.y += zoomSpeed

func controlls(delta):
	if Input.is_action_pressed("cam_down"):
		position.z += moveSpeed
	if Input.is_action_pressed("cam_up"):
		position.z -= moveSpeed
	if Input.is_action_pressed("cam_left"):
		position.x -= moveSpeed
	if Input.is_action_pressed("cam_right"):
		position.x += moveSpeed

