extends Node
class_name CardType
var connectGroupsStreets
var connectGroupsCitys
var connectGroupsGrass
var hasChurch

func _init(connectGroupsStreets_, connectGroupsCitys_, connectGroupsGrass_, hasChurch_: bool ) -> void:
	connectGroupsStreets = connectGroupsStreets_
	connectGroupsCitys = connectGroupsCitys_
	connectGroupsGrass = connectGroupsGrass_
	hasChurch = hasChurch_

