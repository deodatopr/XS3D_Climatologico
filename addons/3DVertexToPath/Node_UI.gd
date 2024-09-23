extends EditorInspectorPlugin

# VARIABLES  - - - - - - - - - -  - - - - - - - - - - 
var UIheader = preload('res://addons/3DVertexToPath/UI_Header.tscn')
var window : Window
var objectNode
 #FUNCTIONS  - - - - - - - - - -  - - - - - - - - - - 
func _can_handle(object):
	objectNode = object as VertexToPath
	return object is VertexToPath

func _parse_begin(object):
	#add_custom_control(UIheader.instantiate())
	pass

func _parse_category(object, category):
	#print_debug(category)
	match category:
		"Node_Tool.gd":
			add_custom_control(UIheader.instantiate())

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	objectNode = object
	match name:
		"fileLocation":
			#Load File
			var loadFileBtn = Button.new()
			loadFileBtn.text = "Load File"
			loadFileBtn.connect("button_down",ShowFileDialog)
			add_property_editor("fileLocation",loadFileBtn, true)
			
			#region Separator
			var separator = HSeparator.new()
			separator.custom_minimum_size.y = 20
			add_property_editor("fileLocation",separator, true)
			#endregion
			
			#Add Points
			var addPntsBtn = Button.new()
			addPntsBtn.text = "Add Points"
			addPntsBtn.connect("button_down",object.ToolVertexToPath_Add)
			add_property_editor("fileLocation",addPntsBtn, true)
			
			#region Separator
			var separator2 = HSeparator.new()
			separator2.custom_minimum_size.y = 20
			add_property_editor("fileLocation",separator2, true)
			#endregion
			
			#Clear Points
			var clearPntsBtn = Button.new()
			clearPntsBtn.text = "Clear Points"
			clearPntsBtn.connect("button_down",object.ToolVertexToPath_Clear)
			add_property_editor("fileLocation",clearPntsBtn, true)
			
			#region Separator
			var separator3 = HSeparator.new()
			separator3.custom_minimum_size.y = 20
			add_property_editor("fileLocation",separator3, true)
			#endregion


func ShowFileDialog():
	if window != null:
		window.grab_focus()
		
	window = EditorFileDialog.new()
	window.access = EditorFileDialog.ACCESS_FILESYSTEM
	window.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	window.size = Vector2i(800, 500)

	EditorInterface.popup_dialog_centered(window)

	window.about_to_popup
	window.connect("file_selected",LoadFilePath)

func LoadFilePath(path: String):
	objectNode.fileLocation = path
