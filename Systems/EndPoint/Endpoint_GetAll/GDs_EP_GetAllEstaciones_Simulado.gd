class_name GDs_EP_GetAllEstaciones_Simulado extends Node

const ultFechaConInfo : String = "2024-09-11T18:32:17"

var CR_LocalEstaciones: GDs_CR_LocalEstaciones

func Initialize(_CR_LocalEstaciones: GDs_CR_LocalEstaciones):
	CR_LocalEstaciones =_CR_LocalEstaciones

func GetEstaciones() -> Array[GDs_Data_EP_Estacion]:
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
	var dir_viento : int
	var nivel : float
	var sensores : bool
	
	var temp_bajo_min : float = 10.0
	var temp_bajo_max : float = 20.0
	var temp_alto_min : float = 21.0
	var temp_alto_max : float = 35.0
	
	var pptc_bajo_min : float = 2.0
	var pptc_bajo_max : float = 19.0
	var pptc_alto_min : float = 20.0
	var pptc_alto_max : float = 50.0
	
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
	var idx : int = 0
	for sitioCR in CR_LocalEstaciones.LocalEstaciones:
		match DEBUG.bateria:
			ENUMS.Dbg_Bateria._100:
				nvlBateria = 25.4
			ENUMS.Dbg_Bateria._75:
				nvlBateria = 25.0
			ENUMS.Dbg_Bateria._50:
				nvlBateria = 24.4
			ENUMS.Dbg_Bateria._25:
				nvlBateria = 24.0
			ENUMS.Dbg_Bateria._0:
				nvlBateria = 23.2
		
		#De acuerdo a documento si tiene 23.2 es que está descargada
		bateriaConCarga = nvlBateria > 23.2
		utr = bateriaConCarga
		enlace = bateriaConCarga
		sensores = bateriaConCarga
		var tengoDatos : bool =  bateriaConCarga and sensores and utr and enlace
		
		fecha = Time.get_datetime_string_from_system() if utr else ultFechaConInfo
		
		#Temperatura -> (humedad y evaporacion)
		match DEBUG.temperatura:
			ENUMS.Dbg_Temperatura.Normal:
				temperatura = randf_range(temp_bajo_min, temp_bajo_max)
			ENUMS.Dbg_Temperatura.Calida:
				temperatura = randf_range(temp_alto_min, temp_alto_max)
		temperatura = temperatura if tengoDatos else NAN
		
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
		match DEBUG.lLuvia:
			ENUMS.Dbg_ModoLluvia.SinLLuvia:
				precipitacion = 0.0
			ENUMS.Dbg_ModoLluvia.LLuviaModerada:
				precipitacion = randf_range(pptc_bajo_min,pptc_bajo_max)
			ENUMS.Dbg_ModoLluvia.LluviaIntensa:
				precipitacion = randf_range(pptc_alto_min,pptc_alto_max)
				
		precipitacion = precipitacion if tengoDatos else NAN
		var precipitacionAlta : bool = precipitacion > 20.0
		if tengoDatos and precipitacionAlta:
			presionAtm = randf_range(psnAtm_bajo_min, psnAtm_bajo_max)
			evaporacion -= maxf(randf_range(1,3),0)
		elif tengoDatos and not precipitacionAlta:
			presionAtm = randf_range(psnAtm_alto_min, psnAtm_alto_max)
		else:
			presionAtm = NAN

		#Viento -> (Presión y evaporacion)
		viento = randf_range(0.0, 60.0) if tengoDatos else NAN
		dir_viento = randi_range(0,360) if tengoDatos else NAN
		
		var vientoAlto : bool = viento > 30.0
		if tengoDatos and vientoAlto:
			presionAtm -= maxf(randf_range(5.0, 15.0),0.0)
			evaporacion += randf_range(1.0,3.0)
		else:
			presionAtm += randf_range(5.0, 15.0)
		
		match DEBUG.alarmas:
			ENUMS.Dbg_Alarmas.Normal:
				nivel = randf_range(0,sitioCR.nivelNormal)
			ENUMS.Dbg_Alarmas.Prev:
				nivel = randf_range(sitioCR.nivelPrev,sitioCR.nivelCrit - 1)
			ENUMS.Dbg_Alarmas.Critico:
				nivel = randf_range(sitioCR.nivelCrit, sitioCR.nivelCrit + 5)
			
		nivel = nivel if tengoDatos else NAN
		
		var estacionRndValues = {
		"id" : idx + 1,
		"fecha": fecha,
		"volt_bat_resp": nvlBateria,
		"enlace": enlace,
		"disp_utr": utr,
		"sensores": sensores,
		
		"prtcion_pluvial": precipitacion,
		"presion" : presionAtm,
		
		"temperatura": temperatura,
		"humedad": humedad,
		"evaporacion": evaporacion,
		"intsdad_viento": viento,
		
		"dir_viento": dir_viento,
		
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
		idx+=1
		
	return estaciones