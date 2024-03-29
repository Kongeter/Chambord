extends Node


var material = preload("res://materials/dots.tres")
var GameField
var nodesThatWhereChanged = []
func _ready():
	GameField = get_node("%GameField")

func _on_ray_cast_3d_hover_group(type, group, round):
	#temporary, replace with groups later
	var curTile = Vector2(GameField.xClicked,GameField.yClicked)
	var tile : Node = GameField.placedTileNodes[curTile]
	var subNode
	print(type)
	match type:
		0:
			subNode = tile.get_node("Grass/"+str(group))
		1:
			subNode = tile.get_node("City/"+str(group))
		2:
			subNode = tile.get_node("Street/"+str(group))
		3:
			subNode = tile.get_node("Church")
	if subNode == null:
		return 
	var children = Helper.getChildrenWithGroup(subNode,"Material")
	print(children.size())
	for c : MeshInstance3D in children:
		c.material_overlay = material
		nodesThatWhereChanged.append(c)


func _on_ray_cast_3d_unhover_group(type, group, round):
	print("test")
	for n in nodesThatWhereChanged:
		n.material_overlay = null
	nodesThatWhereChanged = []
	pass # Replace with function body.
	pass
