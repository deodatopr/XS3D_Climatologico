@tool
extends HBoxContainer
class_name ShaderParameter

@export var ParameterName : LineEdit
@export var TextureSuff : LineEdit

var AutoMapShader : AutoMapShader

func _on_remove_parameter_pressed():
	var index : int = AutoMapShader.ShaderParameters.find(self)
	AutoMapShader.ShaderParameters.remove_at(index)
	self.queue_free()
