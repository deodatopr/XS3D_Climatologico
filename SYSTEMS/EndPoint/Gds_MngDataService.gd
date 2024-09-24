extends Node

@export_category("ENDPOINT - GetAllSitios")
@export_group("Endpoint")
@export var endpointGetAllEstaciones : GDs_EP_GetAllEstaciones
@export var URL : String
@export var secondsToRefreshEP : float = 4.0
@export var timeout : float = 3.0
@export var timerEPGetAllEstaciones : Timer

@export_group("Local")
@export var crLocalEstaciones : GDs_CR_LocalEstaciones

var estaciones : Array[GDs_Data_Estacion] = []
var isFirstTimeRequestGetAllEstaciones : bool = true

func Initialize():
	endpointGetAllEstaciones.On_Request_Success.connect(_OnSuccessEP_GetAllEstaciones)
	endpointGetAllEstaciones.On_Request_Failed_BY_INTERNET.connect(_OnErrorEP_GetAllEstaciones)
	endpointGetAllEstaciones.Initialize(URL,timeout)
	
	endpointGetAllEstaciones.Request_GetAllEstaciones()
	
	timerEPGetAllEstaciones.timeout.connect(endpointGetAllEstaciones.Request_GetAllEstaciones)
	timerEPGetAllEstaciones.start(secondsToRefreshEP)
	
func _OnSuccessEP_GetAllEstaciones():
	_GetDataFromEP_GetAllEstaciones()
		
func _OnErrorEP_GetAllEstaciones():
	_GetDataFromEP_GetAllEstaciones()
	timerEPGetAllEstaciones.stop()

#region [ Fill array estaciones ]
func _GetDataFromEP_GetAllEstaciones():
	if isFirstTimeRequestGetAllEstaciones:
		_FetchEndpointWithLocalData(endpointGetAllEstaciones.arrayEstaciones)
		isFirstTimeRequestGetAllEstaciones = false
	else:
		_UpdateFromEP(endpointGetAllEstaciones.arrayEstaciones)	
	

func _FetchEndpointWithLocalData(arrayEndPoint : Array[GDs_Data_EP_Estacion]):
	for estacionEP in arrayEndPoint:
		var estacionLocal = crLocalEstaciones.GetEstacion(estacionEP.id)
		
		var instanceEstacionCombinada : GDs_Data_Estacion
		
		#From EP
		instanceEstacionCombinada.id = estacionEP.id
		instanceEstacionCombinada.fecha = estacionEP.fecha
		instanceEstacionCombinada.nivel = estacionEP.nivel
		instanceEstacionCombinada.pptn_pluvial = estacionEP.pptn_pluvial
		instanceEstacionCombinada.humedad = estacionEP.humedad
		instanceEstacionCombinada.evaporacion = estacionEP.evaporacion
		instanceEstacionCombinada.intsdad_viento = estacionEP.intsdad_viento
		instanceEstacionCombinada.temperatura = estacionEP.temperatura
		instanceEstacionCombinada.disp_utr = estacionEP.disp_utr
		instanceEstacionCombinada.fallo_alim_ac = estacionEP.fallo_alim_ac
		instanceEstacionCombinada.volt_bat_resp = estacionEP.volt_bat_resp
		instanceEstacionCombinada.enlace = estacionEP.enlace
		instanceEstacionCombinada.energia_electrica = estacionEP.energia_electrica
		instanceEstacionCombinada.rebasa_nvls_presa = estacionEP.rebasa_nvls_presa
		instanceEstacionCombinada.rebasa_tlrncia_prep_pluv = estacionEP.rebasa_tlrncia_prep_pluv
		
		#From Local
		instanceEstacionCombinada.nombre = estacionLocal.nombre
		instanceEstacionCombinada.estado = estacionLocal.estado
		instanceEstacionCombinada.latitud = estacionLocal.latitud
		instanceEstacionCombinada.longitud = estacionLocal.longitud
		
		#Add to Final array
		estaciones.append(instanceEstacionCombinada)
		
func _UpdateFromEP(arrayEndPoint : Array[GDs_Data_EP_Estacion]):
	for estacionEP in arrayEndPoint:
		var idxEstacionToUpdate :  int = estaciones.bsearch(estacionEP.id)
				
		estaciones[idxEstacionToUpdate].fecha = estacionEP.fecha
		estaciones[idxEstacionToUpdate].nivel = estacionEP.nivel
		estaciones[idxEstacionToUpdate].pptn_pluvial = estacionEP.pptn_pluvial
		estaciones[idxEstacionToUpdate].humedad = estacionEP.humedad
		estaciones[idxEstacionToUpdate].evaporacion = estacionEP.evaporacion
		estaciones[idxEstacionToUpdate].intsdad_viento = estacionEP.intsdad_viento
		estaciones[idxEstacionToUpdate].temperatura = estacionEP.temperatura
		estaciones[idxEstacionToUpdate].disp_utr = estacionEP.disp_utr
		estaciones[idxEstacionToUpdate].fallo_alim_ac = estacionEP.fallo_alim_ac
		estaciones[idxEstacionToUpdate].volt_bat_resp = estacionEP.volt_bat_resp
		estaciones[idxEstacionToUpdate].enlace = estacionEP.enlace
		estaciones[idxEstacionToUpdate].energia_electrica = estacionEP.energia_electrica
		estaciones[idxEstacionToUpdate].rebasa_nvls_presa = estacionEP.rebasa_nvls_presa
		estaciones[idxEstacionToUpdate].rebasa_tlrncia_prep_pluv = estacionEP.rebasa_tlrncia_prep_pluv
#endregion
