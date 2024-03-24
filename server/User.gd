extends RefCounted
class_name User

var Id: int
var Lobby: String

func _init(id, lobby):
	Id = id
	Lobby = lobby
