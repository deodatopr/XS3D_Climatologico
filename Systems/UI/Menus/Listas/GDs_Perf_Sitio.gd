class_name GDs_Perf_Sitio
extends Control

@export var button:Button
@export_group("Focus Animation")
@export var animScaleNode:Control
@export var scaleScale:Vector2
@export var blurBG:Control
@export_group("Data Refresh")
@export_subgroup("Color, ID & Nombre")
@export var frame:Control
@export var frameNombre:Control
@export var patch:Control
@export var id:Label
@export var nombre:Label
@export var estado:Label
@export_subgroup("Senales")
@export var senal:Control
@export var UTR:Control
@export var falloAC:Control
@export var lblBateria:Label
@export var bateriaRelleno:Control
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

var estacion:GDs_Data_Sitio

signal OnSitioPressed(GDs_Data_Sitio) 
var tween:Tween

var whiteBlur := Color.WHITE
var transparent: Color 
var pressed:= false

func _ready():
	bateriaColorNorm = bateriaRelleno.self_modulate
	transparent = whiteBlur
	transparent.a = 0
	button.pressed.connect(OnBtnPressed)
	button.focus_entered.connect(ScaleUp)
	button.mouse_entered.connect(ScaleUp)
	button.focus_exited.connect(ScaleDown)
	button.mouse_exited.connect(ScaleDown)

func DataRefresh(_estacion: GDs_Data_Sitio):
	estacion = _estacion
	frame.self_modulate = _estacion.color
	frameNombre.self_modulate = _estacion.color
	patch.self_modulate = _estacion.color
	id.text = str(_estacion.id)
	nombre.text = _estacion.nombre
	estado.text = UTILITIES.FormatEstado(_estacion.estado)
	
	#Senales
	if _estacion.ac:
		falloAC.self_modulate = OffColor
	else:
		falloAC.self_modulate = OnColor
	if _estacion.enlace:
		senal.self_modulate = OnColor
	else:
		senal.self_modulate = OffColor
	if _estacion.utr:
		UTR.self_modulate = OnColor
	else:
		UTR.self_modulate = OffColor
	
	match _estacion.volt:
		25.4:#100%
			bateriaRelleno.scale = Vector2(1.0,1.0)
			bateriaRelleno.self_modulate =  bateriaColorNorm
		25.0:#75%
			bateriaRelleno.scale = Vector2(1.0,0.75)
			bateriaRelleno.self_modulate =  bateriaColorNorm
		24.4:#50%
			bateriaRelleno.scale = Vector2(1.0,0.50)
			bateriaRelleno.self_modulate =  ColorPrev
		24.0:#25%
			bateriaRelleno.scale = Vector2(1.0,0.25)
			bateriaRelleno.self_modulate =  ColorCrit
		23.2:#0%
			bateriaRelleno.scale = Vector2(1.0,0.1)
			bateriaRelleno.self_modulate =  ColorCrit
	
	lblBateria.text = UTILITIES.FormatBateriaV(_estacion.volt)
	
	#nivel
	nivel.text = UTILITIES.FormatNivel(_estacion.presaVal)
	nivelPrev.text = UTILITIES.FormatNiveles(_estacion.nivelPrev)
	nivelCrit.text = UTILITIES.FormatNiveles(_estacion.nivelCrit)
	
	nivelBg.self_modulate = ColorNorm
	if _estacion.presaVal > _estacion.nivelPrev: nivelBg.self_modulate = ColorPrev
	if _estacion.presaVal > _estacion.nivelCrit: nivelBg.self_modulate = ColorCrit
	
	#Datos
	precipitacion.text = UTILITIES.FormatPptn_pluvial(_estacion.pcptnVal)
	precipitacionSnsr.self_modulate = OnColor 
	if not _estacion.pcptnSnsr: precipitacionSnsr.self_modulate = OffColor 
	
	humedad.text = UTILITIES.FormatHumedad(_estacion.humVal)
	humedadSnsr.self_modulate = OnColor 
	if not _estacion.humTempSnsr: humedadSnsr.self_modulate = OffColor 
	
	evaporacion.text = UTILITIES.FormatEvaporacion(_estacion.rSolVal)
	evaporacionSnsr.self_modulate = OnColor 
	if not _estacion.rSolSnsr: evaporacionSnsr.self_modulate = OffColor 
	
	temp.text = UTILITIES.FormatTemperatura(_estacion.tempVal)
	tempSnsr.self_modulate = OnColor 
	if not _estacion.humTempSnsr: tempSnsr.self_modulate = OffColor 
	
	presion.text = UTILITIES.FormatPresion(_estacion.prsnVal)
	presionSnsr.self_modulate = OnColor 
	if not _estacion.prsnSnsr: presionSnsr.self_modulate = OffColor 
	
	viento.text = UTILITIES.FormatIntensidadViento(_estacion.vntoInt)#TODO sistema para que regrese N S E O
	vientoSnsr.self_modulate = OnColor 
	if not _estacion.vntoSnsr: vientoSnsr.self_modulate = OffColor

func OnBtnPressed():
	OnSitioPressed.emit(estacion)
	pressed = true

func ScaleUp():
	button.grab_focus()
	tween = create_tween()
	tween.tween_property(animScaleNode,"scale",scaleScale,0.2)
	tween.parallel().tween_property(blurBG,"self_modulate",whiteBlur,0.2)

func ScaleDown():
	#timer para que primero le de tiempo de cambiar el booleano de pressed
	await get_tree().create_timer(0.1).timeout
	if not pressed:
		tween = create_tween()
		tween.tween_property(animScaleNode,"scale",Vector2.ONE,0.2)
		tween.parallel().tween_property(blurBG,"self_modulate",transparent,0.2)

func OnPopUpCancelar():
	if visible:
		pressed = false
