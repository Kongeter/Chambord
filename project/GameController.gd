extends Node


var placedCards = [Card.new(0,0,3,0,0,0)]
var GameField
var tileStack
var rng = RandomNumberGenerator.new()


func _ready():
	GameField = get_node("%GameField")
	GameField.placeTile(0,0,0,"D")
	tileStack = ["A","B","C","D","E","F"]
	playGame()

func playGame():
	while(true):
		await tileSelection(0)

@rpc("any_peer","call_local")
func placeTile(tilePos, rotation, tileType):
	GameField.placeTile(tilePos.x,tilePos.y,0,tileType)
	var newcard = Card.new(tilePos.x,tilePos.y,3,3,0,0)#TODO save the correct card
	placedCards.append(newcard)

func tileSelection(player: int):
	var tileType = tileStack.pick_random()#TODO remove choosen tile
	var legitPlaces = getLegitPlaces()
	var klickedTileCoords = await GameField.tileChooser(tileType, legitPlaces)
	placeTile.rpc(klickedTileCoords, 0, tileType)
	return
	
func getLegitPlaces():
	var possiblePlaces = []
	for card: Card in placedCards:
		var directions = [[1, 0], [-1, 0], [0, 1], [0, -1]]
		for dir in directions:
			var newX= card.xCoord+dir[0]
			var newY= card.yCoord+dir[1]
			if !Helper.arrayHas(possiblePlaces, func(c): return c.equals(newX, newY)) and !Helper.arrayHas(placedCards, func(c): return (c.xCoord == newX and c.yCoord == newY)):
				possiblePlaces.append(Coord.new(newX,newY))



	return possiblePlaces
	
func _process(delta):
	pass


