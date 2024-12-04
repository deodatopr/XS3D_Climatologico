@tool
extends Control
class_name AutoMapStandard

@export var NameTexture : LineEdit
@export var NumDigits : OptionButton
@export var Extension : OptionButton

@export var ExampleName : LineEdit
@export var ExampleDigits : LineEdit
@export var ExampleExtension : LineEdit

@export var BaseColor : CheckBox
@export var Roughness : CheckBox
@export var Metallic : CheckBox
@export var Normal : CheckBox
@export var Emission : CheckBox
@export var Occlusion : CheckBox

@export var SuffBC : LineEdit
@export var SuffR : LineEdit
@export var SuffM : LineEdit
@export var SuffN : LineEdit
@export var SuffE : LineEdit
@export var SuffO : LineEdit

@export var AutoMap : AutoMap

var window : Window
var Textures : Dictionary
var AppliedTextures : int = 0

func _on_apply_standard_pressed():
	if !BaseColor.button_pressed and !Roughness.button_pressed and !Metallic.button_pressed and !Normal.button_pressed and !Emission.button_pressed and !Occlusion.button_pressed:
		AutoMap.WarningMessage("Select at least one map connection")
		return
	
	window = AutoMap.ComfirmationWindow(NameTexture, NumDigits, Extension)
	
	if window != null:
		window.connect("confirmed",_applyTextures)
	
func _applyTextures():
	AppliedTextures = 0
	
	for path in AutoMap.fileSystemSelPath:
		if path.get_extension() == "tres":
			var resource = ResourceLoader.load(path)
			AutoAssingTextures(resource, path.get_file())
			
	if AppliedTextures == 0:
		AutoMap.WarningMessage("No textures were found with the strucutre of the name")

func AutoAssingTextures(MaterialFile : StandardMaterial3D, FileName : String):
	Textures.clear()

	var DigitText : String = ""
	if NumDigits.get_selected_id() > 1:
		DigitText = GetDigitsOfMaterial(FileName, NumDigits.get_selected_id())
	var NameStruct = NameTexture.text + DigitText
	FindTextures("res://", NameStruct)
	
	if BaseColor.button_pressed and Textures.has(SuffBC.text):
		MaterialFile.albedo_texture = Textures[SuffBC.text]
		AppliedTextures += 1
		
	if Roughness.button_pressed and Textures.has(SuffR.text):
		MaterialFile.roughness_texture = Textures[SuffR.text]
		AppliedTextures += 1
		
	if Metallic.button_pressed and Textures.has(SuffM.text):
		MaterialFile.metallic_texture = Textures[SuffM.text]
		AppliedTextures += 1
		
	if Normal.button_pressed and Textures.has(SuffN.text):
		MaterialFile.normal_enabled = true
		MaterialFile.normal_texture = Textures[SuffN.text]
		AppliedTextures += 1
		
	if Emission.button_pressed and Textures.has(SuffE.text):
		MaterialFile.emission_enabled = true
		MaterialFile.emission_texture = Textures[SuffE.text]
		AppliedTextures += 1
		
	if Occlusion.button_pressed and Textures.has(SuffO.text):
		MaterialFile.ao_enabled = true
		MaterialFile.ao_texture = Textures[SuffO.text]
		AppliedTextures += 1
	
func GetDigitsOfMaterial(MaterialName : String, NumUnits : int)->String:
	return MaterialName.split(".")[0].right(NumUnits)
	
func FindTextures(path : String, nameStruct : String):
	var dir = DirAccess.open(path)
	
	if DirAccess.get_open_error() != OK:
		print("Failed to open directory: ", path)
		return
		
	dir.list_dir_begin()
	
	var file_or_dir = dir.get_next()
	while file_or_dir != "":
		if file_or_dir.begins_with("."):
			file_or_dir = dir.get_next()
			continue
		
		var fullPath = path.path_join(file_or_dir)
		if dir.current_is_dir():
			FindTextures(fullPath, nameStruct)
		else:
			if file_or_dir.contains(nameStruct) and file_or_dir.get_extension().to_upper() == Extension.get_item_text(Extension.get_selected_id()):
				var FileSplit = file_or_dir.erase(0, nameStruct.length()).split(".")
				var Suffix : String
				if FileSplit[0] == SuffBC.text:
					Suffix = SuffBC.text
				elif FileSplit[0] == SuffR.text:
					Suffix = SuffR.text
				elif FileSplit[0] == SuffM.text:
					Suffix = SuffM.text
				elif FileSplit[0] == SuffN.text:
					Suffix = SuffN.text
				elif FileSplit[0] == SuffE.text:
					Suffix = SuffE.text
				elif FileSplit[0] == SuffO.text:
					Suffix = SuffO.text
					
				if ResourceLoader.exists(fullPath):
					var newTexture = ResourceLoader.load(fullPath)
					Textures[Suffix] = newTexture
		
		file_or_dir = dir.get_next()
		
	dir.list_dir_end()
	
func _on_reset_standard_pressed():
	BaseColor.button_pressed = false
	Roughness.button_pressed = false
	Metallic.button_pressed = false
	Normal.button_pressed = false
	Emission.button_pressed = false
	Occlusion.button_pressed = false
	
	SuffBC.text = "_BC"
	SuffR.text = "_R"
	SuffM.text = "_M"
	SuffN.text = "_N"
	SuffE.text = "_E"
	SuffO.text = "_O"
