extends Node
class_name Scorer



#bekommt Koordinate von Karte + Richtung (0 oben dann im Uhrzeigersinn)
#Gibt dann Array zurück von: (Koordinate, Richtung) die man durch die Straße erreichen kann (wobei richtung dann die richtung ist mit der man bei der neuen Karte ankommt)
static func getStreetOrCityConnection(card: Card, direction: int, street: bool) ->Array:
	var Defintions = CardTypesInitiated.new()
	var groups
	if street:
		groups = Defintions.cards[card.type].connectGroupsStreets
	else: 
		groups = Defintions.cards[card.type].connectGroupsCitys
		
	var groupsRotated = groups.map(func(x): return x.map(func(y): return (y + card.rotation) % 4))
	var group = groupsRotated.filter(func(x): return x.has(direction))[0];

	if group.size() <= 1:
		return []
	
	var groupF = group.filter(func(x): return x!=direction) #enthält die richtige Connectiongruppe ohne die Richtung aus der wir kommen
	
	var result = []
	for x in groupF:#
		var xNew = card.xCoord 
		var yNew = card.yCoord 
		var directionNew = ( x + 2 ) % 4
		match x:
			0:
				yNew+=1
			1:
				xNew+=1
			2:
				yNew-=1
			3:
				xNew-=1
		result.append([xNew, yNew, directionNew])
	
	var debugCoords = [Coord.new(card.xCoord, card.yCoord), Coord.new(result[0][0], result[0][1])]
	DebugHelper.showCoord(debugCoords, 3,3)
	DebugHelper.showDirection(direction)
	DebugHelper.showDirection(result[0][2])
	return [result]

#bekommt Koordinate von Karte + Richtung (0 oben links, 1 oben rechts, dann im Uhrzeigersinn)
#Gibt dann Array zurück von: (Koordinate, Richtung) die man durch die Wiese erreichen kann (wobei richtung dann die richtung ist mit der man bei der neuen Karte ankommt)
static func getGrassConnection(card: Card, direction: int) ->Array:
	var Defintions = CardTypesInitiated.new()
	var groups = Defintions.cards[card.type].connectGroupsGrass
		
	var groupsRotated = groups.map(func(x): return x.map(func(y): return (y + card.rotation*2) % 8))
	
	var group = groupsRotated.filter(func(x): return x.has(direction))[0];

	if group.size() <= 1:
		return []
	
	var groupF = group.filter(func(x): return x!=direction) #enthält die richtige Connectiongruppe ohne die Richtung aus der wir kommen
	
	var result = []
	for x in groupF:
		var xNew = card.xCoord 
		var yNew = card.yCoord 
		var directionNew = ( x + 2 ) % 4 #TODO das anpassen für gras
		match x:
			0,1:
				yNew+=1
			2,3:
				xNew+=1
			4,5:
				yNew-=1
			6,7:
				xNew-=1
		result.append([xNew, yNew, directionNew])
	
	var debugCoords = [Coord.new(card.xCoord, card.yCoord), Coord.new(result[0][0], result[0][1])]
	DebugHelper.showCoord(debugCoords, 3,3)
	print("dir1: ", direction, "   dir2: ", result[0][2])
	return [result]



func moveScorer(newCard):
	#wenn stadt: stadt flood von da aus
	#wenn straße: straßen flood von da aus
	#schauen ob im umkreis Klosten -> dann schauen ob somit fertig
	pass
	
func endOfGameScorer():
	#alle spielsteine:
	#Wiese:
	pass




	
	
	
	
