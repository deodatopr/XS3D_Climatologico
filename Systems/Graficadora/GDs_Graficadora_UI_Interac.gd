class_name GDs_Graficadora_UI_Interact extends Node

@export_group("Internal Refs")
@export var firstToGrabFocus:Button
@export var graficadora : Control
@export var sitesBtnContainer:Control
@export var sitesLastBtn:Button
@export var scrollContainerGraphic:ScrollContainer
@export var btnsGraficar : Button
@export_subgroup("Date Dropdowns")
@export var dateYearDd: OptionButton
@export var dateMonthDd: OptionButton
@export var dateDayDd: OptionButton
@export var dateTimeDd: OptionButton
var barraMenus: GDs_BarraMenus

func Initialize(_dataService : GDs_DataService_Manager,_barraMenus: GDs_BarraMenus):
	graficadora.visibility_changed.connect(func x(): if graficadora.visibility_changed: firstToGrabFocus.grab_focus())
	barraMenus = _barraMenus
	
	for child in sitesBtnContainer.get_children():
		child.focus_neighbor_left = barraMenus.BtnMapa.get_path()
		child.focus_neighbor_right = barraMenus.BtnConfig.get_path()
	
	dateYearDd.focus_neighbor_left = barraMenus.BtnMapa.get_path()
	dateYearDd.focus_neighbor_right = barraMenus.BtnConfig.get_path()
	dateMonthDd.focus_neighbor_left = barraMenus.BtnMapa.get_path()
	dateMonthDd.focus_neighbor_right = barraMenus.BtnConfig.get_path()
	dateDayDd.focus_neighbor_left = barraMenus.BtnMapa.get_path()
	dateDayDd.focus_neighbor_right = barraMenus.BtnConfig.get_path()
	dateTimeDd.focus_neighbor_left = barraMenus.BtnMapa.get_path()
	dateTimeDd.focus_neighbor_right = barraMenus.BtnConfig.get_path()
	btnsGraficar.focus_neighbor_left = barraMenus.BtnMapa.get_path()
	btnsGraficar.focus_neighbor_right = barraMenus.BtnConfig.get_path()

func _process(delta):
	if not graficadora.visible : return
	if Input.is_action_pressed("3DMove_RotHor_-"):
		scrollContainerGraphic.get_h_scroll_bar().value -= delta * 600
	if Input.is_action_pressed("3DMove_RotHor_+"):
		scrollContainerGraphic.get_h_scroll_bar().value += delta * 600
