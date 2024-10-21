class_name GDs_Utilities extends Node

var currentCurvValue : float

func TurnOffObject(object):
	object.hide()
	object.process_mode = Node.PROCESS_MODE_DISABLED

func TurnOnObject(object):
	object.show()
	object.process_mode = Node.PROCESS_MODE_INHERIT
	
func _GetCurvePoint(_curveToEvaluate : Curve, _speedTransition : float, _delta: float, _reverse : bool = false) -> float:
	if _reverse:
		currentCurvValue -= _speedTransition * _delta
	else:
		currentCurvValue += _speedTransition * _delta
	
	currentCurvValue = clampf(currentCurvValue,0,1)
	return _curveToEvaluate.sample(currentCurvValue) 

#region Formato strings
func FormatNivel(nivel:float)->String:
	nivel = roundf(nivel)
	return str(nivel) + "m"

func FormatPptn_pluvial(pptn:float)->String:
	pptn = roundf(pptn)
	return str(pptn) + "mm"

func FormatHumedad(humedad:float)->String:
	humedad = roundf(humedad)
	return str(humedad) + "%"
	
func FormatEvaporacion(evaporacion:float)->String:
	evaporacion = roundf(evaporacion)
	return str(evaporacion) + "mm"

func FormatIntensidadViento(viento:float)->String:
	viento = roundf(viento)
	return str(viento) + "km/hr"

func FormatTemperatura(temp:float)->String:
	temp = roundf(temp)
	return str(temp) + "°C"

func FormatDirViento(dir:float)->String:
	dir = roundf(dir)
	return str(dir) + "°"

func FormatBateriaV(volt:float)->String:
	volt = roundf(volt)
	return str(volt) + "V"
#endregion
