class_name GDs_EP_Hist extends Node

@onready var http_request = $HTTPRequest

var historicos : Array[GDs_Data_EP_Historicos]
var isBusy : bool
var URL : String

func Initialize(_url : String):
	URL = _url
	http_request.request_completed.connect(OnRequest_Completed)
	
func Request(_id : int, _dateFrom : String, _dateTo : String):
	if isBusy:
		return
	
	isBusy = true
	
	#HACK: Usando endpoint de lumbreras para testear
	var signalSite : int = 6000000 + _id

	var headers = ["Content-Type: application/json"]
	var body_data = {"IdSignals": [signalSite], "FechaInicial": _dateFrom, "FechaFinal": _dateTo}
	var json_body = JSON.stringify(body_data)
	http_request.request(URL, headers, HTTPClient.METHOD_POST, json_body)

func OnRequest_Completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		var json = JSON.parse_string(body.get_string_from_utf8())
		historicos.clear()
		for data in json:
			var rng = RandomNumberGenerator.new()
			var newData : GDs_Data_EP_Historicos = GDs_Data_EP_Historicos.new()
			newData.idSignals = data.IdSignal
			
			#HACK: Poniendo valores random para graficar algo ya que muchas veces no llega
			newData.valor = float(rng.randi_range(0, 20))
			newData.tiempo = data.Tiempo
			historicos.append(newData)
			
		SIGNALS.OnRequestResult_Hist_Success.emit()
		print_rich("[color=green]Request [ Historicos ] success..![/color].")
	else:
		SIGNALS.OnRequestResult_Hist_Error.emit()
		print_rich("[color=red]Request [ Historicos ] failed by internet..![/color].")
		
	isBusy = false
		
func GetHistoricos() -> Array[GDs_Data_EP_Historicos]:
	return historicos
