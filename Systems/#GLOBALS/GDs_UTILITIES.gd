class_name GDs_Utilities extends Node

const txtNoData : String = " --- "

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
func FormatFecha(fecha:String)->String:
	return "Ult. Act. : " + fecha

func FormatNivel(nivel:float)->String:
	return "Nvl: " + _ValueToText(nivel) + "m"

func FormatNiveles(nivel:float)->String:
	return _ValueToText(nivel) + "m"

func FormatPptn_pluvial(pptn:float)->String:
	return _ValueToText(pptn) + "mm"

func FormatHumedad(humedad:float)->String:
	return _ValueToText(humedad) + "%"
	
func FormatEvaporacion(evaporacion:float)->String:
	return _ValueToText(evaporacion) + "%"

func FormatIntensidadViento(viento:float)->String:
	return _ValueToText(viento) + "km/h"

func FormatTemperatura(temp:float)->String:
	return _ValueToText(temp) + "°C"

func FormatPresion(presion:float)->String:
	return _ValueToText(presion) + "hPa"

func FormatDirViento(dir:float)->String:
	return _ValueToText(dir) + "°"
		

func FormatBateriaV(volt:float)->String:
	return String.num(volt,1) + "V"

func FormatAltura(altura:int)->String:
	return str(altura) + "m"
	
func FormatVelocidad(vel:int)->String:
	return str(vel) + " km/h"
	
func FormatRotacionXY(rot:Vector2)->String:
	return "("+ str(rot.x) + "° , " + str(rot.y) +"°)"
	
func FormatRotacionY(rot:float)->String:
	return str(rot) + "°"

func FormatFov(fov:float)->String:
	return str(fov) + "°"

func FormatEstado(estado:int)->String:
	if estado == 0:
		return "EDOMEX"
	else:
		return "MICH"
		
		
func _ValueToText(_value : float) -> String:
	if is_nan(_value):
		return txtNoData
	else:
		_value = roundf(_value)
		return str(_value)
		
func FormatDateGraficadoraRango(_date : String):
	var year : String =  _date.substr(2,2)
	var month : String = _date.substr(5,2)
	var day : String = _date.substr(8,2)
	var hour : String = _date.substr(11,2)
	var minute : String = _date.substr(14,2)
	
	return str(year,"/",month,"/",day," ",hour,":",minute)
#endregion
