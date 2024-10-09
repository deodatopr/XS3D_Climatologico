@tool

# - - -
extends EditorPlugin
# - - -

# VARS'
var UI_Tool :PackedScene = preload('res://addons/3DAutoMaterial/UI_Tool.tscn')
var ui: Control

# FUNCS
func _enter_tree() -> void:
	ui = UI_Tool.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, ui)
	
func _exit_tree() -> void:
	remove_control_from_docks(ui)
