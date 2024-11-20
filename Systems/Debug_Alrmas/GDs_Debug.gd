class_name GDs_Debug extends Node

@export_enum("Endpoint", "Simulados") var modoDatos : int = 1:
	set (value):
		DEBUG.modoDatos = value
		SIGNALS.OnDebugRefresh.emit()
		
@export_group("Simulados")
@export_enum("Success","Error_NoData","Error_LastData") var endpointResult : int:
	set (value):
		DEBUG.requestResult = value
		if DEBUG.modoDatos == ENUMS.ModoDatos.Simulado:
			SIGNALS.OnDebugRefresh.emit()

@export_enum("100%", "75%","50%", "25%", "0%") var Bateria : int:
	set (value):
		DEBUG.bateria = value
		if DEBUG.modoDatos == ENUMS.ModoDatos.Simulado:
			SIGNALS.OnDebugRefresh.emit()
@export_enum("SinLluvia", "ConLluvia")var LLuvia : int = 0:
	set (value):
		DEBUG.lLuvia = value
		if DEBUG.modoDatos == ENUMS.ModoDatos.Simulado:
			SIGNALS.OnDebugRefresh.emit()
@export_enum("Normal","Calida", "Alta")var Temperatura : int:
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
	SIGNALS.OnDebugValuechangedByScript.connect(_OnDebugValuechangedByScript)
	DEBUG.modoDatos = modoDatos
	
func _OnDebugValuechangedByScript():
	endpointResult = DEBUG.requestResult
	Bateria = DEBUG.requestResult
	LLuvia = DEBUG.requestResult
	Temperatura = DEBUG.requestResult
	Alarmas = DEBUG.alarmas
	SIGNALS.OnDebugRefresh.emit()
