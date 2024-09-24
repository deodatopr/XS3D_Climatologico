class_name GDs_Utilities
extends Node

func TurnOffObject(object):
	object.hide()
	object.process_mode = Node.PROCESS_MODE_DISABLED

func TurnOnObject(object):
	object.show()
	object.process_mode = Node.PROCESS_MODE_INHERIT

#region Formato strings
func FormatNivel(nivel:float)->String:
	return str(nivel) + "m"

func FormatPptn_pluvial(pptn:float)->String:
	return str(pptn) + "mm"

func FormatHumedad(humedad:float)->String:
	return str(humedad) + "%"
	
func FormatEvaporacion(evaporacion:float)->String:
	return str(evaporacion) + "mm"

func FormatIntensidadViento(viento:float)->String:
	return str(viento) + "km/hr"

func FormatTemperatura(temp:float)->String:
	return str(temp) + "°C"

func FormatDirViento(dir:float)->String:
	return str(dir) + "°"

func FormatBateriaV(volt:float)->String:
	return str(volt) + "V"
#endregion
