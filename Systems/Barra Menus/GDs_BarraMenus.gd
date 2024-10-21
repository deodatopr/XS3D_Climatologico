extends Node
@export_group("Refs Externas")
@export var menuSitios: Control
@export var menuGuia: Control
@export_group("Botones")
@export var BtnSitios:Button   #0
@export var BtnMapa:Button     #1
@export var BtnConfig:Button   #2
@export var BtnGuia:Button     #3

var lastOneOnFocus:=0
var isFocusingMenu:= false
func _ready():
	BtnSitios.focus_entered.connect(OnBtnSitiosFocus)
	BtnSitios.focus_exited.connect(OnBtnSitiosFocusExited)
	BtnGuia.focus_entered.connect(OnBtnGuiaFocus)
	BtnGuia.focus_exited.connect(OnBtnGuiaFocusExited)

func _input(event):
	if event.is_action_pressed("UIFocusMenus"):
		isFocusingMenu = !isFocusingMenu
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
	GetCurrentFocus()
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

func OnBtnSitiosFocus():
	menuSitios.show()

func OnBtnSitiosFocusExited():
	menuSitios.hide()

func OnBtnGuiaFocus():
	menuGuia.show()

func OnBtnGuiaFocusExited():
	menuGuia.hide()
