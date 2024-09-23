extends Resource

class_name GDs_CR_LocalSitios

@export var LocalSitios : Array[GDs_LocalSitio] = []

func GetSitio(idSitio : int) -> GDs_LocalSitio:
	for sitio in LocalSitios:
		if sitio.IdSitio == idSitio:
			return sitio
	
	return null
