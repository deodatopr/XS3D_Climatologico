@tool
extends Control 

@export var btnAutoAssign: Button
@export var btnResetMaterials: Button
var fileSystemSelPath :PackedStringArray
var resourceArray: Array[PackedScene] =[]

var importPath: String  = ""
var window:Window


func _ready():
	btnAutoAssign.connect("button_down",GetFileSystemSelected)
	btnResetMaterials.connect("button_down",CleanMaterials)

func GetFileSystemSelected():
	fileSystemSelPath.clear()
	resourceArray.clear()
	
	fileSystemSelPath = EditorInterface.get_selected_paths()
	var meshCount = 0
	for path in fileSystemSelPath:
		if ValidFileExtension(path.get_extension()):
			meshCount += 1
			var resource = ResourceLoader.load(path)
			var scene = resource.instantiate()
			for surface in GetAllSurfaces(scene):
				FindMaterialInProject(surface)
			AutoAssingMaterials(resource)
	
	if meshCount == 0:
		OpenPopUp_Assign()

func ValidFileExtension(path:String) -> bool:
	match path:
		"blend": return true
		"gltf": return true
		"glb": return true
		"fbx": return true
		"obj": return true
		_:return false

func GetAllChilds(node,array : Array[Node] =[]) -> Array[Node]:
	array.push_back(node)
	for child in node.get_children():
		array = GetAllChilds(child, array)
	return array

func GetAllSurfaces(node : Node) -> Array[String]:
	var childs = GetAllChilds(node)
	var list : Array[String]
	for child in childs:
		if child.get_class() == "MeshInstance3D":
			var mi : MeshInstance3D = child
			for s in mi.mesh.get_surface_count():
				var matName = mi.mesh.get("surface_" + str(s) + "/name") #Surface name?
				if !list.has(matName):
					list.append(matName)
	
	return list

func FindMaterialInProject(matName : String) -> String:
	var possibleNames : Array[String]
	
	#Possible name variants
	possibleNames.append(matName)
	possibleNames.append(matName.replace(" ", "_"))
	possibleNames.append(matName.replace("_", " "))
	possibleNames.append(matName.replace(" ", ""))
	possibleNames.append(matName.replace("_", ""))
	
	var folders = GetAllFolders()
	
	for folder in folders:
		for name in possibleNames:
			#Find with extra steps to keep cases matching
			var correctName = name
			var files = DirAccess.get_files_at(folder)
			for file in files:
				if file.to_lower() == (name + ".tres").to_lower():
					correctName = file
			
			var path = folder + correctName
			
			if FileAccess.file_exists(path):
				var m = load(path)
				if m != null:
					if m.is_class("Material"):
						#print("[AutoMat] Material found: " + matName + ", " + m.resource_path)
						return m.resource_path
	print_rich("[bgcolor=RED]Material not found:[/bgcolor] " + matName)
	return ""

func GetAllFolders(path : String = "res://") -> Array[String]:
	var folders : Array[String]
	for dir in DirAccess.get_directories_at(path):
		if dir.begins_with("."):
			continue
		
		var p = path + dir + "/"
		folders.append(p)
		folders.append_array(GetAllFolders(p))
	
	return folders

func AutoAssingMaterials(meshFile : PackedScene):
	
	var subresourcesLine = "_subresources="
	
	var scene = meshFile.instantiate()
	var matNames = GetAllSurfaces(scene)
	
	var matPaths : Array[String]
	
	for matn in matNames:
		var mat = FindMaterialInProject(matn)
		matPaths.append(mat)
	
	var config = ConfigFile.new()
	config.load(meshFile.resource_path + ".import")
	
	var subresources : Dictionary = config.get_value("params", "_subresources")
	var subresourcesmats : Dictionary
	if subresources.has("materials"):
		subresourcesmats = subresources["materials"].duplicate()
	
	for m in range(matNames.size()):
		if matPaths[m] != "":
			subresourcesmats[matNames[m]] = { "use_external/enabled": true, "use_external/path": matPaths[m] }
	
	if !subresources.has("materials"):
		subresources["materials"] = {}
	
	subresources["materials"].clear()
	subresources["materials"] = subresourcesmats
	
	config.set_value("params", "_subresources", subresources)
	config.save(meshFile.resource_path + ".import")
	EditorInterface.get_resource_filesystem().reimport_files([meshFile.resource_path])
	#OpenPopUp_Assign()
	
func CleanMaterials():
	fileSystemSelPath.clear()
	resourceArray.clear()
	
	fileSystemSelPath = EditorInterface.get_selected_paths()
	var meshCount=0
	for path in fileSystemSelPath:
		importPath = path
		if ValidFileExtension(importPath.get_extension()):
			meshCount += 1
			OpenPopUp_Clean(path)
	if meshCount == 0:
		OpenPopUp_Assign()

func DeleteImport():
	var error = DirAccess.remove_absolute(importPath + ".import")
	if error == OK:
		EditorInterface.get_resource_filesystem().reimport_files([importPath])
	importPath = ""

func OpenPopUp_Clean(_path: String):
	if window != null:
		window.grab_focus()

	var dialog = Label.new()
	dialog.text = "Are you sure you want to clean materials of '" +_path +"'?"
	dialog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialog.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	window = ConfirmationDialog.new()
	window.size = Vector2i(200, 100)

	EditorInterface.popup_dialog_centered(window)

	window.add_child(dialog)
	window.about_to_popup
	
	window.connect("confirmed",DeleteImport)


func OpenPopUp_Assign():
	if window != null:
		window.grab_focus()

	var dialog = Label.new()
	dialog.text = "There is no 'MESH' selected from 'FILESYSTEM'"
	dialog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialog.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	window = AcceptDialog.new()
	window.size = Vector2i(200, 100)

	EditorInterface.popup_dialog_centered(window)

	window.add_child(dialog)
	window.about_to_popup
