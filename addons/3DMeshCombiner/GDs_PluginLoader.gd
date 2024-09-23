@tool
extends EditorPlugin

var plugin = preload('res://addons/3DMeshCombiner/GDs_InterfaceLoader.gd')
func _enter_tree():
	# Initialization of the plugin goes here.
	plugin = plugin.new()
	add_inspector_plugin(plugin)
	add_custom_type("Mesh Combiner", "MeshInstance3D",preload('res://addons/3DMeshCombiner/GDs_CombinerNode.gd'),preload('res://addons/3DMeshCombiner/Ico_Merge.png'))

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("Mesh Combiner")
	remove_inspector_plugin(plugin)
