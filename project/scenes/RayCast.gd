extends RayCast3D


signal clickedGroup(type, group, round)
signal hoverGroup(type, group, round)
signal unhoverGroup(type, group, round)

var curGroup;
var curType;
var curRound;

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
	if collider is GroupSelector:
		var group = collider.group
		var round = collider.round
		var type = collider.type;
		if group != curGroup:
			hoverGroup.emit(type,group,round)
			unhoverGroup.emit(curType, curGroup, curRound)
			curGroup = group
			curType = type
			curRound = round
	
	
	pass


func _on_camera_3d_actual_click():
	clickedGroup.emit(curType, curGroup, curRound)
	pass # Replace with function body.
