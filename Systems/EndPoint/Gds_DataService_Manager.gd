class_name GDs_DataService_Manager extends Node

@export_category("ENDPOINT - GetAllSitios")
@export_group("Endpoint")
@export var endpoint : GDs_EP_GetAllSitios
@export var endpoint_Simulado : GDs_EP_GetAllSitios_Simulado
@export var endpoint_Error : GDs_EP_GetAllSitios_Error
@export var URL : String
@export var timeToRefresh : float = 30.0
@export var timeToReconnect_Error : float = 10.0
@export var timeoutEPGetAllEstaciones : float = 3.0
@export var timerTicking : Timer

@export_group("Local")
@export var crLocalEstaciones : GDs_CR_LocalSitios

var estacionesFromEP : Array[GDs_Data_EP_Sitio] = []

var estaciones : Array[GDs_Data_Sitio] = []

var isFirstTimeRequestGetAllEstaciones : bool = true


func Initialize():
	SIGNALS.OnGoToSitio.connect(UpdateCurrentSitio)
	SIGNALS.OnDebugRefresh.connect(_OnSimuladoValueChange)
	
	#Connect with endpoint GetAllEstacion
	SIGNALS.OnRequestResult_Success.connect(_OnSuccessEP_GetAllEstaciones)
	SIGNALS.OnRequestResult_Error_Data.connect(_OnFailedEP_GetAllEstaciones)
	SIGNALS.OnRequestResult_Error_NoData.connect(_OnFailedEP_GetAllEstaciones)
	
	#Initialization
	endpoint.Initialize(URL,timeoutEPGetAllEstaciones,crLocalEstaciones,endpoint_Simulado,endpoint_Error)	
	endpoint_Error.Initialize(crLocalEstaciones)
	endpoint_Simulado.Initialize(crLocalEstaciones)
	
	#Connect timer to refresh endpoint
	timerTicking.timeout.connect(MakeRequest_GetAllEstaciones)

func MakeRequest_GetAllEstaciones():
	endpoint.Request_GetAllEstaciones()
	
func GetEstacionById(_id : int) -> GDs_Data_Sitio:
	for estacion in estaciones:
		if estacion.id == _id:
			return estacion
			
	return null
	
func UpdateCurrentSitio(_id : int):
	for sitio in estaciones:
		if sitio.id == _id:
			APPSTATE.currntSitio = sitio
	
			
	#Señal Lluvia
	if APPSTATE.currntSitio.pptn_pluvial > 0:
		SIGNALS.OnLluviaSet.emit(ENUMS.LluviaIntsdad.ConLluvia)
	else:
		SIGNALS.OnLluviaSet.emit(ENUMS.LluviaIntsdad.SinLluvia)
		
	#Señal Temperatura
	if APPSTATE.currntSitio.temperatura > CONST.thrshld_temperatura_alta:
		SIGNALS.OnTemperaturaSet.emit(ENUMS.Temperatura.Alta)
	elif APPSTATE.currntSitio.temperatura > CONST.thrshld_temperatura_calida and APPSTATE.currntSitio.temperatura <= CONST.thrshld_temperatura_alta:
		SIGNALS.OnTemperaturaSet.emit(ENUMS.Temperatura.Calida)
	else:
		SIGNALS.OnTemperaturaSet.emit(ENUMS.Temperatura.Normal)
		
	#Señal Bateria
	if APPSTATE.currntSitio.volt_bat_resp == 25.4:
		SIGNALS.OnBateriaSet.emit(ENUMS.Bateria._100)
	elif APPSTATE.currntSitio.volt_bat_resp == 25.0:
		SIGNALS.OnBateriaSet.emit(ENUMS.Bateria._75)
	elif APPSTATE.currntSitio.volt_bat_resp == 24.4:
		SIGNALS.OnBateriaSet.emit(ENUMS.Bateria._50)
	elif APPSTATE.currntSitio.volt_bat_resp == 24.0:
		SIGNALS.OnBateriaSet.emit(ENUMS.Bateria._25)
	else:
		SIGNALS.OnBateriaSet.emit(ENUMS.Bateria._0)
		
	#Señal alarmas
	if APPSTATE.currntSitio.enCrit:
		SIGNALS.OnAlarmaSet.emit(ENUMS.Alarmas.Critico)
	elif APPSTATE.currntSitio.enPrev:
		SIGNALS.OnAlarmaSet.emit(ENUMS.Alarmas.Prev)
	else:
		SIGNALS.OnAlarmaSet.emit(ENUMS.Alarmas.Normal)
	

#region [ EVENTS ]
func _OnSuccessEP_GetAllEstaciones():
	APPSTATE.EP_GetAllEstaciones_State = ENUMS.EP_GetAllEstaciones.Success
	
	#Update data
	_GetDataFromEP_GetAllEstaciones()
	
	#Start again the timer
	if timerTicking.is_stopped():
		timerTicking.start(timeToRefresh)
		
func _OnFailedEP_GetAllEstaciones():
	APPSTATE.EP_GetAllEstaciones_State = ENUMS.EP_GetAllEstaciones.Error
	
	#Update data
	_GetDataFromEP_GetAllEstaciones()
	
	#Stop refresh EP timer
	timerTicking.stop()

func _OnSimuladoValueChange():
	APPSTATE.EP_GetAllEstaciones_State = ENUMS.EP_GetAllEstaciones.Success
	
	#Update data
	_GetDataFromEP_GetAllEstaciones()
	
	#Start again the timer
	timerTicking.stop()
	timerTicking.timeout.emit()
	timerTicking.start(timeToRefresh)
	
#region [ FILL DATA ]
func _GetDataFromEP_GetAllEstaciones():
	#Get Data estaciones from EP | random | empty
	estacionesFromEP.clear()
	estacionesFromEP = endpoint.GetEstaciones()
	
	#Use data filled to fetch EP with local or only to update data
	if isFirstTimeRequestGetAllEstaciones:
		_FetchEndpointWithLocalData(estacionesFromEP)
		isFirstTimeRequestGetAllEstaciones = false
		
	_UpdateFromEP(estacionesFromEP)
	
	SIGNALS.OnRefresh.emit()

func _FetchEndpointWithLocalData(arrayEndPoint : Array[GDs_Data_EP_Sitio]):
	for sitioEP in arrayEndPoint:
		var sitioLocal = crLocalEstaciones.GetEstacion(sitioEP.id)
		var instanceSitioCombinado : GDs_Data_Sitio = GDs_Data_Sitio.new()
		
		#From EP
		instanceSitioCombinado.id = sitioEP.id
		instanceSitioCombinado.fecha = sitioEP.fecha
		instanceSitioCombinado.nivel = sitioEP.nivel
		instanceSitioCombinado.pptn_pluvial = sitioEP.pptn_pluvial
		instanceSitioCombinado.humedad = sitioEP.humedad
		instanceSitioCombinado.evaporacion = sitioEP.evaporacion
		instanceSitioCombinado.intsdad_viento = sitioEP.intsdad_viento
		instanceSitioCombinado.temperatura = sitioEP.temperatura
		instanceSitioCombinado.disp_utr = sitioEP.disp_utr
		instanceSitioCombinado.fallo_alim_ac = sitioEP.fallo_alim_ac
		instanceSitioCombinado.volt_bat_resp = sitioEP.volt_bat_resp
		instanceSitioCombinado.enlace = sitioEP.enlace
		instanceSitioCombinado.energia_electrica = sitioEP.energia_electrica
		instanceSitioCombinado.rebasa_nvls_presa = sitioEP.rebasa_nvls_presa
		instanceSitioCombinado.rebasa_tlrncia_prep_pluv = sitioEP.rebasa_tlrncia_prep_pluv
		instanceSitioCombinado.presion = sitioEP.presion
		instanceSitioCombinado.presaSnsr = sitioEP.presaSnsr
		instanceSitioCombinado.pcptnSnsr = sitioEP.pcptnSnsr
		instanceSitioCombinado.prsnSnsr = sitioEP.prsnSnsr
		instanceSitioCombinado.solSnsr = sitioEP.solSnsr
		instanceSitioCombinado.humTempSnsr = sitioEP.humTempSnsr
		instanceSitioCombinado.vntoSnsr = sitioEP.vntoSnsr
		
		#From Local
		instanceSitioCombinado.nombre = sitioLocal.nombre
		instanceSitioCombinado.estado = sitioLocal.estado
		instanceSitioCombinado.latitud = sitioLocal.latitud
		instanceSitioCombinado.longitud = sitioLocal.longitud
		instanceSitioCombinado.nivelNormal = sitioLocal.nivelNormal
		instanceSitioCombinado.nivelPrev = sitioLocal.nivelPrev
		instanceSitioCombinado.nivelCrit = sitioLocal.nivelCrit
		instanceSitioCombinado.disponible = sitioLocal.disponible
		instanceSitioCombinado.color = sitioLocal.color
		
		#Extras
		instanceSitioCombinado.enPrev =  sitioEP.nivel >=  sitioLocal.nivelPrev and sitioEP.nivel <  sitioLocal.nivelCrit 
		instanceSitioCombinado.enCrit =  sitioEP.nivel >=  sitioLocal.nivelCrit
		
		#Add to Final array
		estaciones.append(instanceSitioCombinado)
		
func _UpdateFromEP(arrayEndPoint : Array[GDs_Data_EP_Sitio]):
	#Update data only for properties from EP
	
	for sitioEP in arrayEndPoint:
		var estacionToUpdate : GDs_Data_Sitio = GetEstacionById(sitioEP.id)
		estacionToUpdate.fecha = sitioEP.fecha
		estacionToUpdate.nivel = sitioEP.nivel
		estacionToUpdate.pptn_pluvial = sitioEP.pptn_pluvial
		estacionToUpdate.humedad = sitioEP.humedad
		estacionToUpdate.evaporacion = sitioEP.evaporacion
		estacionToUpdate.intsdad_viento = sitioEP.intsdad_viento
		estacionToUpdate.temperatura = sitioEP.temperatura
		estacionToUpdate.disp_utr = sitioEP.disp_utr
		estacionToUpdate.fallo_alim_ac = sitioEP.fallo_alim_ac
		estacionToUpdate.volt_bat_resp = sitioEP.volt_bat_resp
		estacionToUpdate.presion = sitioEP.presion
		estacionToUpdate.presaSnsr = sitioEP.presaSnsr
		estacionToUpdate.pcptnSnsr = sitioEP.pcptnSnsr
		estacionToUpdate.prsnSnsr = sitioEP.prsnSnsr
		estacionToUpdate.solSnsr = sitioEP.solSnsr
		estacionToUpdate.humTempSnsr = sitioEP.humTempSnsr
		estacionToUpdate.vntoSnsr = sitioEP.vntoSnsr
		estacionToUpdate.enlace = sitioEP.enlace
		estacionToUpdate.energia_electrica = sitioEP.energia_electrica
		estacionToUpdate.rebasa_nvls_presa = sitioEP.rebasa_nvls_presa
		estacionToUpdate.rebasa_tlrncia_prep_pluv = sitioEP.rebasa_tlrncia_prep_pluv
		estacionToUpdate.enPrev =  sitioEP.nivel >=  estacionToUpdate.nivelPrev and sitioEP.nivel <  estacionToUpdate.nivelCrit 
		estacionToUpdate.enCrit =  sitioEP.nivel >=  estacionToUpdate.nivelCrit
		
		UpdateCurrentSitio(APPSTATE.currntIdSitio)
#endregion
