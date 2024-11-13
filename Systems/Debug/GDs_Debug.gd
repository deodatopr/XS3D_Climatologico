class_name GDs_Debug extends Node

@export_enum("Endpoint", "Simulados") var modoDatos : int = 1:
	set (value):
		DEBUG.modoDatos = value
		SIGNALS.OnDebugRefresh.emit()
		
@export_group("Simulados")
@export_enum("100%", "75%","50%", "25%", "0%") var Bateria : int:
	set (value):
		DEBUG.bateria = value
		if DEBUG.modoDatos == ENUMS.ModoDatos.Simulado:
			SIGNALS.OnDebugRefresh.emit()
@export_enum("Nada", "Moderada","Intensa")var LLuvia : int:
	set (value):
		DEBUG.lLuvia = value
		if DEBUG.modoDatos == ENUMS.ModoDatos.Simulado:
			SIGNALS.OnDebugRefresh.emit()
@export_enum("Normal", "Alta")var Temperatura : int:
	set (value):
		DEBUG.temperatura = value
		if DEBUG.modoDatos == ENUMS.ModoDatos.Simulado:
			SIGNALS.OnDebugRefresh.emit()
@export_enum("Normal", "Preventivo","Critico")var Alarmas : int:
	set (value):
		DEBUG.alarmas = value
		if DEBUG.modoDatos == ENUMS.ModoDatos.Simulado:
			SIGNALS.OnDebugRefresh.emit()
			
func _init():
	DEBUG.modoDatos = modoDatos
