extends Node3D

func _process(delta):
	controlls(delta)
	
var tileRotation
var xClicked = 1
var yClicked = 1
var ValidPositions_G
var placedTileNodes : Dictionary
var flagNode = preload("res://assets/flag.tscn")

func tileChooser(type: String, ValidPositions:Array):
	ValidPositions_G = ValidPositions
	$%TileLabel.text = type
	tileRotation = 0
	showPossiblePlaces(ValidPositions.filter(func(p):return p[2]==0).map(func(p):return Coord.new(p[0],p[1])))
	await Signal(get_node("%Camera3D"), "previewTileClicked")
	removePossiblePlaces()
	return [xClicked, yClicked, tileRotation]

func _on_camera_3d_preview_tile_clicked(x, y):
	xClicked = -int(floor(x/2))-1
	yClicked = int(floor(y/2))

func placeTile(x,y,tileRotation_,type):
	var tilePath = "res://tiles/"+type+".tscn"
	var scene = load(tilePath)
	var instance = scene.instantiate()
	instance.position.x = -(2*x+1)
	instance.position.z = 2*y+1
	instance.rotate_y(-deg_to_rad(90.0)*(tileRotation_+1))
	add_child(instance)
	placedTileNodes[Vector2(x,y)] = instance
	markGroupSelectors(instance,Helper.getIndexFromLetter(type))

func placeFlag(flag : Flag):
	var tile : Node = placedTileNodes[Vector2(flag.x, flag.y)]
	var subNode
	match flag.type:
		0:
			subNode = tile.get_node("Grass/"+str(flag.group))
		1:
			subNode = tile.get_node("City/"+str(flag.group))
		2:
			subNode = tile.get_node("Street/"+str(flag.group))
		3:
			subNode = tile.get_node("Church")
	var point = subNode.get_child(0)
	var flagInst = flagNode.instantiate()
	add_child(flagInst)
	flagInst.position = point.global_position
	

var previewCardElements:Array
func showPossiblePlaces(possiblePlaces: Array):
	for coord:Coord in possiblePlaces:
		var scene = load("res://tiles/previewCard.tscn")
		var instance = scene.instantiate()
		instance.position.x = -(2 * coord.xCoord +1)
		instance.position.z = 2 * coord.yCoord+1
		previewCardElements.append(instance)
		print(coord.xCoord, " " ,coord.yCoord)
		add_child(instance)

func removePossiblePlaces():
	for previewCard in previewCardElements:
		previewCard.queue_free()
	previewCardElements = []
	
func controlls(delta):
	if Input.is_action_just_pressed("rotate_tile_left"):
		tileRotation = (tileRotation + 3)%4
		removePossiblePlaces()
		showPossiblePlaces(ValidPositions_G.filter(func(p):return p[2]==tileRotation).map(func(p):return Coord.new(p[0],p[1])))
	if Input.is_action_just_pressed("rotate_tile_right"):
		tileRotation = (tileRotation + 1)%4
		removePossiblePlaces()
		showPossiblePlaces(ValidPositions_G.filter(func(p):return p[2]==tileRotation).map(func(p):return Coord.new(p[0],p[1])))
	$%TileRotLabel.text = str(tileRotation)

func markGroupSelectors(tile, type: int):
	print(tile.name)
	var grass = tile.get_node("Grass")
	for i in range(CardTypes.cards[type].connectGroupsGrass.size()):
		
		var group : Node3D = grass.get_node(str(i))
		var collisions = Helper.getChildrenWithGroup(group,"Collision")
		for col in collisions:
			if(col is GroupSelector):
				col.type = 0
				col.group = i
		
	
	
