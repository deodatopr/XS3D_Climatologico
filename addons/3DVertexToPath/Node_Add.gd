@tool
extends EditorPlugin
var plugin = preload('Node_UI.gd')

func _enter_tree() -> void:
	plugin = plugin.new()
	add_inspector_plugin(plugin)
	add_custom_type( "VertexToPath", "Path3D", preload("Node_Tool.gd"), preload('res://addons/3DVertexToPath/Icon_Node.png') )
	
	
func _exit_tree() -> void:
	remove_inspector_plugin(plugin)
	remove_custom_type("VertexToPath")
