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
	
	var temp_normal_min : float = 5.0
	var temp_normal_max : float = CONST.thrshld_temperatura_calida - 1.0
	var temp_calido_min : float = CONST.thrshld_temperatura_calida
	var temp_calido_max : float = CONST.thrshld_temperatura_alta - 1.0
	var temp_alto_min : float = CONST.thrshld_temperatura_alta
	var temp_alto_max : float = CONST.thrshld_temperatura_alta + 15.0
	
	var pptc_bajo_min : float = 2.0
	var pptc_bajo_max : float = CONST.thrshld_pptcn_lluvia_moderada - 1
	var pptc_alto_min : float = CONST.thrshld_pptcn_lluvia_moderada 
	var pptc_alto_max : float = CONST.thrshld_pptcn_lluvia_intensa 
	
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
			ENUMS.Bateria._100:
				nvlBateria = 25.4
			ENUMS.Bateria._75:
				nvlBateria = 25.0
			ENUMS.Bateria._50:
				nvlBateria = 24.4
			ENUMS.Bateria._25:
				nvlBateria = 24.0
			ENUMS.Bateria._0:
				nvlBateria = 23.2
		
		#De acuerdo a documento si tiene 23.2 es que está descargada
		bateriaConCarga = nvlBateria > CONST.thrshld_bateria_conCarga
		utr = bateriaConCarga
		enlace = bateriaConCarga
		sensores = bateriaConCarga
		var tengoDatos : bool =  bateriaConCarga and sensores and utr and enlace
		
		fecha = Time.get_datetime_string_from_system() if utr else ultFechaConInfo
		
		#Temperatura -> (humedad y evaporacion)
		match DEBUG.temperatura:
			ENUMS.Temperatura.Normal:
				temperatura = randf_range(temp_normal_min, temp_normal_max)
			ENUMS.Temperatura.Calida:
				temperatura = randf_range(temp_calido_min, temp_calido_max)
			ENUMS.Temperatura.Alta:
				temperatura = randf_range(temp_alto_min, temp_alto_max)
		temperatura = temperatura if tengoDatos else NAN
		
		var temperaturaAlta : bool = temperatura > CONST.thrshld_temperatura_alta
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
			ENUMS.LluviaIntsdad.Nada:
				precipitacion = 0.0
			ENUMS.LluviaIntsdad.Moderada:
				precipitacion = randf_range(pptc_bajo_min,pptc_bajo_max)
			ENUMS.LluviaIntsdad.Intensa:
				precipitacion = randf_range(pptc_alto_min,pptc_alto_max)
				
		precipitacion = precipitacion if tengoDatos else NAN
		var precipitacionAlta : bool = precipitacion > CONST.thrshld_pptcn_lluvia_intensa
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
		
		var vientoAlto : bool = viento > CONST.thrshld_vnto_fuerte
		if tengoDatos and vientoAlto:
			presionAtm -= maxf(randf_range(5.0, 15.0),0.0)
			evaporacion += randf_range(1.0,3.0)
		else:
			presionAtm += randf_range(5.0, 15.0)
		
		match DEBUG.alarmas:
			ENUMS.Alarmas.Normal:
				nivel = randf_range(0,sitioCR.nivelNormal)
			ENUMS.Alarmas.Prev:
				nivel = randf_range(sitioCR.nivelPrev,sitioCR.nivelCrit - 1)
			ENUMS.Alarmas.Critico:
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
