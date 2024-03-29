extends Node
class_name Helper

#returns the index of fist Object in "array" which fulfills Funktion "f"
static func functionFindFirstIndex(a: Array, f: Callable) -> int:
	for i in range(a.size()):
		if f.call(a[i]):
			return i
	return -1

#returns the fist Object in "array" which fulfills Funktion "f"
static func functionFindFirstObject(array: Array, f: Callable):
	for i in range(array.size()):
		if f.call(array[i]):
			return array[i]
	return null

#does "array" have any element that fulfills Funktion "f"?
static func arrayHas(array: Array, f: Callable) -> bool:
	for element in array:
		if f.call(element):
			return true
	return false

#flattens "array" by one
static func flatten(array: Array):
	var result = []
	for subArray in array:
		for element in subArray:
			result.append(element)
	return result
	
static func withoutDuplicates(array: Array) -> Array:
	var res: Array = []
	for element in array:
		if not res.has(element):
			res.append(element)
	return res

static func getIndexFromLetter(s: String):
	var index;
	match s:
		"A":
			index=0;
		"B":
			index=1;
		"C":
			index=2;
		"D":
			index=3;
		"E":
			index=4;
		"F":
			index=5;
	return index

static func getChildrenWithGroup(node : Node, group: String):
	var objs = []
	for child in node.get_children():
		if child.is_in_group(group):
			objs.append(child)
		var childObjs = getChildrenWithGroup(child, group)
		objs.append_array(childObjs)
	return objs
		
		
	
