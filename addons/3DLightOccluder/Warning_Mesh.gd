@tool

extends Node3D

func _get_configuration_warnings() -> PackedStringArray:
	if get_child_count() == 0:
		return ['This node has no parented a Light']
	return []
