extends Node
class_name CardTypesInitiated

#connectGroupsStreets, connectGroupsCitys, connectGroupsGrass, hasChurch, 
#CardType.new()
var cards = [
	CardType.new([[2]],[],[[0,1,2,3,4,5,6,7]],true), #A
	CardType.new([],[],[[0,1,2,3,4,5,6,7]],true), #B
	CardType.new([],[[0,1,2,3]],[],false), #C
	CardType.new([[0,2]],[[1]],[[0,5,6,7],[1,4]],false), #D
	CardType.new([],[[0]],[[2,3,4,5,6,7]],false),#E
	CardType.new([],[[1,3]],[[0,1],[4,5]],false),#F
]

