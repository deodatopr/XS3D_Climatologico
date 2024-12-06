@tool
extends HBoxContainer
class_name ShaderParameter

@export var ParameterName : LineEdit
@export var TextureSuff : LineEdit
@export var option_button : OptionButton

var AutoMapShader : AutoMapShader
var fileSystemSelPath :PackedStringArray

func _on_remove_parameter_pressed():
	var index : int = AutoMapShader.ShaderParameters.find(self)
	AutoMapShader.ShaderParameters.remove_at(index)
	self.queue_free()


func _on_option_button_pressed():
	fileSystemSelPath.clear()
	fileSystemSelPath = EditorInterface.get_selected_paths()
	var MaterialsSelected : int
	var Parameters : Array
	
	for path in fileSystemSelPath:
		if path.get_extension() == "tres":
			var shaderMaterial : ShaderMaterial = ResourceLoader.load(path)
			if shaderMaterial is ShaderMaterial:
				if shaderMaterial.shader:
					var shader = shaderMaterial.shader
					if shader is VisualShader:
						var type = VisualShader.TYPE_FRAGMENT
						for id in shader.get_node_list(type):
							var node = shader.get_node(type, id)
							if node is VisualShaderNodeTexture2DParameter:
								var param : VisualShaderNodeTexture2DParameter
								param = node
								Parameters.append(param.parameter_name)
	
	option_button.clear()
	option_button.add_separator("Parameter")
	option_button.selected = 0
	
	var id : int = 1
	var sameNames : bool = false
	for option in Parameters:
		for i in option_button.item_count:
			if option_button.get_item_text(i) == option:
				sameNames = true
				break
				
		if sameNames:
			sameNames = false
			continue
			
		option_button.add_item(option, id)
		id += 1
	
