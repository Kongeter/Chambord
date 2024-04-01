extends Node
class_name Client

@onready var lobby = $Lobby
@onready var mainScene = load("res://scenes/mainScene.tscn")

enum Message{
	Create,
	Join,
	Message,
	Id,
	Lobby,
}
var myId : int = 0
var hostId: int
var lobbyValue: String = ""

var order = []
var players
var nextPlayer

var socket = WebSocketPeer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	#connectToServer("wss://1223233612753928257.discordsays.com/api/ws")
	#connectToServer("wss://345654.xyz/ws")
	connectToServer("ws://localhost:1337/ws")
	pass # Replace with function body.

func RTCServerConnected():
	print("RTC server connected")
	
func RTCPeerConnected(id):
	print("RTC peer connected")
	
func RTCPeerDisconnected(id):
	print("RTC peer disconnected")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet()
			if packet != null:
				
				var dataString = packet.get_string_from_utf8()
				
				if dataString == "start":
					print("connection works")
					continue
				var data = JSON.parse_string(dataString)
				print(data)
				if data.Message == Message.Id:
					myId = data.Id
				elif data.Message == Message.Lobby:
					print(data.Id)
					players = data.Users
					lobby.showLobby(data.Id, true)
					for p in players:
						order.append(p.Id)
					lobby.showPlayers(data.Users)
				elif data.Message == Message.Message:
					match data.f:
						"sg":
							handleStartGame(data)
						"pt":
							handlePlaceTile(data)
						"fl":
							handlePlaceFlag(data)
						"tu":
							handleTurn(data)
	


	
	
func connectToServer(url):
	var err = socket.connect_to_url(url)
	if err != OK:
		print("Unable to connect")
	else:
		print("client started")
	pass



func switchScene():
	remove_child($Lobby)
	get_tree().root.add_child(mainScene.instantiate())




func getPlayerNames(players):
	var playerNames : Array = []
	for p in players:
		playerNames.append(players[p].name)
	return playerNames


func _on_lobby_create_lobby(playerName):
	var message = {
		"Name" : playerName
	}
	var messageBytes = (str(Message.Create)+JSON.stringify(message)).to_utf8_buffer()
	socket.put_packet(messageBytes)
	pass # Replace with function body.


func _on_lobby_join_lobby(playerName, lobbyId):
	print("join lobby")
	var message = {
		"LobbyId" : lobbyId,
		"Name" : playerName
	}
	var messageBytes = (str(Message.Join)+JSON.stringify(message)).to_utf8_buffer()
	socket.put_packet(messageBytes)
	pass # Replace with function body.

func sendMessgae(data):
	var messageBytes = (str(Message.Message)+JSON.stringify(data)).to_utf8_buffer()
	socket.put_packet(messageBytes)


func _on_start_game_pressed():
	startGame()
	pass # Replace with function body.
	
	
func startGame():
	switchScene()
	sendStartGame()
	pass

func sendStartGame():
	sendMessgae({
		"Message":Message.Message,
		"f":"sg"})

func handleStartGame(data):
	switchScene()
	
signal placeTile(x,y,rot, type)

func sendPlaceTile(x,y,rot,type):
	print("test send")
	sendMessgae({
		"Message":Message.Message,
		"f":"pt",
		"x":x,
		"y": y,
		"rot": rot,
		"type": type})
	
func handlePlaceTile(data):
	placeTile.emit(data.x, data.y, data.rot, data.type)

signal placeFlag(x,y, group, type, player)

func sendPlaceFlag(x,y, group,type, player):
	print("test send")
	sendMessgae({
		"Message":Message.Message,
		"f":"fl",
		"x":x,
		"y": y,
		"group": group,
		"type": type,
		"player": player})
	
func handlePlaceFlag(data):
	print("place flag handler")
	placeFlag.emit(int(data.x), int(data.y), int(data.group), int(data.type), int(data.player))
	

signal playerTurn(player)

func sendTurn(player):
	print("test send")
	sendMessgae({
		"Message":Message.Message,
		"f":"tu",
		"player": player})
	
func handleTurn(data):
	playerTurn.emit(data.player)
