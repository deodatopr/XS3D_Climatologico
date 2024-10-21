extends Node

@export_group("Botones")
@export var BtnSitios:Button   #0
@export var BtnMapa:Button     #1
@export var BtnConfig:Button   #2
@export var BtnGuia:Button     #3

var lastOneOnFocus: int
var isFocusingMenu:= false
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("UIFocusMenus"):
		isFocusingMenu != isFocusingMenu
		if isFocusingMenu:
			FocusLastMenu()
		else:
			StopFocusOnMenus()

func FocusLastMenu():
	match lastOneOnFocus:
		0:
			BtnSitios.grab_focus()
		1:
			BtnMapa.grab_focus()
		2:
			BtnConfig.grab_focus()
		3:
			BtnGuia.grab_focus()

func StopFocusOnMenus():
	BtnSitios.release_focus()
	BtnMapa.release_focus()
	BtnConfig.release_focus()
	BtnGuia.release_focus()

func GetCurrentFocus():
	if BtnSitios.has_focus():
		lastOneOnFocus = 0
	if BtnMapa.has_focus():
		lastOneOnFocus = 1
	if BtnConfig.has_focus():
		lastOneOnFocus = 2
	if BtnGuia.has_focus():
		lastOneOnFocus = 3
