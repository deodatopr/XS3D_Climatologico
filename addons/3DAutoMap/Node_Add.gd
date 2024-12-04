@tool
extends EditorPlugin

var TextureBatcher
const QUICK_TEXTURE_BATHCER = preload('res://addons/3DAutoMap/UI_Tool.tscn')

func _enter_tree():
	TextureBatcher = QUICK_TEXTURE_BATHCER.instantiate()
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, TextureBatcher)


func _exit_tree():
	remove_control_from_docks(TextureBatcher)
	
	TextureBatcher.queue_free()
