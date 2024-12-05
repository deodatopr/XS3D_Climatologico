class_name GDs_Graficadora_UI_Interact extends Node

@export_group("Internal Refs")
@export var graficadora : Control
@export var sitesBtnContainer:Control
@export var muestrasLess:Button
@export var muestrasMore:Button
@export var sitesLastBtn:Button
@export var scrollBar:HScrollBar
@export var btnsSitios : Array[GDs_Graficadora_Item_BtnSitio] = []

var barraMenus: GDs_BarraMenus

func Initialize(_dataService : GDs_DataService_Manager,_barraMenus: GDs_BarraMenus):
	barraMenus = _barraMenus
	
	for child in sitesBtnContainer.get_children():
		child.focus_neighbor_left = barraMenus.BtnMapa.get_path()
		child.focus_neighbor_right = barraMenus.BtnConfig.get_path()
	
	muestrasLess.focus_neighbor_left = barraMenus.BtnMapa.get_path()
	muestrasLess.focus_neighbor_right = barraMenus.BtnConfig.get_path()
	muestrasMore.focus_neighbor_left = barraMenus.BtnMapa.get_path()
	muestrasMore.focus_neighbor_right = barraMenus.BtnConfig.get_path()
	
	var idx : int = 0
	for btnSitio in btnsSitios:
		var sitio : GDs_Data_Sitio = _dataService.estaciones[idx]
		btnSitio.Initialize(sitio.color,sitio.id,sitio.nombre)
		idx += 1

func _process(delta):
	if not graficadora.visible : return
	if Input.is_action_pressed("3DMove_SpeedBoost"):
		scrollBar.value -= delta * 20
	if Input.is_action_pressed("3DMove_Height_+"):
		scrollBar.value += delta * 20
