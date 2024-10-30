class_name GDs_BarraMenus
extends Node
@export_group("Refs Externas")
@export var menuSitios: Control
@export var menuMapa: Control
@export var menuConfig: Control
@export var menuDatos: Control
@export_group("Botones")
@export var BtnSitios:Button   #0
@export var BtnMapa:Button     #1
@export var BtnConfig:Button   #2
@export var BtnGuia:Button     #3
@export_group("Audio")
@export var sndUi1:AudioStreamPlayer

var lastOneOnFocus:=0
var isFocusingMenu:= false
func _ready():
	BtnSitios.focus_entered.connect(OnBtnSitiosFocus)
	BtnGuia.focus_entered.connect(OnBtnDatosFocus)
	BtnGuia.focus_exited.connect(OnBtnDatosFocusExited)
	BtnMapa.focus_entered.connect(OnBtnMapaFocus)
	BtnMapa.focus_exited.connect(OnBtnMapaFocusExited)
	BtnConfig.focus_entered.connect(OnBtnConfigFocus)
	BtnConfig.focus_exited.connect(OnBtnConfigFocusExited)

func _input(event):
	if event.is_action_pressed("UI_FocusMenus"):
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
	BtnSitios.button_pressed = false
	menuSitios.hide()
	
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
	sndUi1.play()
	UTILITIES.TurnOnObject(menuSitios)
	BtnSitios.button_pressed = true



func OnBtnMapaFocus():
	sndUi1.play()
	UTILITIES.TurnOffObject(menuSitios)
	BtnSitios.button_pressed = false
	
	UTILITIES.TurnOnObject(menuMapa)

func OnBtnMapaFocusExited():
	UTILITIES.TurnOffObject(menuMapa)



func OnBtnDatosFocus():
	sndUi1.play()
	UTILITIES.TurnOnObject(menuDatos)

func OnBtnDatosFocusExited():
	UTILITIES.TurnOffObject(menuDatos)


func OnBtnConfigFocus():
	sndUi1.play()
	UTILITIES.TurnOnObject(menuConfig)
	UTILITIES.TurnOffObject(menuSitios)
	BtnSitios.button_pressed = false

func OnBtnConfigFocusExited():
	UTILITIES.TurnOffObject(menuConfig)
