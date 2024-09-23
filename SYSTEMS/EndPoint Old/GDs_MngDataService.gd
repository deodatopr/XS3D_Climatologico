extends Node

class_name DATA_SERVICE

@export var sitiosFromCResource : GDs_CR_LocalSitios
@export var endPoint_GetAllSitios : GDs_EndPoint_GetAllSitios
@export var endPoint_RequestError : GDs_Endpoint_Error
@export var endPoint_Historicos : GDs_Endpoint_Historicos

@export_category("DEBUG: Endpoint GetAllSitios")
@export_subgroup("Acceso Endpoint")
@export var DBG_Respuesta_GetAllSitios : bool

@export_subgroup("RANDOM")
@export var DBG_NivelesBarras : bool

@export_category("DEBUG: Endpoint Historicos")
@export_subgroup(" Acceso Endpoint")
@export var DBG_Respuesta_Historicos : bool
@export var DBG_NivelesGraficaRnd : bool

signal OnRefreshSitios
signal OnHistoricosReady
signal OnTimeoutToRefreshHistoricos
signal OnDebugGraficadoraChange (_toggle : bool)

var sitiosFromEndPoint : Array[GDs_DATA_SITIO] = []
var sitios : Array[GDs_SITIO] = []

var sitios_Insurgentes : GDs_ESTRUCTURA
var sitios_Circuito : GDs_ESTRUCTURA
var sitios_Tlalpan : GDs_ESTRUCTURA
var sitios_Periferico : GDs_ESTRUCTURA
var sitios_Viaducto : GDs_ESTRUCTURA
var sitios_Reforma : GDs_ESTRUCTURA
var sitios_Todos : GDs_ESTRUCTURA

var dataWasMerge : bool
var ultAct : String

func _ready():
	SIGNALS.OnRequestEndpointSitiosByDBG.connect(RequestGetAllSitiosManuallyByDbg)
	
	endPoint_GetAllSitios.SetDebugOption(DBG_Respuesta_GetAllSitios)
	endPoint_Historicos.SetDebugOption(DBG_Respuesta_Historicos,DBG_NivelesGraficaRnd)
	
	endPoint_GetAllSitios.On_FirstTimeRquest.connect(OnSitiosData_FirstTime)
	endPoint_GetAllSitios.On_Request_Success.connect(OnSitiosDataRefresh_success)
	endPoint_GetAllSitios.On_Request_Failed_BY_INTERNET.connect(OnSitiosDataRefresh_failed_By_Internet)
	
	endPoint_RequestError.OnInitError.connect(endPoint_GetAllSitios.StopPeriodicRefresh)
	endPoint_RequestError.OnFinishError.connect(endPoint_GetAllSitios.StartPeriodicRefresh)
	endPoint_RequestError.OnFinishError.connect(OnSitiosData_FirstTime)
	
	endPoint_Historicos.On_Request_Success.connect(OnHistoricos_success)
	#endPoint_Historicos.On_Request_Failed_BY_INTERNET.connect()
	#endPoint_Historicos.On_Request_Failed_BY_CONNECTION_WITH_SERVER.connect()
	
	
#region ENDPOINT_GetAllSites
func RequestGetAllSitiosManuallyByDbg():
	endPoint_GetAllSitios.Request_GetAllSitiosByDebug()
	sitiosFromEndPoint = endPoint_GetAllSitios.GetSitios()
	MergeLocalWithEndPoint(sitiosFromEndPoint)

#region [ PRIVATE ]
func OnSitiosData_FirstTime():
	sitiosFromEndPoint = endPoint_GetAllSitios.GetSitios()
	MergeLocalWithEndPoint(sitiosFromEndPoint)
	UpdateEndpointGetAllSitios(sitiosFromEndPoint)
	UpdateDataByEstructura()
	
	OnRefreshSitios.emit()
	

func OnSitiosDataRefresh_success():
	sitiosFromEndPoint = endPoint_GetAllSitios.GetSitios()
	UpdateEndpointGetAllSitios(sitiosFromEndPoint)
	UpdateDataByEstructura()
	OnRefreshSitios.emit()
	print_rich("[color=yellow][b]Refresh Endpoint..![/b][/color].")
	

func OnSitiosDataRefresh_failed_By_Internet():
	sitiosFromEndPoint = endPoint_GetAllSitios.GetSitios()
	
	if !dataWasMerge:
		MergeLocalWithEndPoint(sitiosFromEndPoint)
		dataWasMerge = true
		
	UpdateEndpointGetAllSitios(sitiosFromEndPoint)
	UpdateDataByEstructura()
	OnRefreshSitios.emit()
	
func OnSitiosDataRefresh_failed_By_Endpoint():
	sitiosFromEndPoint = endPoint_GetAllSitios.GetSitios()
	
	if !dataWasMerge:
		MergeLocalWithEndPoint(sitiosFromEndPoint)
		dataWasMerge = true
	
	UpdateEndpointGetAllSitios(sitiosFromEndPoint)
	UpdateDataByEstructura()
	OnRefreshSitios.emit()
	
func MergeLocalWithEndPoint(sitiosEndpoint : Array[GDs_DATA_SITIO]):
	sitios.clear()
	
	for sitioFromEP  in sitiosEndpoint:
		var sitio_instance = GDs_SITIO.new()
		var sitioFromCR = sitiosFromCResource.GetSitio(sitioFromEP.IdSitio)
		
		#Datos obtenidos de Custom resource
		sitio_instance.IdLocal = sitioFromCR.IdLocal
		sitio_instance.IdSitio = sitioFromCR.IdSitio
		sitio_instance.Estructura = sitioFromCR.Estructura
		sitio_instance.NombreEstructura = sitioFromCR.NombreEstructura
		sitio_instance.Abreviacion = sitioFromCR.Abreviacion
		sitio_instance.Direccion = sitioFromCR.Direccion
		sitio_instance.NvlNormal = NivelesFormat(sitioFromCR.NvlNormal)
		sitio_instance.NvlPreventivo = NivelesFormat(sitioFromCR.NvlPreventivo)
		sitio_instance.NvlCritico = NivelesFormat(sitioFromCR.NvlCritico)
		sitio_instance.LvlSitio = sitioFromCR.lvlSitio
		sitio_instance.LvlDisponible = sitioFromCR.disponible
		sitio_instance.LvlUnSoloSentido = sitioFromCR.unSoloSentido

		#Datos obtenidos de Endpoint
		sitio_instance.Enlace = sitioFromEP.Enlace
		sitio_instance.Voltaje = VoltajeFormat(sitioFromEP.Enlace, sitioFromEP.Voltaje)
		sitio_instance.Fecha = FechaFormat(sitioFromEP.Fecha)
		
		var nvlValor : float = -1 
		if sitioFromEP.SignalsContainer.size() > 0:
			nvlValor = sitioFromEP.SignalsContainer[0].Signals[0].Valor #NOTA: Si mandan más señales en el futuro actualizar aqui
			sitio_instance.NvlValor = NivelesFormat(nvlValor) 
		
		#Datos extra calculados
		sitio_instance.NvlNormalCompleto = SemaforoFormat(sitioFromCR.NvlNormal, ENUMS.SEMAFORO.NORMAL)
		sitio_instance.NvlPreventivoCompleto = SemaforoFormat(sitioFromCR.NvlPreventivo, ENUMS.SEMAFORO.PREV)
		sitio_instance.NvlCriticoCompleto = SemaforoFormat(sitioFromCR.NvlCritico, ENUMS.SEMAFORO.CRIT)
		
		sitio_instance.estaEnNivelCritico = nvlValor >= sitioFromCR.NvlCritico
		sitio_instance.estaEnNivelPreventivo = nvlValor >= sitioFromCR.NvlPreventivo &&  nvlValor < sitioFromCR.NvlCritico
		
		if sitioFromEP.Enlace:
			sitio_instance.NvlValor01 = clampf(inverse_lerp(sitioFromCR.NvlNormal, sitioFromCR.NvlCritico, nvlValor), 0.2 , 1.0)
		else:
			sitio_instance.NvlValor01 = 0
		
		sitios.append(sitio_instance)
		
	dataWasMerge = true
	print_rich("[color=cyan] Merge data endpoint con customResource..! [/color]")
		
func SaveDataSitiosByEstructura(enumEstructura : int):	
	var estructura_instance = GDs_ESTRUCTURA.new()
	
	var todos = 0
	var enLinea = 0
	var fueraLinea = 0
	var enPrevCrit = 0
	

	#Llenar reales dle endpoint en cada Avenida
	for sitio in sitios:
		if sitio.Estructura == enumEstructura || enumEstructura == ENUMS.Estructuras.TODOS:
			todos += 1
			estructura_instance.sitios.append(sitio)
			
			if sitio.Enlace:
				enLinea += 1
			else:
				fueraLinea += 1
				estructura_instance.sitiosFueraLinea.append(sitio)
				
			if  sitio.estaEnNivelPreventivo || sitio.estaEnNivelCritico:
				enPrevCrit += 1
				estructura_instance.sitiosPrevCrit.append(sitio)
				
		estructura_instance.todos = todos
		estructura_instance.enLinea = enLinea
		estructura_instance.fueraLinea = fueraLinea
		estructura_instance.enPrevCrit = enPrevCrit

	match enumEstructura:
			ENUMS.Estructuras.INSURGENTES:	sitios_Insurgentes = estructura_instance
			ENUMS.Estructuras.CIRCUITO:		sitios_Circuito = estructura_instance
			ENUMS.Estructuras.TLALPAN:		sitios_Tlalpan = estructura_instance
			ENUMS.Estructuras.PERIFERICO:	sitios_Periferico = estructura_instance
			ENUMS.Estructuras.VIADUCTO:		sitios_Viaducto = estructura_instance
			ENUMS.Estructuras.REFORMA:		sitios_Reforma = estructura_instance
			ENUMS.Estructuras.TODOS:		sitios_Todos = estructura_instance
			
func UpdateEndpointGetAllSitios(sitiosEndpoint : Array[GDs_DATA_SITIO]):
	var idx = 0
	for sitioFromEP in sitiosEndpoint:
		var sitioCR =  sitiosFromCResource.GetSitio(sitioFromEP.IdSitio)
		sitios[idx].Enlace = sitioFromEP.Enlace
		sitios[idx].Voltaje = VoltajeFormat(sitioFromEP.Enlace, sitioFromEP.Voltaje)
		sitios[idx].Fecha = FechaFormat(sitioFromEP.Fecha)
		
		var nvlValor : float = -1
		if  sitioFromEP.SignalsContainer.size() > 0:
			nvlValor = sitioFromEP.SignalsContainer[0].Signals[0].Valor
			sitios[idx].NvlValorFloat = nvlValor
			sitios[idx].NvlValor = NivelesFormat(nvlValor) #NOTA: Si mandan más señales en el futuro actualizar aqui
			
		sitios[idx].estaEnNivelCritico = nvlValor >= sitioCR.NvlCritico
		sitios[idx].estaEnNivelPreventivo = nvlValor >= sitioCR.NvlPreventivo &&  nvlValor < sitioCR.NvlCritico
		
		if sitios[idx].Enlace:
			ultAct = sitioFromEP.Fecha
		
		if DBG_NivelesBarras:
			#Debug nvl random 
			print_rich("[color=orange]---------- NOTA: DEBUG NVLS RANDOM ACTIVADO--------- [/color]")
			var rnd = RandomNumberGenerator.new()
			sitios[idx].estaEnNivelCritico = rnd.randi_range(0,1)
			sitios[idx].estaEnNivelPreventivo = rnd.randi_range(0,1)
			
			if sitios[idx].estaEnNivelCritico:
				sitios[idx].NvlValor01 = 1
			elif sitios[idx].estaEnNivelPreventivo:
				sitios[idx].NvlValor01 = .66
			else:
				sitios[idx].NvlValor01 = .1
		else:
			sitios[idx].NvlValor01 =  clampf(inverse_lerp(0.0, sitioCR.NvlCritico, nvlValor), 0.0 , 1.0) + 0.04
			
		idx += 1
		
func UpdateDataByEstructura():	
	#Guardar en cada estructura sus sitios y datos
	SaveDataSitiosByEstructura(ENUMS.Estructuras.INSURGENTES)
	SaveDataSitiosByEstructura(ENUMS.Estructuras.CIRCUITO)
	SaveDataSitiosByEstructura(ENUMS.Estructuras.TLALPAN)
	SaveDataSitiosByEstructura(ENUMS.Estructuras.PERIFERICO)
	SaveDataSitiosByEstructura(ENUMS.Estructuras.VIADUCTO)
	SaveDataSitiosByEstructura(ENUMS.Estructuras.REFORMA)
	SaveDataSitiosByEstructura(ENUMS.Estructuras.TODOS)
	
#region Formato valores
func VoltajeFormat(enLinea: bool, voltaje : float) -> String:
	if not enLinea or voltaje < 0:
		return "--- V"
	else:
		return str(voltaje, " V")
		
func NivelesFormat(nivel : float) -> String:
	if  nivel < 0:
		return "--- cm"
	else:
		return str(nivel * 100, " cm")
		
func FechaFormat(fecha: String) -> String:
	
	var year = fecha.substr(0,4)
	var month = fecha.substr(5,2)
	var day = fecha.substr(8,2)
	var hr = fecha.substr(11,5)
		
	return str(hr," - ",day,"/",month,"/",year)
	
func SemaforoFormat(nvl : float, enumSemaforo : int) -> String:
	match enumSemaforo:
		ENUMS.SEMAFORO.NORMAL:
			return str("Normal: ",NivelesFormat(nvl))
		ENUMS.SEMAFORO.PREV:
			return str("Preventivo: ",NivelesFormat(nvl))
		ENUMS.SEMAFORO.CRIT:
			return str("Critico: ",NivelesFormat(nvl))
			
	return "null"
	
func DentroRangoFormat(value : int) -> String:
	return str("Dentro de rango: ", value)

func ValidoFormat(value : bool) -> String:
	return str("Valido: ", str(value))
#endregion
#endregion

#region [ PUBLIC ]
func GetSitios() -> Array[GDs_SITIO]:
	return sitios
	
func GetSitioById(_idSitio : int) -> GDs_SITIO:
	for sitio in sitios:
		if sitio.IdSitio == _idSitio:
			return sitio
			
	return null
	
func GetSitioByIdLocal(_idLocalSitio : int) -> GDs_SITIO:
	for sitio in sitios:
		if sitio.IdLocal == _idLocalSitio:
			return sitio
			
	return null
	
func DEBUG_GetSitioRandom() -> GDs_SITIO:
	return sitios.pick_random()

func GetSitiosByEstructura(enumEstructura : int) -> GDs_ESTRUCTURA:
	match enumEstructura:
		ENUMS.Estructuras.INSURGENTES:  return sitios_Insurgentes
		ENUMS.Estructuras.CIRCUITO:		return sitios_Circuito
		ENUMS.Estructuras.TLALPAN:		return sitios_Tlalpan
		ENUMS.Estructuras.PERIFERICO:	return sitios_Periferico
		ENUMS.Estructuras.VIADUCTO:		return sitios_Viaducto
		ENUMS.Estructuras.REFORMA:		return sitios_Reforma
		ENUMS.Estructuras.TODOS:		return sitios_Todos
		
	return null
	
func GetUltimaActualizacionFormato() -> String:
	for sitio in sitios:
		if sitio.Enlace:
			return sitio.Fecha
			
	return "null"
	
func GetUltimaActualizacion() -> String:
	return ultAct
#endregion
#endregion

#region ENDPOINT_Historicos
func OnHistoricos_success():
	OnHistoricosReady.emit()

#Llamar primero el request
func RequestHistoricos(_sitio : int, _fechaFinal : String):
	endPoint_Historicos.RequestHistoricos(_sitio, _fechaFinal)

#Pedir los historicos cuando llegue la respuesta del request
func GetHistoricos() -> GDs_Historico:
	return endPoint_Historicos.GetHistoricos()
	
func On_TimeoutToRefreshHistoricos():
	OnTimeoutToRefreshHistoricos.emit()
	
func StopRefreshHistoricos():
	endPoint_Historicos.StopTimer()

func DebugGrafica(_toggle : bool):
	endPoint_Historicos.SetDebugOption(DBG_Respuesta_Historicos, _toggle)
	OnDebugGraficadoraChange.emit(_toggle)
#endregion
