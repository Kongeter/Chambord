extends Node

var StartCard = Card.new(1,1,"A",0,0,0)
var placedCards = [StartCard]
var GameField
var tileStack
var rng = RandomNumberGenerator.new()

func _ready():
	GameField = get_node("%GameField")
	GameField.placeTile(StartCard.xCoord,StartCard.yCoord,StartCard.rotation,StartCard.type)
	tileStack = ["A","B","C","D","E","F"]
	#tileStack = ["A"]
	playGame()

func playGame():
	while(true):
		DebugHelper.showBoard(placedCards ,6,6)
		await turn(0)
		
@rpc("any_peer","call_local")
func placeTile(tilePosAndRotation, tileType):
	GameField.placeTile(tilePosAndRotation[0],tilePosAndRotation[1],tilePosAndRotation[2],tileType)
	var newcard = Card.new(tilePosAndRotation[0],tilePosAndRotation[1],tileType,tilePosAndRotation[2],0,0)
	placedCards.append(newcard)

func turn(player: int):
	var tileType = tileStack.pick_random()#TODO remove choosen tile
	var ValidPositions = HelperCards.getValidPositions(tileType, placedCards)
	var klickedTileCoordsAndRotation = await GameField.tileChooser(tileType, ValidPositions)
	placeTile.rpc(klickedTileCoordsAndRotation, tileType)
