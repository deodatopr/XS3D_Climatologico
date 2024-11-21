class_name GDs_CR_LocalSitios extends Resource

@export var LocalEstaciones : Array[GDs_Data_Local_Sitio] = []

func GetEstacion(idEstacion : int) -> GDs_Data_Local_Sitio:
	for estacion in LocalEstaciones:
		if estacion.id == idEstacion:
			return estacion
	
	return null
