extends Node


var material = preload("res://materials/dots.tres")
var GameField
var GameController
var nodesThatWhereChanged = []
func _ready():
	GameController = get_node("%GameController")
	GameField = get_node("%GameField")

func _on_ray_cast_3d_hover_group(type, group, coords):
	var areaGroup = GameController.getArea(coords.x, coords.y, group, type)
	for areaNode in areaGroup:
		markGroup(Vector2(areaNode.x, areaNode.y), areaNode.group, type)
	#temporary, replace with groups later
	

func markGroup(coords, group, type):
	var tile : Node = GameField.placedTileNodes[coords]
	var subNode
	#print(type)
	match type:
		AreaType.GRASS:
			subNode = tile.get_node("Grass/"+str(group))
		AreaType.CITY:
			subNode = tile.get_node("City/"+str(group))
		AreaType.STREET:
			subNode = tile.get_node("Street/"+str(group))
		AreaType.CHURCH:
			subNode = tile.get_node("Church")
	if subNode == null:
		return 
	var children = Helper.getChildrenWithGroup(subNode,"Material")
	#print(children.size())
	for c : MeshInstance3D in children:
		c.material_overlay = material
		nodesThatWhereChanged.append(c)
	pass
	

func _on_ray_cast_3d_unhover_group(type, group, round):
	#print("test")
	for n in nodesThatWhereChanged:
		n.material_overlay = null
	nodesThatWhereChanged = []
	pass # Replace with function body.
	pass
