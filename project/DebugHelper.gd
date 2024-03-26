extends Node
class_name DebugHelper

static func showDirection(x: int) -> void:
	match x:
		0:
			print("↓")
		1:
			print("←")
		2:
			print("↑")
		3:
			print("→")

static func showBoard(cards: Array, xMax, yMax) -> void:
	var divider = "-"
	for i in range(xMax):
		divider += "---" 
	for y in range (yMax):
		print(divider)
		var stringTop = "|"
		var stringBottom = "|"
		for x in range(xMax):
			var index = Helper.functionFindFirstIndex(cards, (func(c:Card): return (c.xCoord == x and c.yCoord == y)))
			if index == -1:
				stringTop += str(x)+str(y)
				stringBottom += "xx"
			else:
				var card = Helper.functionFindFirstObject(cards, (func(c:Card): return (c.xCoord == x and c.yCoord == y)))
				stringTop += str(x)+str(y)
				stringBottom += str(card.type)+str(card.rotation)
			stringTop += "|"
			stringBottom += "|"
		print(stringTop)
		print(stringBottom)
	print(divider)

static func showCoord(coords: Array, xMax, yMax) -> void:
	var divider = "-"
	for i in range(xMax):
		divider += "---" 
	for y in range (yMax):
		print(divider)
		var stringTop = "|"
		var stringBottom = "|"
		for x in range(xMax):
			var index = Helper.functionFindFirstIndex(coords, func(c:Coord): return c.equals(x,y))
			if index == -1:
				stringTop += "xx"
				stringBottom += "xx"
			else:
				stringTop += "0"+str(index)
				stringBottom += "0"+str(index)
			stringTop += "|"
			stringBottom += "|"
		print(stringTop)
		print(stringBottom)
	print(divider)

static func doubleCards(cards: Array)-> bool:
	return false
