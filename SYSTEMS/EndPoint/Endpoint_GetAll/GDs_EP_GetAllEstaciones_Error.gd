extends Node

class_name GDs_EP_GetAllEstaciones_Error

@export_category("GetAllEstaciones")
@export var timer : Timer
@export var timeToRetry : float

@export_category("PANEL RECONECTANDO")
@export var panelBgk : Control
@export var panelError : Control
@export var scaleShow : float
@export var scaleHide : float
@export var speed : float = 1
@export var labelErrorType : Label
@export var labelTimeToRetryValue : Label
@export var btnReconectar : Button

signal OnFinishError

var panelErrorIsOpened : bool

func Initialize():
	btnReconectar.pressed.connect(_OnBtnReintentarPressed)
	labelErrorType.text =  str("Sin conexión reintentando en: ")
	
func Open():
	if not panelErrorIsOpened:
		_AnimPanelError(true)
		panelErrorIsOpened = true
		
	timer.start(timeToRetry)
	
func Close():
	if panelErrorIsOpened:
		_AnimPanelError(false)
		panelErrorIsOpened = false
		timer.stop()
	
func _process(_delta):
	if panelErrorIsOpened:
		var timeToRetry = timer.time_left
		labelTimeToRetryValue.text = str(roundf(timeToRetry))
		
func _OnBtnReintentarPressed():
	OnFinishError.emit()
		
func _AnimPanelError(show : bool):
	if show:
		panelBgk.show()
		panelError.show()
	
	#Animación del panel
	var tween = create_tween()
	var targetScale : float =  scaleShow if show else scaleHide
	var newScale : Vector2 = Vector2(targetScale,targetScale)
	tween.tween_property(panelError, "scale", newScale, speed)
	tween.play()
	
	if not show:
		await tween.finished
		panelError.hide()
		panelBgk.hide()
