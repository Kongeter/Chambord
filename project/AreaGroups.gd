extends Node
class_name AreaGroups
var Defintions:CardTypesInitiated = CardTypesInitiated.new()

var cityAreas = {}
var streetAreas = {}
var grassAreas = {}

var tileWhichAreaCity ={}
var tileWhichAreaStreet ={}
var tileWhichAreaGrass ={}

var currentCityAreaMax = 0
var currentStreetAreaMax = 0
var currentGrassAreaMax = 0

var currentCard:Card  #currentCard
var cCTypeIndex #currentCard Type Index

var neighborTop:Card
var neighborBottom:Card
var neighborLeft:Card
var neighborRight:Card

func addCard(newCard: Card, placedCards):
	currentCard = newCard
	cCTypeIndex= Helper.getIndexFromLetter(newCard.type);
	neighborTop = HelperCards.getCardAt(placedCards,currentCard.xCoord, currentCard.yCoord+1)
	neighborBottom = HelperCards.getCardAt(placedCards,currentCard.xCoord, currentCard.yCoord-1)
	neighborLeft = HelperCards.getCardAt(placedCards,currentCard.xCoord-1, currentCard.yCoord)
	neighborRight = HelperCards.getCardAt(placedCards,currentCard.xCoord+1, currentCard.yCoord)
	addCardCityOrStreetAreas(AreaType.CITY)
	addCardCityOrStreetAreas(AreaType.STREET)
	addCardCityOrStreetAreas(AreaType.GRASS)

	#print("-------------------------------------------------------------------------------------------------------------------------")
	#for i in range(currentCityAreaMax):
		#print(i , " cityArea: " , cityAreas[i].map(func(c): return str(c.x)+":"+str(c.y)+":"+str(c.group)+" | "))
	#for i in range(currentStreetAreaMax):
		#print(i , " streetArea: " , streetAreas[i].map(func(c): return str(c.x)+":"+str(c.y)+":"+str(c.group)+" | "))
	#for i in range(currentGrassAreaMax):
		#print(i , " grassArea: " , grassAreas[i].map(func(c): return str(c.x)+":"+str(c.y)+":"+str(c.group)+" | "))
	#
func addCardCityOrStreetAreas(areaType):
	var groups = getConnectGroupRotated(cCTypeIndex, areaType, currentCard.rotation)
	for groupIndex in range(groups.size()):
		var group = groups[groupIndex]
		var groupConnection = [] # gets filled with all Areas on other Tiles connected with the group
		var directions = [[neighborTop, 0, 2],[neighborRight, 1, 3],[neighborBottom, 2, 0],[neighborLeft, 3, 1]]
		if areaType == AreaType.GRASS: directions = [[neighborTop, 0, 5],[neighborTop, 1, 4],[neighborRight, 2, 7],[neighborRight, 3, 6],[neighborBottom, 4, 1],[neighborBottom, 5, 0],[neighborLeft, 6, 3],[neighborLeft, 7, 2]]
		for a in directions:
			if a[0] != null and group.has(a[1]):
				var neighborGroups = getConnectGroupRotated(Helper.getIndexFromLetter(a[0].type), areaType,a[0].rotation)
				var connectedNeighborGroups = Helper.functionFindFirstIndex(neighborGroups, func(g:Array): return g.has(a[2]))
				groupConnection.append(Vector3(a[0].xCoord,a[0].yCoord, connectedNeighborGroups))
		combineAreas(groupConnection, groupIndex, areaType)

func combineAreas(groupConnection, currentGroup, areaType):
	var dict1 
	var dict2 
	var maxIndex 
	match areaType:
		AreaType.CITY:
			dict1=cityAreas
			dict2=tileWhichAreaCity
			maxIndex =currentCityAreaMax
		AreaType.STREET:
			dict1=streetAreas
			dict2=tileWhichAreaStreet
			maxIndex= currentStreetAreaMax
		AreaType.GRASS:
			dict1=grassAreas
			dict2=tileWhichAreaGrass
			maxIndex= currentGrassAreaMax

	if groupConnection.size() == 0:
		dict1[maxIndex] = [newAreaNode(currentGroup, currentCard)];
		dict2[Vector3(currentCard.xCoord, currentCard.yCoord, currentGroup)] = maxIndex
		match areaType:
			AreaType.CITY: currentCityAreaMax += 1
			AreaType.STREET: currentStreetAreaMax += 1
			AreaType.GRASS: currentGrassAreaMax += 1
	else:
		var groupIndexes = Helper.withoutDuplicates(groupConnection.map(func(n): return dict2[n]))
		var firstIndex = groupIndexes[0]
		var firstArea: Array = dict1[firstIndex]
		firstArea.append(newAreaNode(currentGroup, currentCard))
		dict2[Vector3(currentCard.xCoord, currentCard.yCoord, currentGroup)] = groupIndexes[0]
		groupIndexes.remove_at(0)
		for i in groupIndexes:
			var toMergeArea = dict1[i]
			for node in toMergeArea:
				dict2[Vector3(node.x, node.y, node.group)] = firstIndex
			firstArea.append_array(toMergeArea)
			dict1[i] = []

func getConnectGroupRotated(index, type,rotation):
	match type:
		AreaType.CITY:
			return Defintions.cards[index].connectGroupsCitys.map(func(x): return x.map(func(y): return (y + rotation) % 4))
		AreaType.STREET:
			return Defintions.cards[index].connectGroupsStreets.map(func(x): return x.map(func(y): return (y + rotation) % 4))
		AreaType.GRASS:
			return Defintions.cards[index].connectGroupsGrass.map(func(x): return x.map(func(y): return (y + rotation*2) % 8))

func newAreaNode(group, card_):
	return AreaNode.new(card_.xCoord, card_.yCoord, group)
