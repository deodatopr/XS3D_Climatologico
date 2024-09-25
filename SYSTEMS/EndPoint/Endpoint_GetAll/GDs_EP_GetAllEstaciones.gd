extends Node
class_name GDs_EP_GetAllEstaciones

@export var customResource_GetAllEstaciones : GDs_CR_LocalEstaciones
@onready var http_request : HTTPRequest = $HTTPRequest

signal On_Request_Success
signal On_Request_Failed_BY_INTERNET

var arrayEstaciones : Array[GDs_Data_EP_Estacion] = []
var estacionesFromServer = {"Estaciones" : arrayEstaciones}
var URL : String
var isBusy : bool

func Initialize(_url : String, _timeout : float):
	URL = _url
	http_request.timeout = _timeout
	http_request.request_completed.connect(_on_request_completed_GetAllSitios)

func _on_request_completed_GetAllSitios(result, _response_code, _headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		#var dataFromServer= jsonResponse.parse_string(body.get_string_from_utf8())
		var dataFromServer= JSON.parse_string(body.get_string_from_utf8())
		
		#Guardar datos en un diccionario local
		estacionesFromServer = dataFromServer["Estaciones"]
		arrayEstaciones = CastJsonToArraySitio(estacionesFromServer)
#	
		On_Request_Success.emit()
		
		print_rich("[color=green]Request [Get all Estaciones] success..![/color].")
	else:
		arrayEstaciones = FillArrayEstacionesWithEmptyData()
		On_Request_Failed_BY_INTERNET.emit()
		print_rich("[color=red]Request [Get all sitios] failed by internet..![/color].")
		
	isBusy = false

func CastJsonToArraySitio(json_array: Array) -> Array[GDs_Data_EP_Estacion]:
	var custom_array: Array[GDs_Data_EP_Estacion] = []
	#Obtener y setear cada propiedad de la clase ENDPOINT_SITIO_EXT para agregarlo al array
	for item_data in json_array:
		var custom_item = GDs_Data_EP_Estacion.new(item_data)
		custom_array.append(custom_item)
		
	return custom_array

func Request_GetAllEstaciones():
	if isBusy:
		return

	isBusy = true
	http_request.request(URL)

func FillArrayEstacionesWithEmptyData()-> Array[GDs_Data_EP_Estacion]:
	#Llenar datos vacios de endpoint para que la app pueda funcionar pero sin datos	
	var custom_array: Array[GDs_Data_EP_Estacion] = []

	#Obtener y setear cada propiedad de la clase ENDPOINT_SITIO_EXT para agregarlo al array
	for i in range(customResource_GetAllEstaciones.LocalEstaciones.size()):
		var emptyEstacion = {
		"id": customResource_GetAllEstaciones.LocalEstaciones[i].id,
		"fecha": "",
		"nivel": 0.0,
		"prtcion_pluvial": 0.0,
		"humedad": 0.0,
		"evaporacion": 0.0,
		"intsdad_viento": 0.0,
		"dir_viento": 0.0,
		"temperatura": 0.0,
		
		"disp_utr": false,
		"fallo_alim_ac": false,
		"volt_bat_resp": 0.0,
		
		"enlace": false,
		"energia_electrica": false,
		"rebasa_nvls_presa": false,
		"rebasa_tlrncia_prep_pluv": false
		}
		
		var custom_item = GDs_Data_EP_Estacion.new(emptyEstacion)		
		custom_array.append(custom_item)

	return custom_array
