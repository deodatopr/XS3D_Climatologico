class_name GDs_MenuMapa
extends Control

@export var barraMenus:GDs_BarraMenus
@export var popUp:GDs_PopUpVerSitio
@export var mapPoints:Array[GDs_MapPoint]

var currentSitio:=0#IDX del array

# Called when the node enters the scene tree for the first time.
func Initialize(_estaciones:Array[GDs_Data_Estacion], current:int):
	currentSitio = current
	visibility_changed.connect(OnVisibility)
	var idx = 0
	for point in mapPoints:
		point.focus_neighbor_left = barraMenus.BtnSitios.get_path()
		point.focus_neighbor_right = barraMenus.BtnDatos.get_path()
		point.pressed.connect(popUp.show)
		if idx == currentSitio:
			point.Initialize(_estaciones[idx],true)
		else:
			point.Initialize(_estaciones[idx],false)
		idx += 1


func OnVisibility():
	if visible:
		mapPoints[currentSitio].grab_focus()
