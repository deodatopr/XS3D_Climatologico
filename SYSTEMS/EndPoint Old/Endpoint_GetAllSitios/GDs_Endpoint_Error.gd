extends Node

class_name GDs_Endpoint_Error

@export_subgroup("GetAllSitios")
@export var endpoint_GetAllSitios : GDs_EndPoint_GetAllSitios
@export var timer_GetAllSitios : Timer
@export var timeToRetry_GetAllSitios : float = 10

@export_subgroup("Historicos")
@export var endpoint_Historicos : GDs_Endpoint_Historicos
@export var timer_Historicos : Timer
@export var timeToRetry_Historicos : float = 10

@export_category("PANEL RECONECTANDO")
@export var panelBgk : Control
@export var panelError : Control
@export var scaleShow : float
@export var scaleHide : float
@export var speed : float = 1
@export var labelErrorType : Label
@export var labelTimeToRetryValue : Label
@export var btnReconectar : Button

signal OnInitError
signal OnFinishError

var panelErrorIsOpened : bool
var errorType : int
var errorByEndpoint : int

func _ready():
	endpoint_GetAllSitios.On_FirstTimeRquest.connect(OnRequest_Success_GetAllSitios)
	endpoint_GetAllSitios.On_Request_Success.connect(OnRequest_Success_GetAllSitios)
	endpoint_GetAllSitios.On_Request_Failed_BY_INTERNET.connect(OnRequest_Failed_ByInternet_GetAllSitios)
	
	endpoint_Historicos.On_Request_Success.connect(OnRequest_Success_Historicos)
	endpoint_Historicos.On_Request_Failed_BY_INTERNET.connect(OnRequest_Failed_ByInternet_Historicos)
	
	btnReconectar.pressed.connect(OnBtnReintentarPressed)
	
	errorByEndpoint = ENUMS.ERROR_ENDPOINT.NONE
	
func _process(_delta):
	if panelErrorIsOpened:
		var timeToRetry = timer_GetAllSitios.time_left if errorByEndpoint == ENUMS.ERROR_ENDPOINT.GETALLSITIOS else timer_Historicos.time_left
		labelTimeToRetryValue.text = str(roundf(timeToRetry))
		
func OnBtnReintentarPressed():
	match errorByEndpoint:
		ENUMS.ERROR_ENDPOINT.NONE:
			return
		ENUMS.ERROR_ENDPOINT.GETALLSITIOS:
			OnTimeOut_GetAllSitios()
		ENUMS.ERROR_ENDPOINT.HISTORICOS:
			OnTimeOut_Historicos()
		
func AnimPanelError(show : bool):
	if ProjectSettings.get_setting("DEBUG/IgnoreUIErrorConection"):
		print_rich("[color=orange]--------- NOTA: UI ERROR CONEXIÓN DESACTIVADA POR SETTING  [ DEBUG/IgnoreUIErrorConection ]---------- [/color]")
		return
	
	if show:
		panelBgk.show()
		panelError.show()
	else:
		errorByEndpoint = ENUMS.ERROR_ENDPOINT.NONE
	
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

#region Endpoint GetAllSitios
func OnRequest_Success_GetAllSitios():
	if panelErrorIsOpened:
		AnimPanelError(false)
		panelErrorIsOpened = false
		timer_GetAllSitios.stop()
		OnFinishError.emit()

func OnRequest_Failed_ByInternet_GetAllSitios():
	errorType = ENUMS.EndpointStatus.ERROR_INTERNET

	labelErrorType.text =  str("Sin conexión reintentando en: ")
	On_Request_Failed_GetAllSitios()

func On_Request_Failed_GetAllSitios():
	if not panelErrorIsOpened:
		errorByEndpoint = ENUMS.ERROR_ENDPOINT.GETALLSITIOS
		AnimPanelError(true)
		panelErrorIsOpened = true
		OnInitError.emit()
	
	if not timer_GetAllSitios.timeout.is_connected(OnTimeOut_GetAllSitios):
		timer_GetAllSitios.timeout.connect(OnTimeOut_GetAllSitios)
		
	timer_GetAllSitios.start(timeToRetry_GetAllSitios)
	
func OnTimeOut_GetAllSitios():
	endpoint_GetAllSitios.Request_GetAllSitios()
	print_rich("[color=pink][b]Reintentado endpoint..![/b][/color].")
#endregion

#region Endpoint Historicos
func OnRequest_Success_Historicos():
	if panelErrorIsOpened:
		AnimPanelError(false)
		panelErrorIsOpened = false
		timer_Historicos.stop()
		OnFinishError.emit()

func OnRequest_Failed_ByInternet_Historicos():
	errorType = ENUMS.EndpointStatus.ERROR_INTERNET

	labelErrorType.text =  str("Sin conexión reintentando en: ")
	On_Request_Failed_Historicos()
	
func OnRequest_Failed_ByEndpoint_Historicos():
	errorType = ENUMS.EndpointStatus.ERROR_ENDPOINT
	
	labelErrorType.text =  str("Sin conexión reintentando en: ")
	On_Request_Failed_Historicos()

func On_Request_Failed_Historicos():
	if not panelErrorIsOpened:
		errorByEndpoint = ENUMS.ERROR_ENDPOINT.HISTORICOS
		AnimPanelError(true)
		panelErrorIsOpened = true
		OnInitError.emit()
	
	if not timer_Historicos.timeout.is_connected(OnTimeOut_Historicos):
		timer_Historicos.timeout.connect(OnTimeOut_Historicos)
		
	timer_Historicos.start(timeToRetry_Historicos)
	
func OnTimeOut_Historicos():
	endpoint_Historicos.Retry_RequestHistoricosAfterError()
	print_rich("[color=pink][b]Reintentado endpoint [Historicos]..![/b][/color].")
#endregion
