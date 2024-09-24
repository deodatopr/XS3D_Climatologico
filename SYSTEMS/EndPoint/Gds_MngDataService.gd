extends Node

@export_category("ENDPOINT - GetAllSitios")
@export_group("Endpoint")
@export var endpointGetAllEstaciones : GDs_EP_GetAllEstaciones
@export var endpointGetAllEstaciones_Error : GDs_EP_GetAllEstaciones_Error
@export var URL : String
@export var secondsToRefreshEP : float = 4.0
@export var timeoutEPGetAllEstaciones : float = 3.0
@export var timerEPGetAllEstaciones : Timer

@export_group("Local")
@export var crLocalEstaciones : GDs_CR_LocalEstaciones

var estaciones : Array[GDs_Data_Estacion] = []
var estaciones_Estruc_Todas : GDs_Data_Estaciones_Estructura
var estaciones_Estruc_Mexico : GDs_Data_Estaciones_Estructura
var estaciones_Estruc_Michoacan : GDs_Data_Estaciones_Estructura

var isFirstTimeRequestGetAllEstaciones : bool = true

func Initialize():
	#Connect with endpoint GetAllEstacion
	endpointGetAllEstaciones.On_Request_Success.connect(_OnSuccessEP_GetAllEstaciones)
	endpointGetAllEstaciones.On_Request_Failed_BY_INTERNET.connect(_OnErrorEP_GetAllEstaciones)
	endpointGetAllEstaciones.Initialize(URL,timeoutEPGetAllEstaciones)
	
	#Connect with endpoint error
	endpointGetAllEstaciones_Error.Initialize()
	endpointGetAllEstaciones_Error.OnFinishError.connect(endpointGetAllEstaciones.Request_GetAllEstaciones)
	
	#Connect timer to refresh endpoint
	timerEPGetAllEstaciones.timeoutEPGetAllEstaciones.connect(endpointGetAllEstaciones.Request_GetAllEstaciones)
	
	#Make request
	endpointGetAllEstaciones.Request_GetAllEstaciones()
	
#region [ EVENTS ]
func _OnSuccessEP_GetAllEstaciones():
	#Update data
	_GetDataFromEP_GetAllEstaciones()
	
	#Close error popup in case it is opened
	endpointGetAllEstaciones_Error.Close()
	
	#Start again the timer
	if timerEPGetAllEstaciones.is_stopped():
		timerEPGetAllEstaciones.start(secondsToRefreshEP)
		
func _OnErrorEP_GetAllEstaciones():
	#Update data
	_GetDataFromEP_GetAllEstaciones()
	
	#Open error popup in case it is closed
	endpointGetAllEstaciones_Error.Open()
	
	#Stop refresh EP timer
	timerEPGetAllEstaciones.stop()
#endregion

#region [ FILL DATA ]
func _GetDataFromEP_GetAllEstaciones():
	if isFirstTimeRequestGetAllEstaciones:
		_FetchEndpointWithLocalData(endpointGetAllEstaciones.arrayEstaciones)
		isFirstTimeRequestGetAllEstaciones = false
	else:
		_UpdateFromEP(endpointGetAllEstaciones.arrayEstaciones)
		
	#Fill structs by estado
	_FillStructure(estaciones_Estruc_Todas)
	_FillStructure(estaciones_Estruc_Mexico)
	_FillStructure(estaciones_Estruc_Michoacan)
	
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
		instanceEstacionCombinada.nvlPrev = estacionLocal.nivelPrev
		instanceEstacionCombinada.nvlCrit = estacionLocal.nivelCrit
		
		#Add to Final array
		estaciones.append(instanceEstacionCombinada)
		
func _UpdateFromEP(arrayEndPoint : Array[GDs_Data_EP_Estacion]):
	
	#Update data only for properties from EP
	
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
		
func _FillStructure(_estaciones_Estruc : GDs_Data_Estaciones_Estructura, _estado : int = -1):
	_estaciones_Estruc.estaciones.clear()
	
	var alrmEnlace := 0
	var alrmEnergiaElectrica := 0
	var alrmRebasaNvlsPresa := 0
	var alrmRebasaTlrnciaPrepPluv := 0
	
	for estacion in estaciones:
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
#endregion
