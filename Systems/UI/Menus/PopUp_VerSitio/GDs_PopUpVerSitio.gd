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
@export var animPlayer:AnimationPlayer

@export_group("No Disponible")
@export var lblNoDisp:Control
@export var parentAceptar:Control


signal OnCancelarVerSitio
var estacion:GDs_Data_Sitio
var currentSitioId : int = -1

func _ready():
	btnAceptar.mouse_entered.connect(OnAceptarFocus)
	btnAceptar.mouse_exited.connect(OnAceptarFocusExited)
	
	btnCancelar.mouse_entered.connect(OnCancelarFocus)
	btnCancelar.mouse_exited.connect(OnCancelarFocusExited)
	
	btnAceptar.pressed.connect(OnAceptar)
	btnCancelar.pressed.connect(OnCancelar)
	
	visibility_changed.connect(OnVisibleChanged)

func _input(event):
	if visible and not APPSTATE.panelErrorOpened:
		if event.is_action_pressed("ui_accept"):
			OnAceptar()
		elif event.is_action_pressed("ui_cancel"):
			OnCancelar()

func OpenPopUp(_estacion:GDs_Data_Sitio):
	show()
	estacion = _estacion
	currentSitioId = _estacion.id
	id.text = str(currentSitioId)
	nombre.text = _estacion.nombre
	frame.self_modulate = _estacion.color
	framePatch.self_modulate = _estacion.color
	
	if estacion.disponible:
		lblNoDisp.hide()
		parentAceptar.show()
	else:
		lblNoDisp.show()
		parentAceptar.hide()

func OnVisibleChanged():
	if visible:
		APPSTATE.popUpOpened = true
		animPlayer.play("PopUp Warning")
		
	else:
		APPSTATE.popUpOpened = false
		animPlayer.stop()

func OnAceptar():
	if estacion.disponible:
		APPSTATE.popUpOpened = false
		APPSTATE.menuUIOptionIsOpened = false
		SIGNALS.OnGoToSitio.emit(currentSitioId)
		

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
