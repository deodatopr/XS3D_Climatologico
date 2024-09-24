extends Resource

class_name GDs_CR_LocalEstaciones

@export var LocalEstaciones : Array[GDs_Data_Local_Estacion] = []

func GetEstacion(idEstacion : int) -> GDs_Data_Local_Estacion:
	for estacion in LocalEstaciones:
		if estacion.id == idEstacion:
			return estacion
	
	return null
