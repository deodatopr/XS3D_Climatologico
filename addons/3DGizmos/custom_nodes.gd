@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type( "Gizmo Arrow", "MeshInstance3D", preload("Node_Arrow.gd"), preload("Icon.png") )
	add_custom_type( "Gizmo Capsule", "MeshInstance3D", preload("Node_Capsule.gd"), preload("Icon.png") )
	add_custom_type( "Gizmo Cylinder", "MeshInstance3D", preload("Node_Cylinder.gd"), preload("Icon.png") )
	add_custom_type( "Gizmo Box", "MeshInstance3D", preload("Node_Box.gd"), preload("Icon.png") )
	add_custom_type( "Gizmo Sphere", "MeshInstance3D", preload("Node_Sphere.gd"), preload("Icon.png") )
	add_custom_type( "Gizmo IcoSphere", "MeshInstance3D", preload("Node_Icosphere.gd"), preload("Icon.png") )
	add_custom_type( "Gizmo Line", "MeshInstance3D", preload("Node_Line.gd"), preload("Icon.png") )
	#add_autoload_singleton('Gizmos3D','scriptname.gd')
	
	
func _exit_tree() -> void:
	remove_custom_type("Gizmo Arrow")
	remove_custom_type("Gizmo Capsule")
	remove_custom_type("Gizmo Cylinder")
	remove_custom_type("Gizmo Box")
	remove_custom_type("Gizmo Sphere")
	remove_custom_type("Gizmo IcoSphere")
	#remove_autoload_singleton('Gizmos3D')
