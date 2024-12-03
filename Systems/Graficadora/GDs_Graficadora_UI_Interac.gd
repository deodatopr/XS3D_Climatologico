extends Control

@export_group("External Refs")
@export var barraMenus: GDs_BarraMenus

@export_group("Internal Refs")
@export var fromDate:Control
@export var toDate:Control
@export var sitesBtnContainer:Control
@export var muestrasLess:Button
@export var muestrasMore:Button
@export var sitesLastBtn:Button
@export var scrollBar:HScrollBar
# Called when the node enters the scene tree for the first time.
func _ready():
	visibility_changed.connect(OnVisible)
	
	for child in sitesBtnContainer.get_children():
		child.focus_neighbor_left = barraMenus.BtnMapa.get_path()
		child.focus_neighbor_right = barraMenus.BtnConfig.get_path()
	
	sitesLastBtn.focus_neighbor_bottom = fromDate.get_child(1).get_path()
	fromDate.get_child(1).focus_neighbor_left = barraMenus.BtnMapa.get_path()
	fromDate.get_child(1).focus_neighbor_right = barraMenus.BtnConfig.get_path()
	fromDate.get_child(1).focus_neighbor_top = sitesLastBtn.get_path()
	toDate.get_child(1).focus_neighbor_left = barraMenus.BtnMapa.get_path()
	toDate.get_child(1).focus_neighbor_right = barraMenus.BtnConfig.get_path()
	muestrasLess.focus_neighbor_left = barraMenus.BtnMapa.get_path()
	muestrasLess.focus_neighbor_right = barraMenus.BtnConfig.get_path()
	muestrasMore.focus_neighbor_left = barraMenus.BtnMapa.get_path()
	muestrasMore.focus_neighbor_right = barraMenus.BtnConfig.get_path()

func _process(delta):
	if not visible : return
	if Input.is_action_pressed("3DMove_SpeedBoost"):
		scrollBar.value -= delta * 20
	if Input.is_action_pressed("3DMove_Height_+"):
		scrollBar.value += delta * 20


func OnVisible():
	if visible:
		fromDate.get_child(1).grab_focus()
