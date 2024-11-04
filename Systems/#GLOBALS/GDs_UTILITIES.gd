class_name GDs_Utilities extends Node

func TurnOffObject(object):
	object.hide()
	object.process_mode = Node.PROCESS_MODE_DISABLED

func TurnOnObject(object):
	object.show()
	object.process_mode = Node.PROCESS_MODE_INHERIT
	
func GetNodeBounds(_root : Node) -> AABB:
	var total_aabb = AABB()
	if _root != null:
		for node in _root.get_children():
			if node is MeshInstance3D:
				total_aabb = total_aabb.merge(node.get_aabb())
	return total_aabb
	
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
	return str(viento) + "km/h"

func FormatTemperatura(temp:float)->String:
	temp = roundf(temp)
	return str(temp) + "°C"

func FormatPresion(temp:float)->String:
	temp = roundf(temp)
	return str(temp) + "hPa"

func FormatDirViento(dir:float)->String:
	dir = roundf(dir)
	return str(dir) + "°"

func FormatBateriaV(volt:float)->String:
	volt = roundf(volt)
	return str(volt) + "V"

func FormatAltura(altura:int)->String:
	return str(altura) + "m"
	
func FormatVelocidad(vel:int)->String:
	return str(vel) + " km/h"
	
func FormatRotacionXY(rot:Vector2)->String:
	return "("+ str(rot.x) + "°," + str(rot.y) +"°)"
	
func FormatRotacionY(rot:float)->String:
	return str(rot) + "°"

func FormatFov(fov:float)->String:
	return str(fov) + "°"

func FormatEstado(estado:int)->String:
	if estado == 0:
		return "EDOMEX"
	else:
		return "MICH"
#endregion
