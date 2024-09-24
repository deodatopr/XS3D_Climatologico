extends Node

func _ready():
	SIGNALS.OnMapa3DInstanciated.connect(OnCheckDayTime)
	SIGNALS.OnGoToSitio.connect(OnCheckDayTime)
	
	OnCheckDayTime()
	
func OnCheckDayTime():
	#Obtener hora del dispositivo
	var dateTime = Time.get_datetime_dict_from_system()
	var hrInt =  int(dateTime["hour"])

	#Setear variables globales únicamente de este punto
	#NOTA: Si se requiere testear manualmente noche/tarde/dia, cambiar aqui esta variable "hrInt"
	STATE.hrDayTime = hrInt
	STATE.dayTimeFromOS = GetDayTime(hrInt)
	STATE.dayTime = GetDayTime(hrInt)
	
func GetDayTime(_hr : int) -> int:
	if _hr >= 7 and _hr < 17:
		#Dia
		return ENUMS.DAYTIME.DIA
	elif _hr >= 17 and _hr < 19:
		#Tarde
		return ENUMS.DAYTIME.TARDE
	else:
		#Noche
		return ENUMS.DAYTIME.NOCHE

