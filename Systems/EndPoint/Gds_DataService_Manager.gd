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
	if APPSTATE.currntSitio.pcptnVal > 0:
		SIGNALS.OnLluviaSet.emit(ENUMS.LluviaIntsdad.ConLluvia)
	else:
		SIGNALS.OnLluviaSet.emit(ENUMS.LluviaIntsdad.SinLluvia)
		
	#Señal Temperatura
	if APPSTATE.currntSitio.tempVal > CONST.thrshld_temperatura_alta:
		SIGNALS.OnTemperaturaSet.emit(ENUMS.Temperatura.Alta)
	elif APPSTATE.currntSitio.tempVal > CONST.thrshld_temperatura_calida and APPSTATE.currntSitio.tempVal <= CONST.thrshld_temperatura_alta:
		SIGNALS.OnTemperaturaSet.emit(ENUMS.Temperatura.Calida)
	else:
		SIGNALS.OnTemperaturaSet.emit(ENUMS.Temperatura.Normal)
		
	#Señal Bateria
	if APPSTATE.currntSitio.volt == 25.4:
		SIGNALS.OnBateriaSet.emit(ENUMS.Bateria._100)
	elif APPSTATE.currntSitio.volt == 25.0:
		SIGNALS.OnBateriaSet.emit(ENUMS.Bateria._75)
	elif APPSTATE.currntSitio.volt == 24.4:
		SIGNALS.OnBateriaSet.emit(ENUMS.Bateria._50)
	elif APPSTATE.currntSitio.volt == 24.0:
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
		instanceSitioCombinado.ac = sitioEP.ac
		instanceSitioCombinado.volt = sitioEP.volt
		instanceSitioCombinado.utr = sitioEP.utr
		instanceSitioCombinado.enlace = sitioEP.enlace
		instanceSitioCombinado.presaSnsr = sitioEP.presaSnsr
		instanceSitioCombinado.presaVal = sitioEP.presaVal
		instanceSitioCombinado.pcptnSnsr = sitioEP.pcptnSnsr
		instanceSitioCombinado.pcptnVal = sitioEP.pcptnVal
		instanceSitioCombinado.prsnSnsr = sitioEP.prsnSnsr
		instanceSitioCombinado.prsnVal = sitioEP.prsnVal
		instanceSitioCombinado.rSolSnsr = sitioEP.rSolSnsr
		instanceSitioCombinado.rSolVal = sitioEP.rSolVal
		instanceSitioCombinado.humTempSnsr = sitioEP.humTempSnsr
		instanceSitioCombinado.humVal = sitioEP.humVal
		instanceSitioCombinado.tempVal = sitioEP.tempVal
		instanceSitioCombinado.vntoSnsr = sitioEP.vntoSnsr
		instanceSitioCombinado.vntoInt = sitioEP.vntoInt
		instanceSitioCombinado.vntoDir = sitioEP.vntoDir
		
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
		instanceSitioCombinado.enPrev = sitioEP.presaSnsr and (sitioEP.presaVal >=  sitioLocal.nivelPrev and sitioEP.presaVal <  sitioLocal.nivelCrit) 
		instanceSitioCombinado.enCrit = sitioEP.presaSnsr and (sitioEP.presaVal >=  sitioLocal.nivelCrit)
		
		#Add to Final array
		estaciones.append(instanceSitioCombinado)
		
func _UpdateFromEP(arrayEndPoint : Array[GDs_Data_EP_Sitio]):
	#Update data only for properties from EP
	
	for sitioEP in arrayEndPoint:
		var estacionToUpdate : GDs_Data_Sitio = GetEstacionById(sitioEP.id)
		estacionToUpdate.fecha = sitioEP.fecha
		estacionToUpdate.ac = sitioEP.ac
		estacionToUpdate.volt = sitioEP.volt
		estacionToUpdate.utr = sitioEP.utr
		estacionToUpdate.enlace = sitioEP.enlace
		estacionToUpdate.presaSnsr = sitioEP.presaSnsr
		estacionToUpdate.presaVal = sitioEP.presaVal
		estacionToUpdate.pcptnSnsr = sitioEP.pcptnSnsr
		estacionToUpdate.pcptnVal = sitioEP.pcptnVal
		estacionToUpdate.prsnSnsr = sitioEP.prsnSnsr
		estacionToUpdate.prsnVal = sitioEP.prsnVal
		estacionToUpdate.rSolSnsr = sitioEP.rSolSnsr
		estacionToUpdate.rSolVal = sitioEP.rSolVal
		estacionToUpdate.humTempSnsr = sitioEP.humTempSnsr
		estacionToUpdate.humVal = sitioEP.humVal
		estacionToUpdate.tempVal = sitioEP.tempVal
		estacionToUpdate.vntoSnsr = sitioEP.vntoSnsr
		estacionToUpdate.vntoInt = sitioEP.vntoInt
		estacionToUpdate.vntoDir = sitioEP.vntoDir

		estacionToUpdate.enPrev = sitioEP.presaSnsr and (sitioEP.presaVal >=  estacionToUpdate.nivelPrev and sitioEP.presaVal <  estacionToUpdate.nivelCrit)
		estacionToUpdate.enCrit = sitioEP.presaSnsr and (sitioEP.presaVal >=  estacionToUpdate.nivelCrit)
		
		UpdateCurrentSitio(APPSTATE.currntIdSitio)
#endregion
