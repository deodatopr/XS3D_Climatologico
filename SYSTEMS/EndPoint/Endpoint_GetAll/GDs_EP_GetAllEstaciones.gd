class_name GDs_EP_GetAllEstaciones extends Node

@export var customResource_GetAllEstaciones : GDs_CR_LocalEstaciones
@onready var http_request : HTTPRequest = $HTTPRequest

signal OnRequest_Success
signal OnRequest_Failed

var arrayEstaciones : Array[GDs_Data_EP_Estacion] = []
var estacionesFromServer = {"Estaciones" : arrayEstaciones}
var URL : String
var isBusy : bool

func Initialize(_url : String, _timeout : float):
	URL = _url
	http_request.timeout = _timeout
	http_request.request_completed.connect(_OnRequestCompleted_GetAllEstaciones)
	
func Request_GetAllEstaciones():
	if isBusy:
		return

	isBusy = true
	http_request.request(URL)
	
func GetEstaciones()-> Array[GDs_Data_EP_Estacion]:
	return arrayEstaciones

func _OnRequestCompleted_GetAllEstaciones(result, _response_code, _headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		var dataFromServer= JSON.parse_string(body.get_string_from_utf8())
		#Guardar datos en un diccionario local
		estacionesFromServer = dataFromServer["Estaciones"]
		arrayEstaciones = _CastJsonToArrayEstaciones(estacionesFromServer)#	
		OnRequest_Success.emit()
		print_rich("[color=green]Request [Get all Estaciones] success..![/color].")
	else:
		OnRequest_Failed.emit()
		print_rich("[color=red]Request [Get all Estaciones] failed by internet..![/color].")
		
	isBusy = false

func _CastJsonToArrayEstaciones(json_array: Array) -> Array[GDs_Data_EP_Estacion]:
	var custom_array: Array[GDs_Data_EP_Estacion] = []
	
	for item_data in json_array:
		var custom_item = GDs_Data_EP_Estacion.new(item_data)
		custom_array.append(custom_item)
		
	return custom_array
