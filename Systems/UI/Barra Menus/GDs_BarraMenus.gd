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
	BtnMapa.pressed.connect(OnBtnMapaPressed)
	
	BtnDatos.focus_entered.connect(OnBtnDatosFocus)
	BtnDatos.pressed.connect(OnBtnDatosPressed)
	
	BtnConfig.focus_entered.connect(OnBtnConfigFocus)
	BtnConfig.pressed.connect(OnBtnConfigPressed)
	
	
	TurnOffAllMenus()

func _input(event):
	if event.is_action_pressed("UI_FocusMenus"):
		isFocusingMenu = !isFocusingMenu
		if isFocusingMenu:
			FocusLastMenu()
		else:
			StopFocusOnMenus()
	if event.is_action_pressed("ui_cancel"):
		pass
		#if BtnSitios.button_pressed: 
			#BtnSitios.release_focus()
			#BtnSitios.button_pressed = false
			#UTILITIES.TurnOffObject(menuSitios)
			#
		#if BtnMapa.has_focus(): BtnMapa.release_focus()
		#if BtnDatos.has_focus(): BtnDatos.release_focus()
		#if BtnConfig.has_focus(): BtnConfig.release_focus()
	

func FocusLastMenu():
	match lastOneOnFocus:
		0:
			BtnSitios.grab_focus()
		1:
			BtnMapa.grab_focus()
		2:
			BtnDatos.grab_focus()
		3:
			BtnConfig.grab_focus()

func StopFocusOnMenus():
	GetCurrentFocus()
	BtnSitios.release_focus()
	BtnSitios.button_pressed = false
	UTILITIES.TurnOffObject(menuSitios)
	
	BtnMapa.release_focus()
	BtnMapa.button_pressed = false
	UTILITIES.TurnOffObject(menuMapa)
	
	BtnDatos.release_focus()
	BtnDatos.button_pressed = false
	UTILITIES.TurnOffObject(menuDatos)
	
	BtnConfig.release_focus()
	BtnConfig.button_pressed = false
	UTILITIES.TurnOffObject(menuConfig)
	

func GetCurrentFocus():
	if BtnSitios.button_pressed:
		lastOneOnFocus = 0
	if BtnMapa.button_pressed:
		lastOneOnFocus = 1
	if BtnDatos.button_pressed:
		lastOneOnFocus = 2
	if BtnConfig.button_pressed:
		lastOneOnFocus = 3



func OnBtnSitioPressed():
	if BtnSitios.has_focus():
		BtnSitios.release_focus()
		UTILITIES.TurnOffObject(menuSitios)
	else:
		BtnSitios.grab_focus()
		
func OnBtnSitiosFocus():
	sndUi1.play()
	UTILITIES.TurnOffObject(menuMapa)
	UTILITIES.TurnOffObject(menuDatos)
	UTILITIES.TurnOffObject(menuConfig)
	UTILITIES.TurnOnObject(menuSitios)
	BtnMapa.button_pressed = false
	BtnDatos.button_pressed = false
	BtnConfig.button_pressed = false
	BtnSitios.button_pressed = true



func OnBtnMapaPressed():
	
	if BtnMapa.has_focus():
		BtnMapa.release_focus()
		UTILITIES.TurnOffObject(menuMapa)
	else:
		BtnMapa.grab_focus()

func OnBtnMapaFocus():
	sndUi1.play()
	UTILITIES.TurnOffObject(menuSitios)
	UTILITIES.TurnOffObject(menuDatos)
	UTILITIES.TurnOffObject(menuConfig)
	UTILITIES.TurnOnObject(menuMapa)
	BtnSitios.button_pressed = false
	BtnDatos.button_pressed = false
	BtnConfig.button_pressed = false
	BtnMapa.button_pressed = true





func OnBtnDatosPressed():
	if BtnDatos.has_focus():
		BtnDatos.release_focus()
		UTILITIES.TurnOffObject(menuDatos)
	else:
		BtnDatos.grab_focus()

func OnBtnDatosFocus():
	sndUi1.play()
	UTILITIES.TurnOffObject(menuSitios)
	UTILITIES.TurnOffObject(menuMapa)
	UTILITIES.TurnOffObject(menuConfig)
	UTILITIES.TurnOnObject(menuDatos)
	BtnSitios.button_pressed = false
	BtnMapa.button_pressed = false
	BtnConfig.button_pressed = false
	BtnDatos.button_pressed = true


func OnBtnConfigPressed():
	if BtnConfig.has_focus():
		BtnConfig.release_focus()
		UTILITIES.TurnOffObject(menuConfig)
	else:
		BtnConfig.grab_focus()

func OnBtnConfigFocus():
	sndUi1.play()
	UTILITIES.TurnOffObject(menuSitios)
	UTILITIES.TurnOffObject(menuMapa)
	UTILITIES.TurnOffObject(menuDatos)
	UTILITIES.TurnOnObject(menuConfig)
	BtnSitios.button_pressed = false
	BtnMapa.button_pressed = false
	BtnDatos.button_pressed = false
	BtnConfig.button_pressed = true





func TurnOffAllMenus():
	UTILITIES.TurnOffObject(menuSitios)
	UTILITIES.TurnOffObject(menuMapa)
	UTILITIES.TurnOffObject(menuDatos)
	UTILITIES.TurnOffObject(menuConfig)
