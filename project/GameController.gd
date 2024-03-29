extends Node

var StartCard = Card.new(1,1,"A",0,0,0)
var placedCards = [StartCard]
var placedFlags = []
var GameField
var tileStack
var rng = RandomNumberGenerator.new()
var AG = AreaGroups.new()

signal endOfTurn()

func _ready():
	GameField = get_node("%GameField")
	GameField.placeTile(StartCard.xCoord,StartCard.yCoord,StartCard.rotation,StartCard.type)
	tileStack = ["A","B","C","D","E","F"]
	tileStack = ["E"]
	AG.addCard(StartCard, []) #add first card to AreaGroups
	playGame()

func playGame():
	while(true):
		#DebugHelper.showBoard(placedCards ,6,6)
		await turn(0)
		await get_tree().create_timer(0.5).timeout

@rpc("any_peer","call_local")
func placeTile(tilePosAndRotation, tileType):
	GameField.placeTile(tilePosAndRotation[0],tilePosAndRotation[1],tilePosAndRotation[2],tileType)
	var newcard = Card.new(tilePosAndRotation[0],tilePosAndRotation[1],tileType,tilePosAndRotation[2],0,0)
	AG.addCard(newcard,placedCards)
	placedCards.append(newcard)
	endOfTurn.emit()

func turn(player: int):
	var tileType = tileStack.pick_random()#TODO remove choosen tile
	var ValidPositions = HelperCards.getValidPositions(tileType, placedCards)
	var klickedTileCoordsAndRotation = await GameField.tileChooser(tileType, ValidPositions)
	placeTile.rpc(klickedTileCoordsAndRotation, tileType)
	var result = await $"../RayCast3D".clickedGroup
	var flag = Flag.new(klickedTileCoordsAndRotation[0],klickedTileCoordsAndRotation[1],result[1],result[0], 0)
	placedFlags.append(flag)
	GameField.placeFlag(flag)
