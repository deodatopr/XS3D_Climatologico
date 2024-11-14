class_name GDs_EP_GetAllEstaciones_Error extends Node

var CR_LocalEstaciones: GDs_CR_LocalEstaciones

func Initialize(_CR_LocalEstaciones: GDs_CR_LocalEstaciones):
	CR_LocalEstaciones = _CR_LocalEstaciones
		
func GetEstaciones_NoData() -> Array[GDs_Data_EP_Estacion]:
	var estaciones : Array[GDs_Data_EP_Estacion]
	
	var fecha : String = "---- -- ----- --:--"
	var utr : bool = false
	var enlace : bool = false
	var nvlBateria : float = NAN
	var temperatura : float = NAN
	var humedad : float = NAN
	var evaporacion : float = NAN
	var precipitacion : float = NAN
	var presionAtm : float = NAN
	var viento : float = NAN
	@warning_ignore('narrowing_conversion')
	var dir_viento : int = NAN
	var nivel : float = NAN
	var presaSnsr : bool = false
	var pcptnSnsr : bool = false
	var prsnSnsr : bool = false
	var solSnsr : bool = false
	var humTempSnsr : bool = false
	var vntoSnsr : bool = false
	
	var idx : int = 0
	for sitioCR in CR_LocalEstaciones.LocalEstaciones:
		var estacionNoValues = {
		"id" : idx + 1,
		"fecha": fecha,
		"volt_bat_resp": nvlBateria,
		"enlace": enlace,
		"disp_utr": utr,
		"presaSnsr": presaSnsr,
		"pcptnSnsr": pcptnSnsr,
		"prsnSnsr": prsnSnsr,
		"solSnsr": solSnsr,
		"humTempSnsr": humTempSnsr,
		"vntoSnsr": vntoSnsr,
		
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
		
		var estacion : GDs_Data_EP_Estacion = GDs_Data_EP_Estacion.new(estacionNoValues)
		estacion.rebasa_nvls_presa = false
		estacion.rebasa_tlrncia_prep_pluv = false

		estaciones.append(estacion)
		idx+=1
		
	return estaciones
	
func GetEstaciones_LastData(_lastEstacionesData : Array[GDs_Data_EP_Estacion]) -> Array[GDs_Data_EP_Estacion]:
	return _lastEstacionesData
