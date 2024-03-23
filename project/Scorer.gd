extends Node
class_name Scorer

#bekommt Koordinate von Karte + Richtung (0 oben dann im Uhrzeigersinn)
#Gibt dann Array zurück von: (Koordinate, Richtung) die man durch die Straße erreichen kann (wobei richtung dann die richtung ist mit der man bei der neuen Karte ankommt)
static func getStreetOrCityConnection(card: Card, direction: int, street: bool) ->Array:
	var groups
	if street:
		groups = CardDefintions.connectGroupsStreets[card.type]
	else: 
		groups = CardDefintions.connectGroupsCitys[card.type]
		
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
	
	var debugCoords
	
	
	return [result]

