class_name GDs_EP_GetAllEstaciones_Debug
extends Node

@export var estacionesLocal: GDs_CR_LocalEstaciones

func GetDebugEstaciones()-> Array[GDs_Data_EP_Estacion]:
	var estaciones : Array[GDs_Data_EP_Estacion]
	#Llenar array con valores Random
	#var idx = 0
	for idx in estacionesLocal.LocalEstaciones.size():
		var estacion : GDs_Data_EP_Estacion
		estacion.id = estacionesLocal.LocalEstaciones[idx].id
		estacion.nombre = estacionesLocal.LocalEstaciones[idx].nombre
		estacion.estado = estacionesLocal.LocalEstaciones[idx].estado
		estacion.fecha = Time.get_datetime_string_from_system()
		estacion.nivel = randf_range(0.0,80)
		estacion.pptn_pluvial = randf_range(0.0,20)
		estacion.humedad = randf_range(0.0,100)
		estacion.evaporacion = randf_range(0.0,20)
		estacion.intsdad_viento = randf_range(0.0,20)
		estacion.temperatura = randf_range(-3,40)
		estacion.dir_viento = randf_range(0,360)
		
		estacion.disp_utr = randi() % 2 == 0
		estacion.fallo_alim_ac = randi() % 2 == 0
		estacion.volt_bat_resp = randf_range(20.0,25.4)
		
		estacion.enlace = randi() % 2 == 0
		estacion.energia_electrica = randi() % 2 == 0
		estacion.rebasa_nvls_presa = estacion.nivel >= estacionesLocal.LocalEstaciones[idx].nivelPrev
		estacion.rebasa_tlrncia_prep_pluv = estacion.pptn_pluvial >= estacionesLocal.LocalEstaciones[idx].tlrncia_prep_pluv
		
		estaciones.append(estacion)
	
	return estaciones
