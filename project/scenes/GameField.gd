extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	placeTile(0,0,0,"A")
	placeTile(1,0,2,"B")
	showPossiblePlaces([Coord.new(1,1),Coord.new(0,1)])
	pass # Replace with function body.
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func placeTile(x,y,rotation_,type):
	var tilePath = "res://tiles/"+type+".tscn"
	var scene = load(tilePath)
	var instance = scene.instantiate()
	instance.position.x = 2*x
	instance.position.z = 2*y
	instance.rotate_y(deg_to_rad(90.0)*rotation_)
	add_child(instance)
	
func showPossiblePlaces(possiblePlaces: Array):
	for coord:Coord in possiblePlaces:
		var scene = load("res://tiles/previewCard.tscn")
		var instance = scene.instantiate()
		instance.position.x = 2 * coord.xCoord
		instance.position.z = 2 * coord.yCoord
		add_child(instance)
	
