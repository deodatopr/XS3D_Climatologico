extends Control

@export var barraMenus:GDs_BarraMenus
@export var mapPoints:Array[Button]

var active:=0

# Called when the node enters the scene tree for the first time.
func _ready():
	visibility_changed.connect(OnVisibility)
	
	for point in mapPoints:
		point.focus_neighbor_left = barraMenus.BtnSitios.get_path()
		point.focus_neighbor_right = barraMenus.BtnDatos.get_path()


func OnVisibility():
	if visible:
		mapPoints[active].grab_focus()
