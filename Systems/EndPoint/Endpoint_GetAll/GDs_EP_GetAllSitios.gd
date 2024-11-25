class_name GDs_EP_GetAllSitios extends Node

@onready var http_request : HTTPRequest = $HTTPRequest

var CR_LocalSitios : GDs_CR_LocalSitios
var getAllSitios_Simulado : GDs_EP_GetAllSitios_Simulado
var getAllSitios_Error : GDs_EP_GetAllSitios_Error
var arraySitios : Array[GDs_Data_EP_Sitio] = []
var lastArraySitiosWithData : Array[GDs_Data_EP_Sitio] = []
var URL : String
var isBusy : bool

func Initialize(_url : String, _timeout : float, _CR_LocalSitios : GDs_CR_LocalSitios, _sitiosSimulado : GDs_EP_GetAllSitios_Simulado ,_sitiosError : GDs_EP_GetAllSitios_Error):
	URL = _url
	http_request.timeout = _timeout
	http_request.request_completed.connect(_OnRequestCompleted_GetAllEstaciones)
	
	CR_LocalSitios = _CR_LocalSitios
	getAllSitios_Simulado = _sitiosSimulado
	getAllSitios_Error = _sitiosError
	
func Request_GetAllEstaciones():
	if isBusy:
		return

	isBusy = true
	
	if DEBUG.modoDatos == ENUMS.ModoDatos.Simulado:
		if DEBUG.requestResult == ENUMS.EP_RequestResult.Success:
			if DEBUG.simuladoRandom:
				arraySitios = getAllSitios_Simulado.GetEstaciones_Random()
			else:
				arraySitios = getAllSitios_Simulado.GetEstaciones_Manual()
				
			lastArraySitiosWithData = arraySitios.duplicate()
			SIGNALS.OnRequestResult_Success.emit()
		elif DEBUG.requestResult == ENUMS.EP_RequestResult.Error_NoData:
			arraySitios = getAllSitios_Error.GetEstaciones_NoData()
			SIGNALS.OnRequestResult_Error_NoData.emit()
		else:
			if lastArraySitiosWithData.size() > 0:
				arraySitios = getAllSitios_Error.GetEstaciones_LastData(lastArraySitiosWithData)
				lastArraySitiosWithData = arraySitios.duplicate()
				SIGNALS.OnRequestResult_Error_Data.emit()
			else:
				arraySitios = getAllSitios_Error.GetEstaciones_NoData()
				SIGNALS.OnRequestResult_Error_NoData.emit()
		isBusy = false
		return
	
	#Request endpoint
	if APPSTATE.EP_GetAllEstaciones_RequestType == ENUMS.EP_GetAllEstaciones.Success:
		http_request.request(URL)
		
	
func GetEstaciones()-> Array[GDs_Data_EP_Sitio]:
	return arraySitios

func _OnRequestCompleted_GetAllEstaciones(result, _response_code, _headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		var dataFromServer= JSON.parse_string(body.get_string_from_utf8())
		#Guardar datos en un diccionario local
		arraySitios = _CastJsonToArrayEstaciones(dataFromServer)
		SIGNALS.OnRequestResult_Success.emit()
		print_rich("[color=green]Request [Get all Estaciones] success..![/color].")
	else:
		SIGNALS.OnRequestResult_Error_NoData.emit()
		print_rich("[color=red]Request [Get all Estaciones] failed by internet..![/color].")
	isBusy = false

func _CastJsonToArrayEstaciones(json_array: Array) -> Array[GDs_Data_EP_Sitio]:
	var custom_array: Array[GDs_Data_EP_Sitio] = []
	
	for item_data in json_array:
		var custom_item = GDs_Data_EP_Sitio.new(item_data)
		custom_array.append(custom_item)
		
	return custom_array
