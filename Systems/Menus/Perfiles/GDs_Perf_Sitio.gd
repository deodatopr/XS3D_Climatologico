class_name GDs_Perf_Sitio
extends Control

@export var button:Button
@export_group("Focus Animation")
@export var animScaleNode:Control
@export var scaleScale:Vector2
@export var blurBG:Control
@export_group("Data Refresh")
@export var frame:Control
@export var frameNombre:Control
@export var patch:Control


signal OnSitioPressed 
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
	frame.self_modulate = _estacion.color
	frameNombre.self_modulate = _estacion.color
	patch.self_modulate = _estacion.color


func OnBtnPressed():
	OnSitioPressed.emit()
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
	pressed = false
