class_name GDs_DebugEstaciones
extends Node

@export var estacionesLocal: GDs_CR_LocalEstaciones

func GetDebugEstaciones()-> Array[GDs_Data_Estacion]:
	var estaciones : Array[GDs_Data_Estacion]
	estaciones.resize(estacionesLocal.LocalEstaciones.size())
	
	#Llenar array con valores Random
	var idx = 0
	for estacion in estaciones:
		estacion.id = estacionesLocal.LocalEstaciones[idx].id
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
		
		idx+=1
	return estaciones
