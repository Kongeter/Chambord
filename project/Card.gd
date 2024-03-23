extends Node
class_name Card

var xCoord : int
var yCoord : int
var type : int
var rotation : int
var figureType : int
var figurePos : int

func _init(x_val, y_val, type_val: int, rotation_val: int,  figureType_val: int, figurePos_val: int) -> void:
	rotation = rotation_val
	type = type_val
	figureType = figureType_val
	figurePos = figurePos_val
	xCoord = x_val
	yCoord = y_val

func printCardInfo() -> void:
	print("coord: [", xCoord,",", yCoord,"]   rota: ", rotation,"   type: ", type)
	
func printCardInfoWithFigures() -> void:
	print("coord: [", xCoord,",", yCoord,"]   rota: ", rotation,"   type: ", type)
	print("Figures:", figureType)
	print("FigurePos:", figurePos)
