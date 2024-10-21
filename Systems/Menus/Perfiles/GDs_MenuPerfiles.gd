extends Control

@export_group("Refs Externas")
@export var barraMenu:GDs_BarraMenus
@export_group("Refs Internas")
@export var sitios: Array[GDs_Perf_Sitio]

var lastOneFocused:= 0
# Called when the node enters the scene tree for the first time.
func _ready():
	visibility_changed.connect(OnShowHide)
	AssignFocusNeighbor()


func OnShowHide():
	if visible:
		sitios[lastOneFocused].button.grab_focus()

func AssignFocusNeighbor():
	for sitio in sitios:
		sitio.button.focus_neighbor_left = barraMenu.BtnGuia.get_path()
		sitio.button.focus_neighbor_right = barraMenu.BtnMapa.get_path()
