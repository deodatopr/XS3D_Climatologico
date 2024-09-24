class_name GDs_EP_GetAllEstaciones_Debug
extends Node

@export var estacionesLocal: GDs_CR_LocalEstaciones

#FIXME: BORRAR DESPUES DE IMPLEMENTA ORQUESTADOR
var estaciones_Estruc_Todas : GDs_Data_Estaciones_Estructura
var estaciones_Estruc_Mexico : GDs_Data_Estaciones_Estructura
var estaciones_Estruc_Michoacan : GDs_Data_Estaciones_Estructura

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
	
	#FIXME: BORRAR DESPUES DE IMPLEMENTA ORQUESTADOR
	_FillStructure(estaciones, estaciones_Estruc_Todas)
	_FillStructure(estaciones, estaciones_Estruc_Mexico, ENUMS.Estado.Mexico)
	_FillStructure(estaciones, estaciones_Estruc_Michoacan,ENUMS.Estado.Michoacan)
	return estaciones
	
#FIXME: BORRAR DESPUES DE IMPLEMENTA ORQUESTADOR
func _FillStructure(_estaciones : Array[GDs_Data_Estacion] ,_estaciones_Estruc : GDs_Data_Estaciones_Estructura, _estado : int = -1):
	_estaciones_Estruc.estaciones.clear()
	
	var alrmEnlace := 0
	var alrmEnergiaElectrica := 0
	var alrmRebasaNvlsPresa := 0
	var alrmRebasaTlrnciaPrepPluv := 0
	
	for estacion in _estaciones:
		if _estado == -1 || _estado == estacion.estado:
			#Count alarms
			if estacion.enlace: alrmEnlace+=1
			if estacion.energia_electrica: alrmEnergiaElectrica+=1
			if estacion.rebasa_nvls_presa: alrmRebasaNvlsPresa+=1
			if estacion.rebasa_tlrncia_prep_pluv: alrmRebasaTlrnciaPrepPluv+=1
			
			#Set struct data
			_estaciones_Estruc.alrmEnlace = alrmEnlace
			_estaciones_Estruc.alrmEnergiaElectrica = alrmEnergiaElectrica
			_estaciones_Estruc.alrmRebasaNvlsPresa = alrmRebasaNvlsPresa
			_estaciones_Estruc.alrmRebasaTlrnciaPrepPluv = alrmRebasaTlrnciaPrepPluv
			_estaciones_Estruc.estaciones.append(estacion)
