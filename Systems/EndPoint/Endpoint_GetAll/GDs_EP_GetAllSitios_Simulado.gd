class_name GDs_EP_GetAllSitios_Simulado extends Node

const ultFechaConInfo : String = "2024-09-11T18:32:17"

var CR_LocalEstaciones: GDs_CR_LocalSitios

func Initialize(_CR_LocalEstaciones: GDs_CR_LocalSitios):
	CR_LocalEstaciones =_CR_LocalEstaciones

func GetEstaciones_Manual() -> Array[GDs_Data_EP_Sitio]:
	var estaciones : Array[GDs_Data_EP_Sitio]
	
	@warning_ignore('unused_variable')
	var id: int
	var fch: String
	var ac: bool
	var volt: float
	var utr: bool
	var enlace: bool
	var presaSnsr: bool
	var presaVal: float
	var pcptnSnsr: bool
	var pcptnVal: float
	var prsnSnsr: bool
	var prsnVal: float
	var rSolSnsr: bool
	var rSolVal: float
	var humTempSnsr: bool
	var humVal: float
	var tempVal: float
	var vntoSnsr: bool
	var vntoInt: float
	var vntoDir: float
	
	var bateriaConCarga : bool
	
	var temp_normal_min : float = 5.0
	var temp_normal_max : float = CONST.thrshld_temperatura_calida - 1.0
	var temp_calido_min : float = CONST.thrshld_temperatura_calida
	var temp_calido_max : float = CONST.thrshld_temperatura_alta - 1.0
	var temp_alto_min : float = CONST.thrshld_temperatura_alta
	var temp_alto_max : float = CONST.thrshld_temperatura_alta + 15.0
	
	var pptc_alto_min : float = CONST.thrshld_pptcn_lluvia_intensa
	var pptc_alto_max : float = CONST.thrshld_pptcn_lluvia_intensa  + 30.0 
	
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
	
	var vnto_bajo_min : float = 5.0
	var vnto_bajo_max : float = 20.0
	var vnto_alto_min : float = 21.0
	var vnto_alto_max : float = 35.0
	
	#Llenar array con valores Random
	var idx : int = 0
	for sitioCR in CR_LocalEstaciones.LocalEstaciones:
		match DEBUG.bateria:
			ENUMS.Bateria._100:
				volt = 25.4
			ENUMS.Bateria._75:
				volt = 25.0
			ENUMS.Bateria._50:
				volt = 24.4
			ENUMS.Bateria._25:
				volt = 24.0
			ENUMS.Bateria._0:
				volt = 23.2
		
		bateriaConCarga = volt > CONST.thrshld_bateria_conCarga
		utr = bateriaConCarga
		enlace = bateriaConCarga
		presaSnsr = bateriaConCarga
		pcptnSnsr = bateriaConCarga
		prsnSnsr = bateriaConCarga
		rSolSnsr = bateriaConCarga
		humTempSnsr = bateriaConCarga
		vntoSnsr = bateriaConCarga
		
		var tengoDatos : bool =  bateriaConCarga and utr and enlace
		
		fch = Time.get_datetime_string_from_system() if utr else ultFechaConInfo
		
		#Temperatura -> (humedad y evaporacion)
		match DEBUG.temperatura:
			ENUMS.Temperatura.Normal:
				tempVal = randf_range(temp_normal_min, temp_normal_max)
			ENUMS.Temperatura.Calida:
				tempVal = randf_range(temp_calido_min, temp_calido_max)
			ENUMS.Temperatura.Alta:
				tempVal = randf_range(temp_alto_min, temp_alto_max)
		tempVal = tempVal if tengoDatos else NAN
		
		var temperaturaAlta : bool = tempVal > CONST.thrshld_temperatura_alta
		if tengoDatos and temperaturaAlta:
			humVal = randf_range(humd_alto_min, humd_alto_max)
			rSolVal =  randf_range(evap_alto_min, evap_alto_max)
		elif tengoDatos and not temperaturaAlta:
			humVal = randf_range(humd_bajo_min, humd_bajo_max)
			rSolVal =  randf_range(evap_bajo_min, evap_bajo_max)
		else:
			humVal = NAN
			rSolVal =  NAN
			
		#Precipitacion -> (Presion atm y evaporacion)
		match DEBUG.lLuvia:
			ENUMS.LluviaIntsdad.SinLluvia:
				pcptnVal = 0.0
			ENUMS.LluviaIntsdad.ConLluvia:
				pcptnVal = randf_range(pptc_alto_min,pptc_alto_max)
				
		pcptnVal = pcptnVal if tengoDatos else NAN
		var precipitacionAlta : bool = pcptnVal > CONST.thrshld_pptcn_lluvia_intensa
		if tengoDatos and precipitacionAlta:
			prsnVal = randf_range(psnAtm_bajo_min, psnAtm_bajo_max)
			rSolVal -= maxf(randf_range(1,3),0)
		elif tengoDatos and not precipitacionAlta:
			prsnVal = randf_range(psnAtm_alto_min, psnAtm_alto_max)
		else:
			prsnVal = NAN

		#Viento -> (Presión y evaporacion)
		if DEBUG.temperatura == ENUMS.Temperatura.Normal:
			vntoInt = randf_range(vnto_alto_min, vnto_alto_max) if tengoDatos else NAN
		else:
			vntoInt = randf_range(vnto_bajo_min, vnto_bajo_max) if tengoDatos else NAN
		@warning_ignore('incompatible_ternary', 'narrowing_conversion')
		vntoDir = randi_range(0,360) if tengoDatos else NAN
		
		var vientoAlto : bool = vntoInt > CONST.thrshld_vnto_fuerte
		if tengoDatos and vientoAlto:
			prsnVal -= maxf(randf_range(5.0, 15.0),0.0)
			rSolVal += randf_range(1.0,3.0)
		else:
			prsnVal += randf_range(5.0, 15.0)
		
		match DEBUG.alarmas:
			ENUMS.Alarmas.Normal:
				presaVal = randf_range(0,sitioCR.nivelNormal)
			ENUMS.Alarmas.Prev:
				presaVal = randf_range(sitioCR.nivelPrev,sitioCR.nivelCrit - 1)
			ENUMS.Alarmas.Critico:
				presaVal = randf_range(sitioCR.nivelCrit, sitioCR.nivelCrit + 5)
			
		presaVal = presaVal if tengoDatos else NAN
		
		var estacionRndValues = {
		"id" : idx + 1,
		"fch": fch,
		"ac": ac,
		"volt": volt,
		"utr": utr,
		"enlace": enlace,
		"presaSnsr": presaSnsr,
		"presaVal": presaVal,
		"pcptnSnsr": pcptnSnsr,
		"pcptnVal": pcptnVal,
		"prsnSnsr": prsnSnsr,
		"prsnVal": prsnVal,
		"rSolSnsr": rSolSnsr,
		"rSolVal": rSolVal,
		"humTempSnsr": humTempSnsr,
		"humVal": humVal,
		"tempVal": tempVal,
		"vntoSnsr": vntoSnsr,
		"vntoInt": vntoInt,
		"vntoDir": vntoDir
		}
		
		var estacion : GDs_Data_EP_Sitio = GDs_Data_EP_Sitio.new(estacionRndValues)
		estaciones.append(estacion)
		idx+=1
		
	return estaciones

func GetEstaciones_Random() -> Array[GDs_Data_EP_Sitio]:
	var estaciones : Array[GDs_Data_EP_Sitio]
	
	@warning_ignore('unused_variable')
	var id: int
	var fch: String
	var ac: bool
	var volt: float
	var utr: bool
	var enlace: bool
	var presaSnsr: bool
	var presaVal: float
	var pcptnSnsr: bool
	var pcptnVal: float
	var prsnSnsr: bool
	var prsnVal: float
	var rSolSnsr: bool
	var rSolVal: float
	var humTempSnsr: bool
	var humVal: float
	var tempVal: float
	var vntoSnsr: bool
	var vntoInt: float
	var vntoDir: float
	
	var bateriaConCarga : bool
	
	var temp_normal_min : float = 5.0
	var temp_normal_max : float = CONST.thrshld_temperatura_calida - 1.0
	var temp_calido_min : float = CONST.thrshld_temperatura_calida
	var temp_calido_max : float = CONST.thrshld_temperatura_alta - 1.0
	var temp_alto_min : float = CONST.thrshld_temperatura_alta
	var temp_alto_max : float = CONST.thrshld_temperatura_alta + 15.0
	
	var pptc_alto_min : float = CONST.thrshld_pptcn_lluvia_intensa
	var pptc_alto_max : float = CONST.thrshld_pptcn_lluvia_intensa  + 30.0 
	
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
	
	var vnto_bajo_min : float = 5.0
	var vnto_bajo_max : float = 20.0
	var vnto_alto_min : float = 21.0
	var vnto_alto_max : float = 35.0
	
	#Llenar array con valores Random
	var idx : int = 0
	for sitioCR in CR_LocalEstaciones.LocalEstaciones:
		var rndBateria : int = randi_range(0,4)
		match rndBateria:
			ENUMS.Bateria._100:
				volt = 25.4
			ENUMS.Bateria._75:
				volt = 25.0
			ENUMS.Bateria._50:
				volt = 24.4
			ENUMS.Bateria._25:
				volt = 24.0
			ENUMS.Bateria._0:
				volt = 23.2
		
		bateriaConCarga = volt > CONST.thrshld_bateria_conCarga
		utr = bateriaConCarga
		enlace = bateriaConCarga
		presaSnsr = bateriaConCarga
		pcptnSnsr = bateriaConCarga
		prsnSnsr = bateriaConCarga
		rSolSnsr = bateriaConCarga
		humTempSnsr = bateriaConCarga
		vntoSnsr = bateriaConCarga
		
		var tengoDatos : bool =  bateriaConCarga and utr and enlace
		
		fch = Time.get_datetime_string_from_system() if utr else ultFechaConInfo
		
		#Temperatura -> (humedad y evaporacion)
		var rndTemperatura : int = randi_range(0,2)
		match rndTemperatura:
			ENUMS.Temperatura.Normal:
				tempVal = randf_range(temp_normal_min, temp_normal_max)
			ENUMS.Temperatura.Calida:
				tempVal = randf_range(temp_calido_min, temp_calido_max)
			ENUMS.Temperatura.Alta:
				tempVal = randf_range(temp_alto_min, temp_alto_max)
		tempVal = tempVal if tengoDatos else NAN
		
		var temperaturaAlta : bool = tempVal > CONST.thrshld_temperatura_alta
		if tengoDatos and temperaturaAlta:
			humVal = randf_range(humd_alto_min, humd_alto_max)
			rSolVal =  randf_range(evap_alto_min, evap_alto_max)
		elif tengoDatos and not temperaturaAlta:
			humVal = randf_range(humd_bajo_min, humd_bajo_max)
			rSolVal =  randf_range(evap_bajo_min, evap_bajo_max)
		else:
			humVal = NAN
			rSolVal =  NAN
			
		#Precipitacion -> (Presion atm y evaporacion)
		var rndLluvia : int = randi_range(0,1)
		if rndTemperatura != ENUMS.Temperatura.Normal:
			rndLluvia = ENUMS.LluviaIntsdad.SinLluvia
		
		match rndLluvia:
			ENUMS.LluviaIntsdad.SinLluvia:
				pcptnVal = 0.0
			ENUMS.LluviaIntsdad.ConLluvia:
				pcptnVal = randf_range(pptc_alto_min,pptc_alto_max)
				
		pcptnVal = pcptnVal if tengoDatos else NAN
		var precipitacionAlta : bool = pcptnVal > CONST.thrshld_pptcn_lluvia_intensa
		if tengoDatos and precipitacionAlta:
			prsnVal = randf_range(psnAtm_bajo_min, psnAtm_bajo_max)
			rSolVal -= maxf(randf_range(1,3),0)
		elif tengoDatos and not precipitacionAlta:
			prsnVal = randf_range(psnAtm_alto_min, psnAtm_alto_max)
		else:
			prsnVal = NAN

		#Viento -> (Presión y evaporacion)
		if rndTemperatura == ENUMS.Temperatura.Normal:
			vntoInt = randf_range(vnto_alto_min, vnto_alto_max) if tengoDatos else NAN
		else:
			vntoInt = randf_range(vnto_bajo_min, vnto_bajo_max) if tengoDatos else NAN

			
		@warning_ignore('incompatible_ternary', 'narrowing_conversion')
		vntoDir = randi_range(0,360) if tengoDatos else NAN
		
		var vientoAlto : bool = vntoInt > CONST.thrshld_vnto_fuerte
		if tengoDatos and vientoAlto:
			prsnVal -= maxf(randf_range(5.0, 15.0),0.0)
			rSolVal += randf_range(1.0,3.0)
		else:
			prsnVal += randf_range(5.0, 15.0)
		
		var rndAlarmas : int = randi_range(0,2)
		match rndAlarmas:
			ENUMS.Alarmas.Normal:
				presaVal = randf_range(0,sitioCR.nivelNormal)
			ENUMS.Alarmas.Prev:
				presaVal = randf_range(sitioCR.nivelPrev,sitioCR.nivelCrit - 1)
			ENUMS.Alarmas.Critico:
				presaVal = randf_range(sitioCR.nivelCrit, sitioCR.nivelCrit + 5)
			
		presaVal = presaVal if tengoDatos else NAN
		
		var estacionRndValues = {
		"id" : idx + 1,
		"fch": fch,
		"ac": ac,
		"volt": volt,
		"utr": utr,
		"enlace": enlace,
		"presaSnsr": presaSnsr,
		"presaVal": presaVal,
		"pcptnSnsr": pcptnSnsr,
		"pcptnVal": pcptnVal,
		"prsnSnsr": prsnSnsr,
		"prsnVal": prsnVal,
		"rSolSnsr": rSolSnsr,
		"rSolVal": rSolVal,
		"humTempSnsr": humTempSnsr,
		"humVal": humVal,
		"tempVal": tempVal,
		"vntoSnsr": vntoSnsr,
		"vntoInt": vntoInt,
		"vntoDir": vntoDir
		}
		
		var estacion : GDs_Data_EP_Sitio = GDs_Data_EP_Sitio.new(estacionRndValues)
		estaciones.append(estacion)
		idx+=1
		
	return estaciones
