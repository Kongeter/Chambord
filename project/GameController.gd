extends Node

var StartCard = Card.new(1,1,"A",0,0,0)
var placedCards = [StartCard]
var GameField
var tileStack
var rng = RandomNumberGenerator.new()

func testing():
	var TestField = [Card.new(1,1,"A",0,0,0)]
	print("GameController/testing: 1:" , HelperCards.getValidPositions("A",TestField), "length", HelperCards.getValidPositions("A",TestField).size())
	DebugHelper.showBoard(TestField,4,4)
	
	
func _ready():
	await testing();
	GameField = get_node("%GameField")
	GameField.placeTile(StartCard.xCoord,StartCard.yCoord,StartCard.rotation,StartCard.type)
	#tileStack = ["A","B","C","D","E","F"]
	tileStack = ["A"]
	playGame()

func playGame():
	while(true):
		await turn(0)
		DebugHelper.showBoard(placedCards ,6,6)
		
@rpc("any_peer","call_local")
func placeTile(tilePosAndRotation, tileType):
	GameField.placeTile(tilePosAndRotation[0],tilePosAndRotation[1],tilePosAndRotation[2],tileType)
	var newcard = Card.new(tilePosAndRotation[0],tilePosAndRotation[1],tileType,tilePosAndRotation[2],0,0)#TODO save the correct card
	placedCards.append(newcard)

func turn(player: int):
	var tileType = tileStack.pick_random()#TODO remove choosen tile
	#print("------------------------------------------------------")
	#print(HelperCards.getValidPositions(tileType, placedCards))
	#print("------------------------------------------------------")
	#var legitPlaces = HelperCards.getLegitPlaces(placedCards)
	#var klickedTileCoordsAndRotation = await GameField.tileChooser(tileType, legitPlaces)
	var ValidPositions = HelperCards.getValidPositions(tileType, placedCards)
	var klickedTileCoordsAndRotation = await GameField.tileChooserV2(tileType, ValidPositions)
	placeTile.rpc(klickedTileCoordsAndRotation, tileType)
