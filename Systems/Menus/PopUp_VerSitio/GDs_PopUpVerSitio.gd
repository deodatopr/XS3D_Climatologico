class_name GDs_PopUpVerSitio
extends Control

@export var btnAceptar:Button
@export var btnCancelar:Button

signal OnCancelarVerSitio


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
	
