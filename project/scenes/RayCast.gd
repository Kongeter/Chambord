extends RayCast3D


signal clickedGroup(type, group, coords)
signal hoverGroup(type, group, coords)
signal unhoverGroup(type, group, coords)

var curGroup = -1;
var curType = -1;
var curCoords = Vector2(-1,-1);

func rippleTest(position):
	var material: ShaderMaterial = load("res://materials/grassRipple.tres")
	material.set_shader_parameter("origin", position);
	material.set_shader_parameter("start_time", Time.get_ticks_msec() / 1000);
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera = get_viewport().get_camera_3d()
	var mouse = get_viewport().get_mouse_position()
	var start = camera.project_ray_origin(mouse)
	var end = camera.project_position(mouse, 100)
	position = start
	target_position = end-camera.position
	var collider = get_collider()
	if(Input.is_action_just_pressed("cam_zoom_in")):
		rippleTest( get_collision_point())
	if !is_colliding():
		if(curGroup != -1):
			unhoverGroup.emit(curType, curGroup, curCoords)
			curGroup = -1
			curType = -1
			curCoords = Vector2(-1,-1)
	elif collider is GroupSelector:
		var group = collider.group
		var coords = collider.coords
		var type = collider.type;
		if group != curGroup || type != curType || coords != curCoords:
			unhoverGroup.emit(curType, curGroup, curCoords)
			hoverGroup.emit(type,group,coords)
			curGroup = group
			curType = type
			curCoords = coords
	pass


func _on_camera_3d_actual_click():
	clickedGroup.emit(curType, curGroup, curCoords)
	pass # Replace with function body.
