extends Control


var panel = preload("res://nodes/panel.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if Input.is_action_just_pressed("left_click"):
		add_panel.rpc(get_global_mouse_position())
	pass
	
@rpc("any_peer","call_local")
func add_panel(pos):
	var panelInst = panel.instantiate()
	add_child(panelInst)
	panelInst.position = pos
