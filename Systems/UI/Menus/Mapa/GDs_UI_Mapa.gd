extends Control

@export var barraMenus:GDs_BarraMenus
@export var popUp:GDs_PopUpVerSitio
@export var mapPoints:Array[Button]

var active:=0

# Called when the node enters the scene tree for the first time.
func _ready():
	visibility_changed.connect(OnVisibility)
	
	for point in mapPoints:
		point.focus_neighbor_left = barraMenus.BtnSitios.get_path()
		point.focus_neighbor_right = barraMenus.BtnDatos.get_path()
		point.pressed.connect(popUp.show)


func OnVisibility():
	if visible:
		mapPoints[active].grab_focus()
