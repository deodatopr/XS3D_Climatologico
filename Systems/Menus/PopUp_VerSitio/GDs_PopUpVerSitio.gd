class_name GDs_PopUpVerSitio
extends Control

@export var btnAceptar:Button
@export var btnAceptarHighlight:Control
@export var btnCancelar:Button
@export var btnCancelarHighlight:Control

signal OnCancelarVerSitio

func _ready():
	btnAceptar.mouse_entered.connect(OnAceptarFocus)
	btnAceptar.mouse_exited.connect(OnAceptarFocusExited)
	
	btnCancelar.mouse_entered.connect(OnCancelarFocus)
	btnCancelar.mouse_exited.connect(OnCancelarFocusExited)
	
	btnAceptar.pressed.connect(OnAceptar)
	btnCancelar.pressed.connect(OnCancelar)

func _input(event):
	if visible:
		if event.is_action_pressed("ui_accept"):
			OnAceptar()
		if event.is_action_pressed("ui_cancel"):
			OnCancelar()

func OnAceptar():
	pass

func OnCancelar():
	hide()
	OnCancelarVerSitio.emit()

func OnAceptarFocus():
	btnAceptarHighlight.show()

func OnAceptarFocusExited():
	btnAceptarHighlight.hide()

func OnCancelarFocus():
	btnCancelarHighlight.show()

func OnCancelarFocusExited():
	btnCancelarHighlight.hide()
