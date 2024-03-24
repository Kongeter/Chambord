extends Button

@rpc("any_peer","call_local")
func moveRight():
	var sender_id = multiplayer.get_remote_sender_id()
	print("huh" + str(sender_id))
	position.x = position.x + 5*(-1 ** sender_id)


func _on_pressed():
	moveRight.rpc()
