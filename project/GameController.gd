extends Node

var StartCard = Card.new(1,1,"A",0,0,0)
var placedCards = [StartCard]
var placedFlags = []
var GameField
var connection : Client
var tileStack
var rng = RandomNumberGenerator.new()
var AG = AreaGroups.new()

var nextPlayer = -1
var myId = 1


func _ready():
	GameField = get_node("%GameField")
	connection = get_tree().root.get_node("Client")
	if connection != null:
		connection.placeTile.connect(placeTile)
		connection.placeFlag.connect(placeFlag)
		connection.playerTurn.connect(turn)
		myId = connection.myId
		for i in range(connection.order.size()):
			if connection.order[i] == connection.myId:
				nextPlayer = connection.order[(i + 1) % connection.order.size()]
		#connection.playerTurn.connect(playerTurn)
	GameField.placeTile(StartCard.xCoord,StartCard.yCoord,StartCard.rotation,StartCard.type)
	#tileStack = ["A","B","C","D","E","F"]
	tileStack = ["D"]
	AG.addCard(StartCard, []) #add first card to AreaGroups
	turn(1)
	#playGame()

#func playGame():
	#while(true):
		##DebugHelper.showBoard(placedCards ,6,6)
		#await turn(0)
		#await get_tree().create_timer(0.5).timeout

func placeTile(x,y,rot,type):
	var newcard = Card.new(x,y,type,rot,0,0)
	AG.addCard(newcard,placedCards)
	GameField.placeTile(x,y,rot,type)
	placedCards.append(newcard)
	
func placeFlag(x,y, group,type,player):
	var flag = Flag.new(x,y, group,type,player)
	print(flag)
	placedFlags.append(flag)
	GameField.placeFlag(flag)

func turn(player: int):
	print(myId)
	if player != myId:
		return
	var tileType = tileStack.pick_random()#TODO remove choosen tile
	var ValidPositions = HelperCards.getValidPositions(tileType, placedCards)
	var klickedTileCoordsAndRotation = await GameField.tileChooser(tileType, ValidPositions)
	if connection != null:
		connection.sendPlaceTile(klickedTileCoordsAndRotation[0],klickedTileCoordsAndRotation[1],klickedTileCoordsAndRotation[2], tileType)
	placeTile(klickedTileCoordsAndRotation[0],klickedTileCoordsAndRotation[1],klickedTileCoordsAndRotation[2], tileType)
	var result = await $"../RayCast3D".clickedGroup
	placeFlag(klickedTileCoordsAndRotation[0],klickedTileCoordsAndRotation[1],result[1],result[0], 0)
	if connection != null:
		connection.sendPlaceFlag(klickedTileCoordsAndRotation[0],klickedTileCoordsAndRotation[1],result[1],result[0], 0)
		connection.sendTurn(nextPlayer)
	
func getArea(x,y, group,type):
	return AG.getAreaGroup(x,y,group,type)
