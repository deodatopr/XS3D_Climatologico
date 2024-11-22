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
@export var lblBateria : Label
@export var rellenoBateria : Control
@export var falloAC:Control
@export var UTR:Control
@export var senal:Control
@export var OnColor:Color
@export var OffColor:Color
var bateriaColorNorm: Color

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
	bateriaColorNorm = rellenoBateria.self_modulate
	btnReconectar.pressed.connect(_OnBtnReconectarPressed)
	timer.timeout.connect(_OnTimerTimeOut)
	panelError.hide()
	
func Initialize(_timeToReconnect : float):
	timeToReconect = _timeToReconnect

func _process(_delta):
	if timerIsRunning:
		lblTimeValue.text = str(ceili(timer.time_left))

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_OnBtnReconectarPressed()

func OnRequestFailed():
	if not panelError.visible:
		_AnimShowPaneError()
		
func OnRequestSuccess():
	if panelError.visible:
		_AnimHidePanelError()
		
func OnDataRefresh():
	var sitio : GDs_Data_Sitio = APPSTATE.currntSitio
	
	id.text = str(sitio.id)
	idframe.self_modulate = sitio.color
	nombre.text = sitio.nombre
	estado.text = UTILITIES.FormatEstado(sitio.estado)
	
	#Senales
	if sitio.ac:
		falloAC.self_modulate = OffColor
	else:
		falloAC.self_modulate = OnColor
	if sitio.enlace:
		senal.self_modulate = OnColor
	else:
		senal.self_modulate = OffColor
	if sitio.utr:
		UTR.self_modulate = OnColor
	else:
		UTR.self_modulate = OffColor
	
	match sitio.volt:
		25.4:#100%
			rellenoBateria.scale = Vector2(1.0,1.0)
			rellenoBateria.self_modulate =  bateriaColorNorm
		25.0:#75%
			rellenoBateria.scale = Vector2(1.0,0.75)
			rellenoBateria.self_modulate =  bateriaColorNorm
		24.4:#50%
			rellenoBateria.scale = Vector2(1.0,0.50)
			rellenoBateria.self_modulate =  ColorPrev
		24.0:#25%
			rellenoBateria.scale = Vector2(1.0,0.25)
			rellenoBateria.self_modulate =  ColorCrit
		23.2:#0%
			rellenoBateria.scale = Vector2(1.0,0.1)
			rellenoBateria.self_modulate =  ColorCrit
	
	lblBateria.text = UTILITIES.FormatBateriaV(sitio.volt)	

	#nivel
	nivel.text = UTILITIES.FormatNivel(sitio.presaVal)
	nivelPrev.text = UTILITIES.FormatNiveles(sitio.nivelPrev)
	nivelCrit.text = UTILITIES.FormatNiveles(sitio.nivelCrit)
	
	nivelBg.self_modulate = ColorNorm
	StopAnimation()
	var hayDatos : bool = not is_nan(sitio.presaVal)
	if hayDatos and (sitio.presaVal > sitio.nivelPrev and sitio.presaVal <= sitio.nivelCrit): 
		nivelBg.self_modulate = ColorPrev
		PlayAnimation(ColorPrev,0.4)
	if hayDatos and sitio.presaVal > sitio.nivelCrit: 
		nivelBg.self_modulate = ColorCrit
		PlayAnimation(ColorCrit,0.3)
	
	#Datos
	precipitacion.text = UTILITIES.FormatPptn_pluvial(sitio.pcptnVal)
	precipitacionSnsr.self_modulate = OnColor 
	if not sitio.pcptnSnsr: precipitacionSnsr.self_modulate = OffColor 
	
	humedad.text = UTILITIES.FormatHumedad(sitio.humVal)
	humedadSnsr.self_modulate = OnColor 
	if not sitio.humTempSnsr: humedadSnsr.self_modulate = OffColor 
	
	evaporacion.text = UTILITIES.FormatEvaporacion(sitio.rSolVal)
	evaporacionSnsr.self_modulate = OnColor 
	if not sitio.rSolVal: evaporacionSnsr.self_modulate = OffColor 
	
	temp.text = UTILITIES.FormatTemperatura(sitio.tempVal)
	tempSnsr.self_modulate = OnColor 
	if not sitio.humTempSnsr: tempSnsr.self_modulate = OffColor 
	
	presion.text = UTILITIES.FormatPresion(sitio.prsnVal)
	presionSnsr.self_modulate = OnColor 
	if not sitio.prsnSnsr: presionSnsr.self_modulate = OffColor 
	
	viento.text = UTILITIES.FormatIntensidadViento(sitio.vntoInt)#TODO sistema para que regrese N S E O
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
	#print("Show")
	await tweenPanelError.finished
	
	timerIsRunning = true
	timer.start(timeToReconect)
	APPSTATE.panelErrorOpened = true
	
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
	APPSTATE.panelErrorOpened = false

func PlayAnimation(_color:Color,_speed:float):
	tween = create_tween().set_loops(0)
	tween.tween_property(nivelBg,"self_modulate",animColor,_speed)
	tween.tween_property(nivelBg,"self_modulate",_color,_speed)
	
func StopAnimation():
	if tween:
		if tween.is_running(): tween.kill()
