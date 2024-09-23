extends EditorInspectorPlugin

# VARIABLES  - - - - - - - - - -  - - - - - - - - - - 
var headerTop = preload('res://addons/3DLightOccluder/UI_Header_Top.tscn')
var headerBottom = preload('res://addons/3DLightOccluder/UI_Header_Bottom.tscn')


# FUNCTIONS  - - - - - - - - - -  - - - - - - - - - - 
func _can_handle(object):
	return object is Light_Occluder

func _parse_begin(object):
	add_custom_control(headerTop.instantiate())
	
	
#Empujar todas las propiedades hasta abajo, antes de la propiedad "Bottom"
func _parse_category(object, category):
	if category == "Node":
		add_custom_control(headerBottom.instantiate())
