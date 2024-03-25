extends Node3D

func _process(delta):
	controlls(delta)
	
var tileRotation
var xClicked
var yClicked
var CardTypesInitiated_ = CardTypesInitiated.new()

func tileChooser(type: String, possiblePlaces:Array):
	$%TileLabel.text = type
	tileRotation = 0
	showPossiblePlaces(possiblePlaces)
	await Signal(get_node("%Camera3D"), "previewTileClicked")
	removePossiblePlaces()
	return [xClicked, yClicked, tileRotation]

func _on_camera_3d_preview_tile_clicked(x, y):
	xClicked = int(floor(x/2))
	yClicked = int(floor(y/2))

func placeTile(x,y,tileRotation_,type):
	var tilePath = "res://tiles/"+type+".tscn"
	var scene = load(tilePath)
	var instance = scene.instantiate()
	instance.position.x = 2*x+1
	instance.position.z = 2*y+1
	instance.rotate_y(-deg_to_rad(90.0)*tileRotation_)
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

func removePossiblePlaces():
	for previewCard in previewCardElements:
		previewCard.queue_free()
	previewCardElements = []
	
func controlls(delta):
	if Input.is_action_just_pressed("rotate_tile_left"):
		tileRotation = (tileRotation - 1)%4
	if Input.is_action_just_pressed("rotate_tile_right"):
		tileRotation = (tileRotation + 1)%4
	$%TileRotLabel.text = str(tileRotation)

#calculates the type of Edge (0=grass, 1=street, 2=city) from any given card
func calcEdgeType(card: Card):
	var res = []
	var index = Helper.getIndexFromLetter(card.type);
	var streetsFlattend = Helper.flatten(CardTypesInitiated_.cards[index].connectGroupsStreets)
	var cityFlattend = Helper.flatten(CardTypesInitiated_.cards[index].connectGroupsCitys)
	for side: int in range(0,4):
		if streetsFlattend.has(side):
			res.append(1)
		elif cityFlattend.has(side):
			res.append(2)
		else:
			res.append(0)
	return res

