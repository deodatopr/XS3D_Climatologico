class_name GDs_EP_GetAllEstaciones_Error extends Node


@export_category("GetAllEstaciones")
@export var timer : Timer

@export_category("Panel")
@export var panelBgk : Control
@export var panelError : Control
@export var scaleShow : float
@export var scaleHide : float
@export var speed : float = 1
@export var labelErrorType : Label
@export var labelTimeToRetryValue : Label
@export var btnReconectar : Button

signal OnFinishError

var CR_LocalEstaciones: GDs_CR_LocalEstaciones
var timeToRetry : float = 10
var originalTimeRetry : float
var panelErrorIsOpened : bool

func Initialize(_CR_LocalEstaciones: GDs_CR_LocalEstaciones, _timeToRetry : float):
	timer.timeout.connect(_OnTimeOut)
	btnReconectar.pressed.connect(_OnBtnReintentarPressed)
	
	originalTimeRetry = _timeToRetry
	CR_LocalEstaciones = _CR_LocalEstaciones
	labelErrorType.text =  str("Sin conexión reintentando en: ")
	
func Open():
	if not panelErrorIsOpened:
		_AnimPanelError(true)
		panelErrorIsOpened = true
	
	timer.stop()
	timeToRetry = originalTimeRetry
	timer.start(timeToRetry)
	
func Close():
	if panelErrorIsOpened:
		_AnimPanelError(false)
		panelErrorIsOpened = false
		
func GetEstaciones()-> Array[GDs_Data_EP_Estacion]:
	#Llenar datos vacios de endpoint para que la app pueda funcionar pero sin datos	
	var custom_array: Array[GDs_Data_EP_Estacion] = []

	#Obtener y setear cada propiedad de la clase ENDPOINT_SITIO_EXT para agregarlo al array
	for i in range(CR_LocalEstaciones.LocalEstaciones.size()):
		var emptyEstacion = {
		"id": CR_LocalEstaciones.LocalEstaciones[i].id,
		"fecha": "--/--/-- T --:--:--",
		"nivel": 0.0,
		"prtcion_pluvial": 0.0,
		"humedad": 0.0,
		"evaporacion": 0.0,
		"intsdad_viento": 0.0,
		"dir_viento": 0.0,
		"temperatura": 0.0,
		
		"disp_utr": false,
		"fallo_alim_ac": false,
		"volt_bat_resp": 0.0,
		
		"enlace": false,
		"energia_electrica": false,
		"rebasa_nvls_presa": false,
		"rebasa_tlrncia_prep_pluv": false
		}
		
		var custom_item = GDs_Data_EP_Estacion.new(emptyEstacion)
		custom_array.append(custom_item)

	return custom_array
	
func _process(_delta):
	if panelErrorIsOpened:
		timeToRetry = timer.time_left
		labelTimeToRetryValue.text = str(roundf(timeToRetry))

func _OnTimeOut():
	timer.stop()
	OnFinishError.emit()

func _OnBtnReintentarPressed():
	if APPSTATE.EP_GetAllEstaciones_RequestType == ENUMS.EP_RequestType.From_Debug_Error:
		APPSTATE.EP_GetAllEstaciones_RequestType = ENUMS.EP_RequestType.From_Debug_Random
	
	OnFinishError.emit()
	timer.stop()
		
func _AnimPanelError(show : bool):
	if show:
		panelBgk.show()
		panelError.show()
	
	#Animación del panel
	var tween = create_tween()
	var targetScale : float =  scaleShow if show else scaleHide
	var newScale : Vector2 = Vector2(targetScale,targetScale)
	tween.tween_property(panelError, "scale", newScale, .001)
	tween.play()
	
	if not show:
		await tween.finished
		panelError.hide()
		panelBgk.hide()
