extends Node

@onready var lobby = $Lobby

enum Message{
	id,
	join,
	userConnected,
	userDisconnected,
	lobby,
	candidate,
	offer,
	answer,
	removeLobby,
	checkIn,
	error,
	switchHost
}
var peer : WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var myId : int = 0
var rtcPeer : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var hostId: int
var lobbyValue: String = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(RTCServerConnected)
	multiplayer.peer_connected.connect(RTCPeerConnected)
	multiplayer.peer_disconnected.connect(RTCPeerDisconnected)
	#connectToServer("ws://104.248.47.16:8915")
	connectToServer("ws://127.0.0.1:8915")
	pass # Replace with function body.

func RTCServerConnected():
	print("RTC server connected")
	
func RTCPeerConnected(id):
	print("RTC peer connected")
	
func RTCPeerDisconnected(id):
	print("RTC peer disconnected")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	peer.poll()
	if peer.get_available_packet_count() > 0:
		var packet = peer.get_packet()
		if packet != null:
			var dataString = packet.get_string_from_utf8()
			var data = JSON.parse_string(dataString)
			if data.message == Message.id:
				myId = data.id
				connected(myId)
			if data.message == Message.userConnected:
				print("user connected " + str(myId) + " " + str(data.id))
				createPeer(data.id)
			if data.message == Message.switchHost:
				print("Switch Host")
				switchHost(data.host, data.players)
			if data.message == Message.error:
				print("Error " + data.error)
			if data.message == Message.lobby:
				lobbyValue = data.lobbyValue
				hostId = data.host
				var players = JSON.parse_string(data.players) 
				print(data.lobbyValue)
				lobby.showLobby(data.lobbyValue, hostId == myId)
				lobby.showPlayers(getPlayerNames(players))
			if data.message == Message.candidate:
				if rtcPeer.has_peer(data.orgPeer):
					print("Got Candidate: " + str(data.orgPeer) + " my id is " + str(myId))
					rtcPeer.get_peer(data.orgPeer).connection.add_ice_candidate(data.mid,data.index,data.sdp)
			if data.message == Message.offer:
				print("received offer")
				if rtcPeer.has_peer(data.orgPeer):
					rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("offer", data.data)
			if data.message == Message.answer:
				if rtcPeer.has_peer(data.orgPeer):
					rtcPeer.get_peer(data.orgPeer).connection.set_remote_description("answer", data.data)
			if data.message == Message.candidate:
				if rtcPeer.has_peer(data.orgPeer):
					print("Got Candidate: " + str(data.orgPeer) + " my id is " + str(myId))
					rtcPeer.get_peer(data.orgPeer).connection.add_ice_candidate(data.mid,data.index,data.sdp)
	pass
	
func connected(id):
	rtcPeer.create_mesh(id)
	multiplayer.multiplayer_peer = rtcPeer
	
func switchHost(id, players):
	var peers = rtcPeer.get_peers()
	for peerID in peers:
		rtcPeer.remove_peer(peerID)
		
	hostId = id
	var playerObjs = JSON.parse_string(players)
	lobby.showPlayers(getPlayerNames(playerObjs))
	for playerId in playerObjs.keys():
		print(playerId)
		createPeer(int(playerId))
	
	
func createPeer(id):
	if id != self.myId:
		var p : WebRTCPeerConnection = WebRTCPeerConnection.new()
		p.initialize({
			"iceServers" : [{ "urls": ["stun:stun.l.google.com:19302"] }]
		})
		print("binding id " + str(id) + " my id is " + str(self.myId))
		
		p.session_description_created.connect(self.offerCreated.bind(id))
		p.ice_candidate_created.connect(self.iceCandidateCreated.bind(id))
		print("added peer: " + str(p) + " I am " + str(myId))
		rtcPeer.add_peer(p, id)
		
		if id < rtcPeer.get_unique_id():
			print("not host, create offer")
			p.create_offer()
	pass
	
func offerCreated(type, data, id):
	print("create offer")
	print("type: " + type)
	if !rtcPeer.has_peer(id):
		return
	rtcPeer.get_peer(id).connection.set_local_description(type, data)
	
	if type == "offer":
		sendOffer(id, data)
	else:
		sendAnswer(id, data)
	pass
	
func sendOffer(id, data):
	var message = {
		"peer" : id, 
		"orgPeer" : self.myId,
		"message" : Message.offer,
		"data" : data,
		"Lobby" : lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	pass
func sendAnswer(id, data):
	var message = {
		"peer" : id, 
		"orgPeer" : self.myId,
		"message" : Message.answer,
		"data" : data,
		"Lobby" : lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	pass
func iceCandidateCreated(midName, indexName, sdpName, id):
	print("iceCandidate")
	var message = {
		"peer" : id, 
		"orgPeer" : self.myId,
		"message" : Message.candidate,
		"mid" : midName,
		"index" : indexName,
		"sdp" : sdpName,
		"Lobby" : lobbyValue
	}
	peer.put_packet(JSON.stringify(message).to_utf8_buffer())
	pass
	
func connectToServer(ip):
	peer.create_client(ip)
	print("client started")
	pass


@rpc("any_peer")
func ping():
	print("ping from " + str(multiplayer.get_remote_sender_id()) + " I am " + str(myId) + " btw")
	pass

func getPlayerNames(players):
	var playerNames : Array = []
	for p in players:
		playerNames.append(players[p].name)
	return playerNames


func _on_lobby_create_lobby(playerName):
	var message = {
		"id" : myId,
		"message" : Message.lobby,
		"lobbyValue" : "",
		"name" : playerName
	}
	var messageBytes = JSON.stringify(message).to_utf8_buffer()
	peer.put_packet(messageBytes)
	pass # Replace with function body.


func _on_lobby_join_lobby(playerName, lobbyId):
	var message = {
		"id" : myId,
		"message" : Message.lobby,
		"lobbyValue" : lobbyId,
		"name" : playerName
	}
	var messageBytes = JSON.stringify(message).to_utf8_buffer()
	peer.put_packet(messageBytes)
	pass # Replace with function body.
