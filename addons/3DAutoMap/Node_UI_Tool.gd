@tool
extends Control
class_name AutoMap

@export var TabOption : TabContainer
@export var AutoMapStandard : AutoMapStandard
@export var AutoMapShader : AutoMapShader

var window : Window
var fileSystemSelPath :PackedStringArray

func ComfirmationWindow(NameTexture : LineEdit, NumDigits : OptionButton, Extension : OptionButton)->Window:
	fileSystemSelPath.clear()
	fileSystemSelPath = EditorInterface.get_selected_paths()
	var MaterialsSelected : int
	
	for path in fileSystemSelPath:
		if path.get_extension() == "tres":
			MaterialsSelected += 1
			
	if NameTexture.text.is_empty():
		WarningMessage("Type the name of the texture")
		return null
		
	if NumDigits.get_selected_id() == 0:
		WarningMessage("Select the number of digits")
		return null
		
	if Extension.get_selected_id() == 0:
		WarningMessage("Select the extension")
		return null
			
	if MaterialsSelected == 0:
		WarningMessage("Select at least 1 Material")
		return null
	
	if window != null:
		window.grab_focus()
		
	var dialog = Label.new()
	dialog.text = "Selected " + str(MaterialsSelected) + " Material(s)\n Do you want to apply?"
	dialog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialog.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	window = ConfirmationDialog.new()
	window.size = Vector2i(200, 100)
	
	EditorInterface.popup_dialog_centered(window)
	
	window.add_child(dialog)
	window.about_to_popup
	
	return window

func WarningMessage(Message : String):
	if window != null:
		window.grab_focus()
		
	var dialog = Label.new()
	dialog.text = Message
	dialog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialog.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	window = AcceptDialog.new()
	window.size = Vector2i(200, 100)
	
	EditorInterface.popup_dialog_centered(window)
	
	window.add_child(dialog)
	window.about_to_popup

func _on_name_texture_text_changed(new_text):
	if TabOption.current_tab == 0:
		if new_text == "":
			AutoMapStandard.ExampleName.text = "Name_Texture"
		else:
			AutoMapStandard.ExampleName.text = new_text
	else:
		if new_text == "":
			AutoMapShader.ExampleName.text = "Name_Texture"
		else:
			AutoMapShader.ExampleName.text = new_text


func _on_digits_number_item_selected(index):
	if TabOption.current_tab == 0:
		if index == 1:
			AutoMapStandard.ExampleDigits.text = ""
		elif index == 2:
			AutoMapStandard.ExampleDigits.text = "01"
		elif index == 3:
			AutoMapStandard.ExampleDigits.text = "001"
	else:
		if index == 1:
			AutoMapShader.ExampleDigits.text = ""
		elif index == 2:
			AutoMapShader.ExampleDigits.text = "01"
		elif index == 3:
			AutoMapShader.ExampleDigits.text = "001"


func _on_extension_item_selected(index):
	if TabOption.current_tab == 0:
		AutoMapStandard.ExampleExtension.text = "." + AutoMapStandard.Extension.get_item_text(index).to_lower()
	else:
		AutoMapShader.ExampleExtension.text = "." + AutoMapShader.Extension.get_item_text(index).to_lower()


func _on_reset_standard_pressed():
	if TabOption.current_tab == 0:
		AutoMapStandard.NameTexture.text = ""
		AutoMapStandard.NumDigits.selected = 0
		AutoMapStandard.Extension.selected = 0
		
		AutoMapStandard.ExampleName.text = "Name_Texture"
		AutoMapStandard.ExampleDigits.text = "###"
		AutoMapStandard.ExampleExtension.text = ".EXT"
		
		AutoMapStandard._on_reset_standard_pressed()
	else:
		AutoMapShader.NameTexture.text = ""
		AutoMapShader.NumDigits.selected = 0
		AutoMapShader.Extension.selected = 0
		
		AutoMapShader.ExampleName.text = "Name_Texture"
		AutoMapShader.ExampleDigits.text = "###"
		AutoMapShader.ExampleExtension.text = ".EXT"
		
		AutoMapShader._on_reset_standard_pressed()
