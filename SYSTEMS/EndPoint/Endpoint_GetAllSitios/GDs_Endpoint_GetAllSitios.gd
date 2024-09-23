extends Node

class_name GDs_EndPoint_GetAllSitios

@export var endPoint_GetAllSitios : String
@export var customResource_GetAllSitios : GDs_CR_LocalSitios

@export_category("PERIODIC REFRESH")
@export var tickEverySec : float = 20
@export var timerTicking : Timer

@onready var http_request : HTTPRequest = $HTTPRequest

signal On_FirstTimeRquest
signal On_Request_Success
signal On_Request_Failed_BY_INTERNET

var DEBUG_overrideResponseResult : bool
var DEBUG_responseResult : int

var arraySitios : Array[GDs_DATA_SITIO] = []
var sitiosFromServer = {"Sites" : arraySitios}
var isBusy : bool
var firstTimeRequest : bool = true
var isShowingErrorPopup : bool

func _ready():
	http_request.timeout = 3
	http_request.request_completed.connect(_on_request_completed_GetAllSitios)
	
	#Solicita request e inicia timer para ejecutarlo cada X Segundos
	Request_GetAllSitios()
	StartPeriodicRefresh()
		
func StartPeriodicRefresh():
	timerTicking.start(tickEverySec)
	if not  timerTicking.timeout.is_connected(Request_GetAllSitios):
		timerTicking.timeout.connect(Request_GetAllSitios)
	
func StopPeriodicRefresh():
	timerTicking.stop()

func SetDebugOption(_DEBUG_overrideResponseResult : bool):
	DEBUG_overrideResponseResult = _DEBUG_overrideResponseResult

#----- REQUEST "GET_ALL_SITIOS INFO CORTA"
func Request_GetAllSitios():
	if isBusy:
		return

	isBusy = true
	http_request.request(endPoint_GetAllSitios)
	
func Request_GetAllSitiosByDebug():
	StopPeriodicRefresh()
	
	Request_GetAllSitios()
	
	StartPeriodicRefresh()

func _on_request_completed_GetAllSitios(result, _response_code, _headers, body):
	if DEBUG_overrideResponseResult:
		if DEBUG_responseResult == 0:
			var rnd = RandomNumberGenerator.new()
			var rndNumber = rnd.randi_range(0,1)
			DEBUG_responseResult = 4 if rndNumber == 0 else 6
		else:
			DEBUG_responseResult = 0
			
		result = DEBUG_responseResult
		print_rich("[color=orange]-------- DEBUG RESULT RESPONSE [GetAllSitios] ENABLE ------------------ [/color]")
	
	if result == HTTPRequest.RESULT_SUCCESS:
		#var dataFromServer= jsonResponse.parse_string(body.get_string_from_utf8())
		var dataFromServer= JSON.parse_string(body.get_string_from_utf8())
		
		#Guardar datos en un diccionario local
		sitiosFromServer = dataFromServer["Sites"]
		arraySitios = CastJsonToArraySitio(sitiosFromServer)
	
		#Avisar si fue la primera vez que se hizo el request para hacer merge con datos locales o si es por un update cada x tiempo
		if firstTimeRequest:
			On_FirstTimeRquest.emit()
			firstTimeRequest = false
		else:
			On_Request_Success.emit()
		
		print_rich("[color=green]Request [Get all sitios] success..![/color].")
	else:
		arraySitios = FillArraySitiosWithEmptyData()
		On_Request_Failed_BY_INTERNET.emit()
		print_rich("[color=red]Request [Get all sitios] failed by internet..![/color].")
		
	isBusy = false


func GetSitios() -> Array[GDs_DATA_SITIO]:
	return arraySitios

# Convierte el JSON array a instancias de de array custom
func CastJsonToArraySitio(json_array: Array) -> Array[GDs_DATA_SITIO]:
	var custom_array: Array[GDs_DATA_SITIO] = []

#Obtener y setear cada propiedad de la clase ENDPOINT_SITIO_EXT para agregarlo al array
	for item_data in json_array:
		var custom_item = GDs_DATA_SITIO.new(item_data)		
		custom_array.append(custom_item)
		
	return custom_array
	

func FillArraySitiosWithEmptyData()-> Array[GDs_DATA_SITIO]:
	#Llenar datos vacios de endpoint para que la app pueda funcionar pero sin datos	
	var custom_array: Array[GDs_DATA_SITIO] = []

	#Obtener y setear cada propiedad de la clase ENDPOINT_SITIO_EXT para agregarlo al array
	for i in range(customResource_GetAllSitios.LocalSitios.size()):
		var emptySitio = {
		"IdSitio": customResource_GetAllSitios.LocalSitios[i].IdSitio,
		"Enlace": false,
		"Voltaje": -1,
		"Fecha": "----/--/--T--:--:--",
		"SignalsContainer": [{"TipoSignal" : -1,"Signals" : [{"Valor" : -1}]}],
		}
		
		var custom_item = GDs_DATA_SITIO.new(emptySitio)		
		custom_array.append(custom_item)

	return custom_array
