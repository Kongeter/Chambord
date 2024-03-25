extends Control

signal joinLobby(playerName, lobbyId)
signal createLobby(playerName)

var playerUI = preload("res://nodes/player_ui.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$LobbySelect.visible = true

func showLobby(lobbyId, amHost):
	$LobbySelect.visible = false
	$LobbyMenu.visible = true
	$LobbyMenu/LobbyId.text = lobbyId
	$LobbyMenu/StartGame.visible = amHost

func showPlayers(players):
	if $LobbyMenu/HBoxContainer.get_child_count() > 0:
		for c in $LobbyMenu/HBoxContainer.get_children():
			$LobbyMenu/HBoxContainer.remove_child(c)
	
	for player in players:
		var playerInst = playerUI.instantiate()
		playerInst.get_node("Name").text = player
		$LobbyMenu/HBoxContainer.add_child(playerInst)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_create_lobby_pressed():
	createLobby.emit($LobbySelect/Name.text)
	pass # Replace with function body.


func _on_join_lobby_pressed():
	joinLobby.emit($LobbySelect/Name.text,$LobbySelect/LineEdit.text)
	pass # Replace with function body.



func _on_lobby_id_pressed():
	DisplayServer.clipboard_set($LobbyMenu/LobbyId.text)
	pass # Replace with function body.
