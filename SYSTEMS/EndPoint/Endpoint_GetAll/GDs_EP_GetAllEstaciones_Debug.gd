class_name GDs_EP_GetAllEstaciones_Debug extends Node

@export var estacionesLocal: GDs_CR_LocalEstaciones

func GetEstaciones_Random()-> Array[GDs_Data_EP_Estacion]:
	var estaciones : Array[GDs_Data_EP_Estacion]
	#Llenar array con valores Random
	for idx in estacionesLocal.LocalEstaciones.size():
		var estacionRndValues = {
		"id" : idx + 1,
		"fecha": Time.get_datetime_string_from_system(),
		"nivel": randf_range(0.0,80),
		"prtcion_pluvial": randf_range(0.0,20),
		"humedad": randf_range(0.0,100),
		"evaporacion": randf_range(0.0,20),
		"intsdad_viento": randf_range(0.0,20),
		"dir_viento": randf_range(0,360),
		"temperatura": randf_range(-3,40),
		
		"disp_utr": randi() % 2 == 0,
		"fallo_alim_ac": randi() % 2 == 0,
		"volt_bat_resp": randf_range(20.0,25.4),
		
		"enlace": randi() % 2 == 0,
		"energia_electrica": randi() % 2 == 0,
		"rebasa_nvls_presa": randi() % 2 == 0,
		"rebasa_tlrncia_prep_pluv": randi() % 2 == 0
		}

		var estacion : GDs_Data_EP_Estacion = GDs_Data_EP_Estacion.new(estacionRndValues)
		estacion.rebasa_nvls_presa = estacion.nivel >= estacionesLocal.LocalEstaciones[idx].nivelPrev
		estacion.rebasa_tlrncia_prep_pluv = estacion.pptn_pluvial >= estacionesLocal.LocalEstaciones[idx].tlrncia_prep_pluv
		
		estaciones.append(estacion)
		
	return estaciones
