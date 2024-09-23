@tool
#C:\Users\Diego\Downloads\test.txt
## Node to use lights without no Limit on distance and get performance
class_name VertexToPath extends Path3D

@export var fileLocation : String = ""
var window:Window

		
func ToolVertexToPath_Add():
	if Engine.is_editor_hint():
		curve.clear_points()
		global_position = Vector3.ZERO
		
		#ARCHIVO
		
		#Remplazar path 
		var replace = "\\"
		var newReplace = "/"
		var new_string = fileLocation.replace(replace, newReplace)
		
		#Obtener contenido del archivo
		var readFile = FileAccess.get_file_as_string(new_string)
		
		#Formato string -> Array (Deserializar)
		var lines_array = readFile.split("\n") 			#Array por cada linea	
		
		var idx := 0
		for line in lines_array:						#Inyectar Vector en puntos
			if not line.is_empty():
				var stringAxisXYZ = line.split(",")
				var x = float(stringAxisXYZ[0])
				var y = float(stringAxisXYZ[1])
				var z = float(stringAxisXYZ[2])
				curve.add_point(Vector3(x,y,z))
				#curve.set_point_in(idx, Vector3(0,0,5))
				#curve.set_point_out(idx, Vector3(0,0,-5))
				idx += 1

func ToolVertexToPath_Clear():
	ShowDialog()

func ShowDialog() -> void:
	if Engine.is_editor_hint():
		var editor_interface = Engine.get_singleton("EditorInterface")
		if window != null:
			window.grab_focus()

		var dialog = Label.new()
		dialog.text = "Are you sure you want to clear all the path points?"
		dialog.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dialog.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		window = ConfirmationDialog.new()
		window.size = Vector2i(200, 100)

		editor_interface.popup_dialog_centered(window)

		window.add_child(dialog)
		window.about_to_popup
		window.connect("confirmed",DialogConfirmed)


func DialogConfirmed():
	curve.clear_points()

func ShowFileExplorer() -> void:
	if Engine.is_editor_hint():
		var editor_interface = Engine.get_singleton("EditorInterface")
		var editor_FileDialog =  Engine.get_singleton("EditorFileDialog")
		if window != null:
			window.grab_focus()
			
		print_debug("editor")
		window = editor_FileDialog.new()
		window.access = editor_FileDialog.ACCESS_FILESYSTEM
		window.file_mode = editor_FileDialog.FILE_MODE_OPEN_FILE
		window.size = Vector2i(800, 500)

		editor_interface.popup_dialog_centered(window)

		window.about_to_popup
		window.connect("confirmed",DialogConfirmed)
		window.connect("file_selected",LoadFilePath)

func LoadFilePath(path: String):
	fileLocation = path
	print_debug(path)
