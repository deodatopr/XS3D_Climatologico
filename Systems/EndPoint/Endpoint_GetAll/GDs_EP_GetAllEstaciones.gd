class_name GDs_EP_GetAllEstaciones extends Node

@onready var http_request : HTTPRequest = $HTTPRequest

var CR_LocalEstaciones : GDs_CR_LocalEstaciones
var getAllEstaciones_Simulado : GDs_EP_GetAllEstaciones_Simulado
var getAllEstaciones_Error : GDs_EP_GetAllEstaciones_Error
var arrayEstaciones : Array[GDs_Data_EP_Estacion] = []
var lastArrayEstacionesWithData : Array[GDs_Data_EP_Estacion] = []
var estacionesFromServer = {"Estaciones" : arrayEstaciones}
var URL : String
var isBusy : bool

func Initialize(_url : String, _timeout : float, _CR_LocalEstaciones : GDs_CR_LocalEstaciones, _estacionesSimulado : GDs_EP_GetAllEstaciones_Simulado ,_estacionesError : GDs_EP_GetAllEstaciones_Error):
	URL = _url
	http_request.timeout = _timeout
	http_request.request_completed.connect(_OnRequestCompleted_GetAllEstaciones)
	
	CR_LocalEstaciones = _CR_LocalEstaciones
	getAllEstaciones_Simulado = _estacionesSimulado
	getAllEstaciones_Error = _estacionesError
	
func Request_GetAllEstaciones():
	if isBusy:
		return

	isBusy = true
	
	if DEBUG.modoDatos == ENUMS.ModoDatos.Simulado:
		if DEBUG.requestResult == ENUMS.EP_RequestResult.Success:
			arrayEstaciones = getAllEstaciones_Simulado.GetEstaciones()
			lastArrayEstacionesWithData = arrayEstaciones.duplicate()
			SIGNALS.OnRequestResult_Success.emit()
		elif DEBUG.requestResult == ENUMS.EP_RequestResult.Error_NoData:
			arrayEstaciones = getAllEstaciones_Error.GetEstaciones_NoData()
			SIGNALS.OnRequestResult_Error_NoData.emit()
		else:
			if lastArrayEstacionesWithData.size() > 0:
				arrayEstaciones = getAllEstaciones_Error.GetEstaciones_LastData(lastArrayEstacionesWithData)
				lastArrayEstacionesWithData = arrayEstaciones.duplicate()
				SIGNALS.OnRequestResult_Error_Data.emit()
			else:
				arrayEstaciones = getAllEstaciones_Error.GetEstaciones_NoData()
				SIGNALS.OnRequestResult_Error_NoData.emit()
			
		isBusy = false
		return
	
	#Request endpoint
	if APPSTATE.EP_GetAllEstaciones_RequestType == ENUMS.EP_GetAllEstaciones.Success:
		http_request.request(URL)
		
	
func GetEstaciones()-> Array[GDs_Data_EP_Estacion]:
	return arrayEstaciones

func _OnRequestCompleted_GetAllEstaciones(result, _response_code, _headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		var dataFromServer= JSON.parse_string(body.get_string_from_utf8())
		#Guardar datos en un diccionario local
		estacionesFromServer = dataFromServer["Estaciones"]
		arrayEstaciones = _CastJsonToArrayEstaciones(estacionesFromServer)#	
		SIGNALS.OnRequestResult_Success
		print_rich("[color=green]Request [Get all Estaciones] success..![/color].")
	else:
		SIGNALS.OnRequestResult_Error_NoData
		print_rich("[color=red]Request [Get all Estaciones] failed by internet..![/color].")
		
	isBusy = false

func _CastJsonToArrayEstaciones(json_array: Array) -> Array[GDs_Data_EP_Estacion]:
	var custom_array: Array[GDs_Data_EP_Estacion] = []
	
	for item_data in json_array:
		var custom_item = GDs_Data_EP_Estacion.new(item_data)
		custom_array.append(custom_item)
		
	return custom_array
