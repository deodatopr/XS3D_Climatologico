extends ColorRect

@export var barraMenus:GDs_BarraMenus
@export var testBtn:Button

# Called when the node enters the scene tree for the first time.
func _ready():
	visibility_changed.connect(OnVisibility)
	
	testBtn.focus_neighbor_left = barraMenus.BtnMapa.get_path()
	testBtn.focus_neighbor_right = barraMenus.BtnConfig.get_path()


func OnVisibility():
	if visible:
		testBtn.grab_focus()
