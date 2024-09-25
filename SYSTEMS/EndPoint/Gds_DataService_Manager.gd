extends Node
class_name GDs_DataService_Manager

@export_category("ENDPOINT - GetAllSitios")
@export_group("Endpoint")
@export var EP_GetAllEstaciones : GDs_EP_GetAllEstaciones
@export var EP_GetAllEstaciones_Error : GDs_EP_GetAllEstaciones_Error
@export var EP_GetAllEstaciones_Debug : GDs_EP_GetAllEstaciones_Debug
@export var URL : String
@export var secondsToRefreshEP : float = 4.0
@export var timeoutEPGetAllEstaciones : float = 3.0
@export var timerTicking : Timer

@export_group("Local")
@export var crLocalEstaciones : GDs_CR_LocalEstaciones

var estacionesFromEP : Array[GDs_Data_EP_Estacion] = []

var estaciones : Array[GDs_Data_Estacion] = []
var estaciones_Estruc_Todas : GDs_Data_Estaciones_Estructura
var estaciones_Estruc_Mexico : GDs_Data_Estaciones_Estructura
var estaciones_Estruc_Michoacan : GDs_Data_Estaciones_Estructura

var isFirstTimeRequestGetAllEstaciones : bool = true

signal OnDataRefresh

func Initialize():
	#Connect with endpoint GetAllEstacion
	EP_GetAllEstaciones.On_Request_Success.connect(_OnSuccessEP_GetAllEstaciones)
	EP_GetAllEstaciones.On_Request_Failed_BY_INTERNET.connect(_OnErrorEP_GetAllEstaciones)
	EP_GetAllEstaciones.Initialize(URL,timeoutEPGetAllEstaciones)
	
	#Connect with endpoint error
	EP_GetAllEstaciones_Error.Initialize()
	EP_GetAllEstaciones_Error.OnFinishError.connect(MakeRequest_GetAllEstaciones)
	
	#Connect timer to refresh endpoint
	timerTicking.timeout.connect(MakeRequest_GetAllEstaciones)
	
	#Create objects
	estaciones_Estruc_Todas = GDs_Data_Estaciones_Estructura.new()
	estaciones_Estruc_Mexico = GDs_Data_Estaciones_Estructura.new()
	estaciones_Estruc_Michoacan = GDs_Data_Estaciones_Estructura.new()

func MakeRequest_GetAllEstaciones():
	if APPSTATE.debug_EP_GetAllEstaciones:
		EP_GetAllEstaciones.Request_GetAllEstaciones_Debug()
	else:
		EP_GetAllEstaciones.Request_GetAllEstaciones()
		

func GetEstacionById(_id : int) -> GDs_Data_Estacion:
	for estacion in estaciones:
		if estacion.id == _id:
			return estacion
			
	return null

#region [ EVENTS ]
func _OnSuccessEP_GetAllEstaciones():
	#Update data
	_GetDataFromEP_GetAllEstaciones()
	
	#Close error popup in case it is opened
	EP_GetAllEstaciones_Error.Close()
	
	#Start again the timer
	if timerTicking.is_stopped():
		timerTicking.start(secondsToRefreshEP)
		
func _OnErrorEP_GetAllEstaciones():
	#Update data
	_GetDataFromEP_GetAllEstaciones()
	
	#Open error popup in case it is closed
	EP_GetAllEstaciones_Error.Open()
	
	#Stop refresh EP timer
	timerTicking.stop()
#endregion

#region [ FILL DATA ]
func _GetDataFromEP_GetAllEstaciones():
	#Fill Data estacions from EP or random values for debug
	estacionesFromEP.clear()
	if APPSTATE.debug_EP_GetAllEstaciones:
		estacionesFromEP = EP_GetAllEstaciones_Debug.GetDebugEstaciones()
	else:
		estacionesFromEP = EP_GetAllEstaciones.arrayEstaciones
	
	#Fetch EP with local or only update EP data
	if isFirstTimeRequestGetAllEstaciones:
		_FetchEndpointWithLocalData(estacionesFromEP)
		isFirstTimeRequestGetAllEstaciones = false
	else:
		_UpdateFromEP(estacionesFromEP)
		
	#Fill structs by estado
	_FillStructure(estaciones_Estruc_Todas)
	_FillStructure(estaciones_Estruc_Mexico, ENUMS.Estado.Mexico)
	_FillStructure(estaciones_Estruc_Michoacan,ENUMS.Estado.Michoacan)
	
	OnDataRefresh.emit()
	
func _FetchEndpointWithLocalData(arrayEndPoint : Array[GDs_Data_EP_Estacion]):
	for estacionEP in arrayEndPoint:
		var estacionLocal = crLocalEstaciones.GetEstacion(estacionEP.id)
		
		var instanceEstacionCombinada : GDs_Data_Estacion = GDs_Data_Estacion.new()
		
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
		instanceEstacionCombinada.nivelPrev = estacionLocal.nivelPrev
		instanceEstacionCombinada.nivelCrit = estacionLocal.nivelCrit
		
		#Add to Final array
		estaciones.append(instanceEstacionCombinada)
		
func _UpdateFromEP(arrayEndPoint : Array[GDs_Data_EP_Estacion]):
	#Update data only for properties from EP
	
	for estacionEP in arrayEndPoint:
		var idxEstacionToUpdate :  int = estaciones.bsearch(GetEstacionById(estacionEP.id))
				
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
