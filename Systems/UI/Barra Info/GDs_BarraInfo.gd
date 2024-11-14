class_name GDs_BarraInfo
extends Control

@export_group("Data Refresh")
@export_subgroup("Color, ID & Nombre")
@export var id:Label
@export var idframe:Control
@export var nombre:Label
@export var estado:Label
@export var fecha:Label
@export_subgroup("Senales")
@export var senal:Control
@export var UTR:Control
@export var OnColor:Color
@export var OffColor:Color
@export_subgroup("Nivel")
@export var nivel:Label
@export var nivelSnsr:Control
@export var nivelBg:Control
@export var nivelNorm:Label
@export var nivelPrev:Label
@export var nivelCrit:Label
@export var ColorNorm:Color
@export var ColorPrev:Color
@export var ColorCrit:Color
@export var animColor:Color
@export_subgroup("Datos")
@export var precipitacion:Label
@export var precipitacionSnsr:Control
@export var humedad:Label
@export var humedadSnsr:Control
@export var evaporacion:Label
@export var evaporacionSnsr:Control
@export var temp:Label
@export var tempSnsr:Control
@export var presion:Label
@export var presionSnsr:Control
@export var viento:Label
@export var vientoSnsr:Control
@export var lblBateria : Label

@export_group("Panel Error")
@export var panelError : Control
@export var lblTimeValue : Label
@export var btnReconectar : Button
@export var timer : Timer
@export var animBttomColor : AnimationPlayer

var tween:Tween
var timeToReconect : float
var timerIsRunning : bool
var tweenPanelError : Tween

func _ready():
	btnReconectar.pressed.connect(_OnBtnReconectarPressed)
	timer.timeout.connect(_OnTimerTimeOut)
	panelError.hide()
	
func Initialize(_timeToReconnect : float):
	timeToReconect = _timeToReconnect
	
func _process(_delta):
	if timerIsRunning:
		lblTimeValue.text = str(ceili(timer.time_left))

func OnRequestFailed():
	if not panelError.visible:
		_AnimShowPaneError()
		
func OnRequestSuccess():
	if panelError.visible:
		_AnimHidePanelError()
		
func OnDataRefresh():
	var sitio : GDs_Data_Estacion = APPSTATE.currntSitio
	
	id.text = str(sitio.id)
	idframe.self_modulate = sitio.color
	nombre.text = sitio.nombre
	estado.text = UTILITIES.FormatEstado(sitio.estado)
	
	#Senales
	if sitio.enlace:
		senal.self_modulate = OnColor
	else:
		senal.self_modulate = OffColor
	if sitio.disp_utr:
		UTR.self_modulate = OnColor
	else:
		UTR.self_modulate = OffColor

	#nivel
	nivel.text = UTILITIES.FormatNivel(sitio.nivel)
	nivelPrev.text = UTILITIES.FormatNiveles(sitio.nivelPrev)
	nivelCrit.text = UTILITIES.FormatNiveles(sitio.nivelCrit)
	
	nivelBg.self_modulate = ColorNorm
	StopAnimation()
	var hayDatos : bool = not is_nan(sitio.nivel)
	if hayDatos and (sitio.nivel > sitio.nivelPrev and sitio.nivel <= sitio.nivelCrit): 
		nivelBg.self_modulate = ColorPrev
		PlayAnimation(ColorPrev,0.4)
	if hayDatos and sitio.nivel > sitio.nivelCrit: 
		nivelBg.self_modulate = ColorCrit
		PlayAnimation(ColorCrit,0.3)
	
	#Datos
	precipitacion.text = UTILITIES.FormatPptn_pluvial(sitio.pptn_pluvial)
	precipitacionSnsr.self_modulate = OnColor 
	if not sitio.pcptnSnsr: precipitacionSnsr.self_modulate = OffColor 
	
	humedad.text = UTILITIES.FormatHumedad(sitio.humedad)
	humedadSnsr.self_modulate = OnColor 
	if not sitio.humTempSnsr: humedadSnsr.self_modulate = OffColor 
	
	evaporacion.text = UTILITIES.FormatEvaporacion(sitio.evaporacion)
	evaporacionSnsr.self_modulate = OnColor 
	if not sitio.solSnsr: evaporacionSnsr.self_modulate = OffColor 
	
	temp.text = UTILITIES.FormatTemperatura(sitio.temperatura)
	tempSnsr.self_modulate = OnColor 
	if not sitio.humTempSnsr: tempSnsr.self_modulate = OffColor 
	
	presion.text = UTILITIES.FormatPresion(sitio.presion)
	presionSnsr.self_modulate = OnColor 
	if not sitio.prsnSnsr: presionSnsr.self_modulate = OffColor 
	
	viento.text = UTILITIES.FormatIntensidadViento(sitio.intsdad_viento)#TODO sistema para que regrese N S E O
	vientoSnsr.self_modulate = OnColor 
	if not sitio.vntoSnsr: vientoSnsr.self_modulate = OffColor
	
func _OnTimerTimeOut():
	if DEBUG.modoDatos == ENUMS.ModoDatos.Simulado:
		DEBUG.requestResult = ENUMS.EP_RequestResult.Success
		SIGNALS.OnDebugValuechangedByScript.emit()

func _OnBtnReconectarPressed():
	if DEBUG.modoDatos == ENUMS.ModoDatos.Simulado:
		DEBUG.requestResult = ENUMS.EP_RequestResult.Success
		SIGNALS.OnDebugValuechangedByScript.emit()

func _AnimShowPaneError():
	var initialPanelPos : Vector2 = panelError.position
	initialPanelPos.y = panelError.size.y
	panelError.position = initialPanelPos
	panelError.show()
	animBttomColor.play()
	
	var targetPos : Vector2 = panelError.position
	targetPos.y -= panelError.size.y
	
	tweenPanelError = create_tween()
	tweenPanelError.tween_property(panelError,"position",targetPos, .5)
	print("Show")
	await tweenPanelError.finished
	
	timerIsRunning = true
	timer.start(timeToReconect)
	
func _AnimHidePanelError():
	timerIsRunning = false
	timer.stop()
	animBttomColor.stop()
	
	var targetPos : Vector2 = panelError.position
	targetPos.y = panelError.size.y
	
	tweenPanelError = create_tween()
	tweenPanelError.tween_property(panelError,"position",targetPos, .5)
	
	await tweenPanelError.finished
	
	panelError.hide()

func PlayAnimation(_color:Color,_speed:float):
	tween = create_tween().set_loops(0)
	tween.tween_property(nivelBg,"self_modulate",animColor,_speed)
	tween.tween_property(nivelBg,"self_modulate",_color,_speed)
	
func StopAnimation():
	if tween:
		if tween.is_running(): tween.kill()
