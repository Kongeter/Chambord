extends Node3D

var xClicked
var yClicked
func tileChooser(type: String, possiblePlaces:Array):
	showPossiblePlaces(possiblePlaces)
	await Signal(get_node("%Camera3D"), "previewTileClicked")
	removePossiblePlaces()
	return [xClicked, yClicked]

func _on_camera_3d_preview_tile_clicked(x, y):
	xClicked = int(x) / 2 
	yClicked = int(y) / 2

func placeTile(x,y,rotation_,type):
	var tilePath = "res://tiles/"+type+".tscn"
	var scene = load(tilePath)
	var instance = scene.instantiate()
	instance.position.x = 2*x+1
	instance.position.z = 2*y+1
	instance.rotate_y(deg_to_rad(90.0)*rotation_)
	add_child(instance)

var previewCardElements:Array
func showPossiblePlaces(possiblePlaces: Array):
	for coord:Coord in possiblePlaces:
		var scene = load("res://tiles/previewCard.tscn")
		var instance = scene.instantiate()
		instance.position.x = 2 * coord.xCoord +1
		instance.position.z = 2 * coord.yCoord+1
		previewCardElements.append(instance)
		add_child(instance)
		print("hello",instance)

func removePossiblePlaces():
	for previewCard in previewCardElements:
		previewCard.queue_free()
	previewCardElements = []


