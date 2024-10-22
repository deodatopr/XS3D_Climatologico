class_name GDs_Perf_Sitio
extends Control

@export var button:Button

signal OnSitioPressed 

func _ready():
	button.pressed.connect(OnBtnPressed)

func OnBtnPressed():
	OnSitioPressed.emit()
