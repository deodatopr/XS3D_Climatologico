class_name GDs_EP_GetAllEstaciones_Debug extends Node

const ultFechaConInfo : String = "2024-09-11T18:32:17"

var CR_LocalEstaciones: GDs_CR_LocalEstaciones

func Initialize(_CR_LocalEstaciones: GDs_CR_LocalEstaciones):
	CR_LocalEstaciones =_CR_LocalEstaciones

func GetEstaciones_Random()-> Array[GDs_Data_EP_Estacion]:
	var estaciones : Array[GDs_Data_EP_Estacion]
	
	var fecha : String
	var utr : bool
	var enlace : bool
	var nvlBateria : float
	var bateriaConCarga : bool
	var temperatura : float
	var humedad : float
	var evaporacion : float
	var precipitacion : float
	var presionAtm : float
	var viento : float
	var nivel : float
	
		
	var humd_bajo_min : float = 0.0
	var humd_bajo_max : float = 70.0
	var humd_alto_min : float = 71.0
	var humd_alto_max : float = 100.0
	
		
	var evap_bajo_min : float = 0.0
	var evap_bajo_max : float = 5.0
	var evap_alto_min : float = 6.0
	var evap_alto_max : float = 10.0
	
	var psnAtm_bajo_min : float = 950.0
	var psnAtm_bajo_max : float = 1000.0
	var psnAtm_alto_min : float = 1001.0
	var psnAtm_alto_max : float = 1050.0
	
	#Llenar array con valores Random
	for idx in CR_LocalEstaciones.LocalEstaciones.size():
		nvlBateria = randf_range(20.0, 25.4)
		
		#De acuerdo a documento si tiene 23.2 es que está descargada
		bateriaConCarga = nvlBateria > 23.2
		enlace = randi() % 2 == 0 if bateriaConCarga else false
		utr = randi() % 2 == 0 if bateriaConCarga else false
		
		var tengoDatos : bool =  bateriaConCarga and utr
		
		fecha = Time.get_datetime_string_from_system() if utr else ultFechaConInfo
		
		#Temperatura -> (humedad y evaporacion)
		temperatura = randf_range(0.0, 35.0) if tengoDatos else NAN
		var temperaturaAlta : bool = temperatura > 20.0
		if tengoDatos and temperaturaAlta:
			humedad = randf_range(humd_alto_min, humd_alto_max)
			evaporacion =  randf_range(evap_alto_min, evap_alto_max)
		elif tengoDatos and not temperaturaAlta:
			humedad = randf_range(humd_bajo_min, humd_bajo_max)
			evaporacion =  randf_range(evap_bajo_min, evap_bajo_max)
		else:
			humedad = NAN
			evaporacion =  NAN
			
		#Precipitacion -> (Presion atm y evaporacion)
		precipitacion = randf_range(0.0, 50.0) if tengoDatos else NAN
		var precipitacionAlta : bool = precipitacion > 20.0
		if tengoDatos and precipitacionAlta:
			presionAtm = randf_range(psnAtm_bajo_min, psnAtm_bajo_max)
			evaporacion -= randf_range(1,3)
		elif tengoDatos and not precipitacionAlta:
			presionAtm = randf_range(psnAtm_alto_min, psnAtm_alto_max)
		else:
			presionAtm = NAN

		#Viento -> (Presión y evaporacion)
		viento = randf_range(0.0, 60.0) if tengoDatos else NAN
		var vientoAlto : bool = viento > 30.0
		if tengoDatos and vientoAlto:
			presionAtm -= randf_range(5.0, 15.0)
			evaporacion += randf_range(1.0,3.0)
		else:
			presionAtm += randf_range(5.0, 15.0)
		
		
		nivel = randf_range(0.0,80.0) if tengoDatos else NAN
		
		var estacionRndValues = {
		"id" : idx + 1,
		"fecha": fecha,
		"volt_bat_resp": nvlBateria,
		"enlace": enlace,
		"disp_utr": utr,
		
		"prtcion_pluvial": precipitacion,
		"presion" : presionAtm,
		
		"temperatura": temperatura,
		"humedad": humedad,
		"evaporacion": evaporacion,
		"intsdad_viento": viento,
		
		"dir_viento": randf_range(0,360),
		
		"nivel": nivel,

		"fallo_alim_ac": randi() % 2 == 0,
		"energia_electrica": randi() % 2 == 0,
		"rebasa_nvls_presa": randi() % 2 == 0,
		"rebasa_tlrncia_prep_pluv": randi() % 2 == 0
		}
		var estacion : GDs_Data_EP_Estacion = GDs_Data_EP_Estacion.new(estacionRndValues)
		estacion.rebasa_nvls_presa = estacion.nivel >= CR_LocalEstaciones.LocalEstaciones[idx].nivelPrev
		estacion.rebasa_tlrncia_prep_pluv = estacion.pptn_pluvial >= CR_LocalEstaciones.LocalEstaciones[idx].tlrncia_prep_pluv

		estaciones.append(estacion)
		
	return estaciones
	
	
