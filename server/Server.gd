extends Node

enum Message{
	id,
	join,
	userConnected,
	userDisconnected,
	lobby,
	candidate,
	offer,
	answer,
	checkIn
}

var peer : WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var users = {}
var lobbies = {}

var Characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
# Called when the node enters the scene tree for the first time.
func _ready():
	peer.connect("peer_connected", peer_connected)
	peer.connect("peer_disconnected", peer_disconnected)
	startServer()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			if data.message == Message.lobby:
				JoinLobby(data.id, data.name, data.lobbyValue)
			if data.message == Message.offer || data.message == Message.answer || data.message == Message.candidate:
				print("source id is: " + str(data.orgPeer))
				sendToPlayer(data.peer, data)
	pass
	
func peer_connected(id):
	print("Peer conncted: " + str(id))
	users[id]= {
		"id" : id,
		"message" : Message.id
	}
	peer.get_peer(id).put_packet(JSON.stringify(users[id]).to_utf8_buffer())
	pass
func peer_disconnected(id):
	pass
	
func startServer():
	peer.create_server(8915)
	print("Server started")
	pass

func JoinLobby(userId, userName, lobbyId):
	if lobbyId == "":
		lobbyId = generateRandomString()
		lobbies[lobbyId] = Lobby.new(userId)
	var player = lobbies[lobbyId].AddPlayer(userId, userName)
	
	for p in lobbies[lobbyId].Players:
		
		var lobbyData = {
			"message" : Message.lobby,
			"players" : JSON.stringify(lobbies[lobbyId].Players),
			"host" : lobbies[lobbyId].HostID,
			"lobbyValue" : lobbyId
		}
		sendToPlayer(p, lobbyData)
		
		var data = {
			"message" : Message.userConnected,
			"id" : userId
		}
		print("send " + str(userId) + " to " + str(p))
		sendToPlayer(p, data)
		
		var data2 = {
			"message" : Message.userConnected,
			"id" : p
		}
		print("send " + str(p) + " to " + str(userId))
		sendToPlayer(userId, data2)
		
		
	
	var data = {
		"message" : Message.userConnected,
		"id" : userId,
		"player" : lobbies[lobbyId].Players[userId],
		
	}
	sendToPlayer(userId, data)
	

func sendToPlayer(userId, data):
	peer.get_peer(userId).put_packet(JSON.stringify(data).to_utf8_buffer())
func generateRandomString() -> String:
	var result = ""
	for i in range(6):
		var index = randi() % Characters.length()
		result += Characters[index]
	return result
