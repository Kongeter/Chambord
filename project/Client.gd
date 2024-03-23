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
var myId : int = 0
var rtcPeer : WebRTCMultiplayerPeer = WebRTCMultiplayerPeer.new()
var hostId: int
var lobbyValue: String = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(RTCServerConnected)
	multiplayer.peer_connected.connect(RTCPeerConnected)
	multiplayer.peer_disconnected.connect(RTCPeerDisconnected)
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
			if data.message == Message.lobby:
				lobbyValue = data.lobbyValue
				hostId = data.host
				print(data.players)
				print(data.lobbyValue)
				$LineEdit.text = data.lobbyValue
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
	pass
	
func connected(id):
	rtcPeer.create_mesh(id)
	multiplayer.multiplayer_peer = rtcPeer
	
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
	peer.create_client("ws://104.248.47.16:8915")
	print("client started")
	pass



func _on_start_client_pressed():
	connectToServer("")
	pass # Replace with function body.


func _on_send_packet_pressed():
	ping.rpc()
	pass
	
@rpc("any_peer")
func ping():
	print("ping from " + str(multiplayer.get_remote_sender_id()) + " I am " + str(myId) + " btw")
	pass


func _on_join_lobby_pressed():
	var message = {
		"id" : myId,
		"message" : Message.lobby,
		"lobbyValue" : $LineEdit.text,
		"name" : "PlayerName"
	}
	var messageBytes = JSON.stringify(message).to_utf8_buffer()
	peer.put_packet(messageBytes)
	pass # Replace with function body.
