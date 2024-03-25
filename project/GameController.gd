extends Node

var GameField 
var cards = []
var tileStack
var rng = RandomNumberGenerator.new()


func _ready():
	GameField = get_node("%GameField")
	tileStack = ["A","B","C","D","E","F"]
	playGame()

func playGame():
	while(true):
		await tileSelection(0)

func tileSelection(player: int):
	var tileType = tileStack.pick_random()#TODO remove choosen tile
	var legitPlaces = getLegitPlaces()
	var klickedTileCoords = await GameField.tileChooser(tileType, legitPlaces)
	GameField.placeTile(klickedTileCoords[0],klickedTileCoords[1],0,tileType)
	var newcard = Card.new(1,1,3,3,0,0)#TODO save the correct card
	cards.append(newcard)
	return
	
func getLegitPlaces():
	rng.randomize()
	return [Coord.new(rng.randi_range(-9, 9),rng.randi_range(-9, 9)),Coord.new(rng.randi_range(-9, 9),rng.randi_range(-9, 9))]   #TODO get tile legit places + roation
	
func _process(delta):
	pass


