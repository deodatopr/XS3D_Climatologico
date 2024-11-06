class_name GDs_PopUpVerSitio
extends Control

@export_group("Data Estacion")
@export var id:Label
@export var nombre:Label
@export var frame:Control
@export var framePatch:Control

@export_group("Buttons")
@export var btnAceptar:Button
@export var btnAceptarHighlight:Control
@export var btnCancelar:Button
@export var btnCancelarHighlight:Control

signal OnCancelarVerSitio
var estacion:GDs_Data_Estacion

func _ready():
	btnAceptar.mouse_entered.connect(OnAceptarFocus)
	btnAceptar.mouse_exited.connect(OnAceptarFocusExited)
	
	btnCancelar.mouse_entered.connect(OnCancelarFocus)
	btnCancelar.mouse_exited.connect(OnCancelarFocusExited)
	
	btnAceptar.pressed.connect(OnAceptar)
	btnCancelar.pressed.connect(OnCancelar)
	
	visibility_changed.connect(OnVisibleChanged)

func _input(event):
	if visible:
		if event.is_action_pressed("ui_accept"):
			OnAceptar()
		elif event.is_action_pressed("ui_cancel"):
			OnCancelar()

func OpenPopUp(_estacion:GDs_Data_Estacion):
	show()
	estacion = _estacion
	id.text = str(_estacion.id)
	nombre.text = _estacion.nombre
	frame.self_modulate = _estacion.color
	framePatch.self_modulate = _estacion.color

func OnVisibleChanged():
	if visible:
		APPSTATE.popUpOpened = true
		
	else:
		APPSTATE.popUpOpened = false

func OnAceptar():
	pass

func OnAceptarFocus():
	btnAceptarHighlight.show()

func OnAceptarFocusExited():
	btnAceptarHighlight.hide()

func OnCancelar():
	await get_tree().create_timer(0).timeout
	hide()
	OnCancelarVerSitio.emit()

func OnCancelarFocus():
	btnCancelarHighlight.show()

func OnCancelarFocusExited():
	btnCancelarHighlight.hide()
