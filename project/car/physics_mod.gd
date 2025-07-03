class_name PhysicsMod
extends Resource

@export var friction := 0.9 :
	get():
		return _merge_property("friction", friction)
@export var drag := 0.001 :
	get():
		return _merge_property("drag", drag)
@export var mass := 1.0 :
	get():
		return _merge_property("mass", mass)
@export var bounciness := 1.0 :
	get():
		return _merge_property("bounciness", bounciness)

var _merged_mods : Array[PhysicsMod] = []


func _merge_property(property: String, value: float) -> float:
	for mod in _merged_mods:
		value *= mod.get(property)
	return value


func merge_with(mod: PhysicsMod) -> void:
	_merged_mods.append(mod)


func unmerge(mod: PhysicsMod) -> void:
	_merged_mods.erase(mod)
