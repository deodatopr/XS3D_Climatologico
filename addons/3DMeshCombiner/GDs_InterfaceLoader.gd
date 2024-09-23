extends EditorInspectorPlugin

var interface = preload('res://addons/3DMeshCombiner/MeshCombinerInspectorUI.tscn')

var btnClear:Button
var btnCombine:Button

func _can_handle(object):
	return object is MshCmbnr

func _parse_category(object, category):
	if category == 'GDs_CombinerNode.gd':
		add_custom_control(interface.instantiate())

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "deleteOriginalMshsOnPlay":
		
		btnCombine = Button.new()
		btnCombine.text = "COMBINE"
		btnCombine.connect("button_down",object._on_btn_combine_pressed)
		btnCombine.connect("button_down",OnCombine)
		add_property_editor("deleteOriginalMshsOnPlay",btnCombine,true)
		
		btnClear = Button.new()
		btnClear.text = "CLEAR"
		btnClear.connect("button_down",object.OnBtnCleanPressed)
		btnClear.connect("button_down",OnClear)
		add_property_editor("deleteOriginalMshsOnPlay",btnClear,true)
		
		if object.mesh: OnCombine()
		else: OnClear()

func OnCombine():
	btnClear.disabled = false
	btnCombine.disabled = true

func OnClear():
	btnClear.disabled = true
	btnCombine.disabled = false
