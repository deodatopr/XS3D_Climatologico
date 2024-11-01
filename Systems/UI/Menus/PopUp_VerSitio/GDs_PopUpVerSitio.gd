class_name GDs_PopUpVerSitio
extends Control

@export var btnAceptar:Button
@export var btnAceptarHighlight:Control
@export var btnCancelar:Button
@export var btnCancelarHighlight:Control
@export var btnWarning:Button
@export var WarningAnim:AnimationPlayer
@export var WarningSound:AudioStreamPlayer

signal OnCancelarVerSitio

func _ready():
	btnAceptar.mouse_entered.connect(OnAceptarFocus)
	btnAceptar.mouse_exited.connect(OnAceptarFocusExited)
	
	btnCancelar.mouse_entered.connect(OnCancelarFocus)
	btnCancelar.mouse_exited.connect(OnCancelarFocusExited)
	
	btnAceptar.pressed.connect(OnAceptar)
	btnCancelar.pressed.connect(OnCancelar)
	
	btnWarning.pressed.connect(OnWarningPressed)
	visibility_changed.connect(OnVisibleChanged)

func _input(event):
	if visible:
		if event.is_action_pressed("ui_accept"):
			OnAceptar()
		elif event.is_action_pressed("ui_cancel"):
			OnCancelar()
		else:
			OnWarningPressed()

func OnVisibleChanged():
	if visible:
		APPSTATE.popUpOpened = true
	else:
		APPSTATE.popUpOpened = false

func OnWarningPressed():
	if not WarningAnim.is_playing():
		WarningAnim.play("PopUp Warning")
		WarningSound.play()

func OnAceptar():
	pass

func OnAceptarFocus():
	btnAceptarHighlight.show()

func OnAceptarFocusExited():
	btnAceptarHighlight.hide()

func OnCancelar():
	hide()
	OnCancelarVerSitio.emit()

func OnCancelarFocus():
	btnCancelarHighlight.show()

func OnCancelarFocusExited():
	btnCancelarHighlight.hide()
