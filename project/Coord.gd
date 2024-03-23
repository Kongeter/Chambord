extends Node
class_name Coord

var xCoord : int
var yCoord : int

func _init(x_val, y_val) -> void:
	xCoord = x_val
	yCoord = y_val

func equals(x,y) -> bool:
	return (x==xCoord and y==yCoord)
