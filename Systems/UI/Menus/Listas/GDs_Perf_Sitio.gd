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
@export var OnColor:Color
@export var OffColor:Color
@export_subgroup("Nivel")
@export var nivel:Label
@export var nivelBg:Control
@export var nivelNorm:Label
@export var nivelPrev:Label
@export var nivelCrit:Label
@export var ColorNorm:Color
@export var ColorPrev:Color
@export var ColorCrit:Color
@export_subgroup("Datos")
@export var precipitacion:Label
@export var humedad:Label
@export var evaporacion:Label
@export var temp:Label
@export var presion:Label
@export var viento:Label

var estacion:GDs_Data_Estacion

signal OnSitioPressed(GDs_Data_Estacion) 
var tween:Tween

var whiteBlur := Color.WHITE
var transparent: Color 
var pressed:= false

func _ready():
	transparent = whiteBlur
	transparent.a = 0
	button.pressed.connect(OnBtnPressed)
	button.focus_entered.connect(ScaleUp)
	button.mouse_entered.connect(ScaleUp)
	button.focus_exited.connect(ScaleDown)
	button.mouse_exited.connect(ScaleDown)

func DataRefresh(_estacion: GDs_Data_Estacion):
	estacion = _estacion
	frame.self_modulate = _estacion.color
	frameNombre.self_modulate = _estacion.color
	patch.self_modulate = _estacion.color
	id.text = str(_estacion.id)
	nombre.text = _estacion.nombre
	estado.text = UTILITIES.FormatEstado(_estacion.estado)
	
	#Senales
	if _estacion.enlace:
		senal.self_modulate = OnColor
	else:
		senal.self_modulate = OffColor
	if _estacion.disp_utr:
		UTR.self_modulate = OnColor
	else:
		UTR.self_modulate = OffColor
	
	#nivel
	nivel.text = UTILITIES.FormatNivel(_estacion.nivel)
	nivelPrev.text = UTILITIES.FormatNiveles(_estacion.nivelPrev)
	nivelCrit.text = UTILITIES.FormatNiveles(_estacion.nivelCrit)
	
	nivelBg.self_modulate = ColorNorm
	if _estacion.nivel > _estacion.nivelPrev: nivelBg.self_modulate = ColorPrev
	if _estacion.nivel > _estacion.nivelCrit: nivelBg.self_modulate = ColorCrit
	
	#Datos
	precipitacion.text = UTILITIES.FormatPptn_pluvial(_estacion.pptn_pluvial)
	humedad.text = UTILITIES.FormatHumedad(_estacion.humedad)
	evaporacion.text = UTILITIES.FormatEvaporacion(_estacion.evaporacion)
	temp.text = UTILITIES.FormatTemperatura(_estacion.temperatura)
	presion.text = UTILITIES.FormatPresion(_estacion.temperatura)#TODO cambiar por presion
	viento.text = UTILITIES.FormatIntensidadViento(_estacion.intsdad_viento)#TODO sistema para que regrese N S E O

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
