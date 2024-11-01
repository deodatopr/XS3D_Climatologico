class_name GDs_BarraMenus
extends Node
@export_group("Refs Externas")
@export var menuSitios: Control
@export var menuMapa: Control
@export var menuDatos: Control
@export var menuConfig: Control
@export_group("Botones")
@export var BtnSitios:Button   #0
@export var BtnMapa:Button     #1
@export var BtnDatos:Button     #3
@export var BtnConfig:Button   #2
@export_group("Audio")
@export var sndUi1:AudioStreamPlayer

var lastOneOnFocus:=0
var isFocusingMenu:= false
func _ready():
	BtnSitios.focus_entered.connect(OnBtnSitiosFocus)
	BtnSitios.pressed.connect(OnBtnSitioPressed)
	
	BtnMapa.focus_entered.connect(OnBtnMapaFocus)
	BtnMapa.focus_exited.connect(OnBtnMapaFocusExited)
	BtnMapa.pressed.connect(OnBtnMapaPressed)
	
	BtnDatos.focus_entered.connect(OnBtnDatosFocus)
	BtnDatos.focus_exited.connect(OnBtnDatosFocusExited)
	BtnDatos.pressed.connect(OnBtnDatosPressed)
	
	BtnConfig.focus_entered.connect(OnBtnConfigFocus)
	BtnConfig.focus_exited.connect(OnBtnConfigFocusExited)
	BtnConfig.pressed.connect(OnBtnConfigPressed)

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
			BtnDatos.grab_focus()

func StopFocusOnMenus():
	GetCurrentFocus()
	BtnSitios.release_focus()
	BtnSitios.button_pressed = false
	menuSitios.hide()
	
	BtnMapa.release_focus()
	BtnConfig.release_focus()
	BtnDatos.release_focus()

func GetCurrentFocus():
	if BtnSitios.has_focus():
		lastOneOnFocus = 0
	if BtnMapa.has_focus():
		lastOneOnFocus = 1
	if BtnConfig.has_focus():
		lastOneOnFocus = 2
	if BtnDatos.has_focus():
		lastOneOnFocus = 3



func OnBtnSitioPressed():
	if BtnSitios.has_focus():
		BtnSitios.release_focus()
		UTILITIES.TurnOffObject(menuSitios)
	else:
		BtnSitios.grab_focus()
		
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
	BtnMapa.button_pressed = false

func OnBtnMapaPressed():
	if BtnMapa.button_pressed:
		BtnMapa.grab_focus()
	else:
		BtnMapa.release_focus()



func OnBtnDatosFocus():
	sndUi1.play()
	UTILITIES.TurnOnObject(menuDatos)
	BtnSitios.button_pressed = false
	UTILITIES.TurnOffObject(menuSitios)
	
	

func OnBtnDatosFocusExited():
	UTILITIES.TurnOffObject(menuDatos)
	BtnDatos.button_pressed = false
	
func OnBtnDatosPressed():
	if BtnDatos.button_pressed:
		BtnDatos.grab_focus()
	else:
		BtnDatos.release_focus()



func OnBtnConfigFocus():
	sndUi1.play()
	UTILITIES.TurnOnObject(menuConfig)
	UTILITIES.TurnOffObject(menuSitios)
	BtnSitios.button_pressed = false

func OnBtnConfigFocusExited():
	UTILITIES.TurnOffObject(menuConfig)
	
	BtnConfig.button_pressed = false
	

func OnBtnConfigPressed():
	if BtnConfig.button_pressed:
		BtnConfig.grab_focus()
	else:
		BtnConfig.release_focus()
