extends Node
class_name Helper

static func functionFindFirstIndex(a: Array, f: Callable) -> int:
	for i in range(a.size()):
		if f.call(a[i]):
			return i
	return -1

static func functionFindFirstObject(a: Array, f: Callable) -> int:
	for i in range(a.size()):
		if f.call(a[i]):
			return a[i]
	return -1

static func arrayHas(array: Array, f: Callable) -> bool:
	for element in array:
		if f.call(element):
			return true
	return false
