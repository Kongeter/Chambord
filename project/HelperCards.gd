extends Node
class_name HelperCards

static func doesCardExistAt(placedCards,x,y):
	return Helper.arrayHas(placedCards, func(c): return (c.xCoord == x and c.yCoord == y))

static func getCardAt(placedCards,x,y):
	return Helper.functionFindFirstObject(placedCards, func(c): return (c.xCoord == x and c.yCoord == y))

#calculates the type of Edge (0=grass, 1=street, 2=city) from any given card
static func calcEdgeType(cardType, rotation):
	var Defintions = CardTypes.cards;
	var res = []
	var index = Helper.getIndexFromLetter(cardType);
	var streetsFlattend = Helper.flatten(Defintions[index].connectGroupsStreets)
	var cityFlattend = Helper.flatten(Defintions[index].connectGroupsCitys)
	for side: int in range(0,4):
		var sideRotated = (side + 3 * rotation) % 4 
		if streetsFlattend.has(sideRotated):
			res.append(1)
		elif cityFlattend.has(sideRotated):
			res.append(2)
		else:
			res.append(0)
	return res
	
#returns an array of all places next to already placed Cards (without paying attention to matching edges)
static func getLegitPlaces(placedCards):
	var possiblePlaces = []
	for card: Card in placedCards:
		var directions = [[1, 0], [-1, 0], [0, 1], [0, -1]]
		for dir in directions:
			var newX= card.xCoord+dir[0]
			var newY= card.yCoord+dir[1]
			if !Helper.arrayHas(possiblePlaces, func(c): return c.equals(newX, newY)) and !Helper.arrayHas(placedCards, func(c): return (c.xCoord == newX and c.yCoord == newY)):
				possiblePlaces.append(Coord.new(newX,newY))
	return possiblePlaces

static func getValidPositions(cardType, placedCards: Array):
	#TODO write this more efficently by getting the edges next to each position just once
	var Defintions = CardTypesInitiated.new()
	var possiblePositions = getLegitPlaces(placedCards)
	var validPositions = []
	for position:Coord in possiblePositions:
		for rotation: int in range(0,4):
			var newEdges = calcEdgeType(cardType, rotation)
			if HelperCards.doesCardExistAt(placedCards, position.xCoord+1, position.yCoord): #oben
				var neighbour:Card = HelperCards.getCardAt(placedCards, position.xCoord+1, position.yCoord)
				if newEdges[1] != calcEdgeType(neighbour.type, neighbour.rotation)[3]:
					continue
			if HelperCards.doesCardExistAt(placedCards, position.xCoord-1, position.yCoord): #oben
				var neighbour:Card = HelperCards.getCardAt(placedCards, position.xCoord-1, position.yCoord)
				if newEdges[3] != calcEdgeType(neighbour.type, neighbour.rotation)[1]:
					continue
			if HelperCards.doesCardExistAt(placedCards, position.xCoord, position.yCoord+1): #oben
				var neighbour:Card = HelperCards.getCardAt(placedCards, position.xCoord, position.yCoord+1)
				if newEdges[0] != calcEdgeType(neighbour.type, neighbour.rotation)[2]:
					continue
			if HelperCards.doesCardExistAt(placedCards, position.xCoord, position.yCoord-1): #oben
				var neighbour:Card = HelperCards.getCardAt(placedCards, position.xCoord, position.yCoord-1)
				if newEdges[2] != calcEdgeType(neighbour.type, neighbour.rotation)[0]:
					continue
			
			validPositions.append([position.xCoord,position.yCoord, rotation])
	return validPositions
