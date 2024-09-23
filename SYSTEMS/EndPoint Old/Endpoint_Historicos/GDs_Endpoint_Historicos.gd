extends Node

class_name GDs_Endpoint_Historicos

@export var crLocalSitios : GDs_CR_LocalSitios
@export var endpointURL : String
@export var diasDelMes : Array[int] = []
@export var timerTicking : Timer

@onready var http_request : HTTPRequest = $HTTPRequest

signal On_Request_Success
signal On_Request_Failed_BY_INTERNET

signal On_TimeoutToRefreshHistoricos

var DEBUG_overrideResponseResult : bool
var DEBUG_responseResult : int
var DEBUG_nivelesGraficaRnd : bool

var sitioHistoricos : Array[GDs_DATA_HISTORICOS] = []
var historicos : GDs_Historico

var isRequestBusy : bool
var nextMinExpected : int

var lastSitio : int = -1
var lastFecha : String = "0000-00-00T00:00:00"

var testFecha : String = "2024-03-07T01:28:02"
var testSitio : int  = 6000007

func _ready():
	http_request.timeout = 3
	http_request.request_completed.connect(_on_request_completed)
	timerTicking.timeout.connect(OnTimeoutToRefreshHistoricos)
	
	#---- Probar endpoint
	#RequestHistoricos(testSitio,testFecha)
	#await On_Request_Success
	#var test = GetHistoricos()
	#print("Debug")

func SetDebugOption(_DEBUG_overrideResponseResult : bool, _DEBUG_nivelesGraficaRnd):
	DEBUG_overrideResponseResult = _DEBUG_overrideResponseResult
	DEBUG_nivelesGraficaRnd = _DEBUG_nivelesGraficaRnd

func RequestHistoricos(_sitio : int, _fechaFinal : String):
	lastSitio = _sitio
	lastFecha = _fechaFinal
	
	#Hacer array el sitio que es como lo pide el request
	var arraySitio : Array[int] = []
	arraySitio.append(_sitio)
	
	#Parametros a enviar junto con request
	var _fechaInicial : String = GetFechaInicial(_fechaFinal,3)
	var data = {"IdSignals" : arraySitio,"FechaInicial" : _fechaInicial, "FechaFinal" : _fechaFinal}
	var body = JSON.stringify(data)
	
	#Teoria: Que el request acepte json
	var headers = ["Content-Type: application/json"]
	
	#Hacer request
	if isRequestBusy:
		http_request.cancel_request()
		
	http_request.request(endpointURL, headers, HTTPClient.METHOD_POST, body)
	isRequestBusy = true

func Retry_RequestHistoricosAfterError():
	RequestHistoricos(lastSitio,lastFecha)

func GetHistoricos() -> GDs_Historico:
	return historicos
	
func OnTimeoutToRefreshHistoricos():
	On_TimeoutToRefreshHistoricos.emit()

func _on_request_completed(result, _response_code, _headers, body):
	if DEBUG_overrideResponseResult:
		if DEBUG_responseResult == 0:
			var rnd = RandomNumberGenerator.new()
			var rndNumber = rnd.randi_range(0,1)
			DEBUG_responseResult = 4 if rndNumber == 0 else 6
		else:
			DEBUG_responseResult = 0
			
		result = DEBUG_responseResult
		print_rich("[color=orange]-------- DEBUG RESULT RESPONSE [Historico] ENABLE ------------------ [/color]")
	
	if result == HTTPRequest.RESULT_SUCCESS:
		var dataFromServer = JSON.parse_string(body.get_string_from_utf8())
		sitioHistoricos = CastJsonToArrayHistorico(dataFromServer)
		
		BuildHistoricosClass(sitioHistoricos)
		StartTimer(lastFecha)
		On_Request_Success.emit()
		print_rich("[color=green]Request [Historicos] success..![/color].")
	else:
		StopTimer()
		On_Request_Failed_BY_INTERNET.emit()
		print_rich("[color=red]Request [Get all sitios] failed by internet..![/color].")
		
	isRequestBusy = false

func BuildHistoricosClass(_sitioHistoricosArray : Array[GDs_DATA_HISTORICOS]):
	var sitioFromCR = crLocalSitios.GetSitio(lastSitio)
	historicos = GDs_Historico.new()
	historicos.idSitio = lastSitio
	historicos.estructura = sitioFromCR.NombreEstructura
	historicos.idLocal = sitioFromCR.IdLocal
	historicos.fecha = FormatFecha(lastFecha)
	historicos.nameSitio = sitioFromCR.Abreviacion
	historicos.hasData = true if DEBUG_nivelesGraficaRnd else sitioHistoricos.size() > 0
	historicos.nvlCrit =  FormatValueToCm(sitioFromCR.NvlCritico)
	historicos.nvlPrev = FormatValueToCm(sitioFromCR.NvlPreventivo)
	
	var nvlNormal : float = sitioFromCR.NvlNormal
	if sitioFromCR.NvlNormal == 0:
		nvlNormal = sitioFromCR.NvlPreventivo / 2
	historicos.nvlNor = FormatValueToCm(nvlNormal)
	
	if historicos.hasData:
		#Valores verticales para graficar
		historicos.valuesNvlGrafVertical.append(historicos.nvlCrit)
		historicos.valuesNvlGrafVertical.append(historicos.nvlPrev + ((historicos.nvlCrit - historicos.nvlPrev)/2))
		historicos.valuesNvlGrafVertical.append(historicos.nvlPrev)
		historicos.valuesNvlGrafVertical.append(historicos.nvlPrev * .5)
		historicos.valuesNvlGrafVertical.append(0.00)
		
		#Llenar hr y valor de cada historico
		
		if _sitioHistoricosArray.size() > 12:
			_sitioHistoricosArray.reverse()
			_sitioHistoricosArray.resize(12)
			_sitioHistoricosArray.reverse()
			
			for itemHist in _sitioHistoricosArray:
				var hr = itemHist.Tiempo.substr(11,5)
				historicos.valuesHrGrafHorizontal.append(hr)
				
				var valueCm = FormatValueToCm(itemHist.Valor) 
				historicos.values.append(valueCm)
				
				var semaforo = ENUMS.SEMAFORO.NORMAL
				if valueCm >= historicos.nvlPrev and valueCm < historicos.nvlCrit:
					semaforo = ENUMS.SEMAFORO.PREV
				elif valueCm >= historicos.nvlCrit:
					semaforo = ENUMS.SEMAFORO.CRIT
				
				historicos.semaforos.append(semaforo)
				
				#Posicionar puntos con valores normalizados
				var value01 = 0.0
				if valueCm > historicos.nvlPrev:
					value01 = clampf(inverse_lerp(historicos.nvlPrev, historicos.nvlCrit, valueCm)  * 0.5 +0.5,0,1)
				else:
					value01 = clampf((inverse_lerp(0, historicos.nvlPrev, valueCm) * 0.5) ,0,1)
					
				historicos.values01.append(value01)
		elif _sitioHistoricosArray.size() < 12:
			#Cachar indices faltantes para tener los 12 valores
			var firstValueSet : bool
			var idxMissing : Array[int] = []
			
			var idx = 0
			for itemHist in _sitioHistoricosArray:
				var hr = itemHist.Tiempo.substr(11,5)
				var minutes = int(hr.substr(3,2))
				
				if not firstValueSet:
					nextMinExpected = minutes
					firstValueSet = true
					
				var isMissingAValue : bool = minutes != nextMinExpected
				CalculateNextMinutes(minutes)
				if isMissingAValue:
					idxMissing.append(idx)
				idx += 1
				
			if _sitioHistoricosArray.size() + idxMissing.size() < 12:
				var missinElements = 12 - _sitioHistoricosArray. size()
				for elemtns in missinElements:
					var nullElement =  GDs_DATA_HISTORICOS.new()
					nullElement.IdSignal = NAN
					nullElement.Valor = NAN
					_sitioHistoricosArray.append(nullElement)
			else:
				for elemtnMissing in idxMissing:
					var nullElement =  GDs_DATA_HISTORICOS.new()
					nullElement.IdSignal = NAN
					nullElement.Valor = NAN
					_sitioHistoricosArray.insert(elemtnMissing,nullElement)
			

			for itemHist in _sitioHistoricosArray:
				var dataIsMissing = itemHist.Tiempo.is_empty()
				var hr = "null" if dataIsMissing else  itemHist.Tiempo.substr(11,5)
				historicos.valuesHrGrafHorizontal.append(hr)
				
				var valueCm = FormatValueToCm(itemHist.Valor) 
				historicos.values.append(valueCm)
				
				var value01 = 0.0 
				if not dataIsMissing:
					#Posicionar puntos con valores normalizados
					if valueCm > historicos.nvlPrev:
						value01 = clampf(inverse_lerp(historicos.nvlPrev, historicos.nvlCrit, valueCm)  * 0.5 +0.5,0,1)
					else:
						value01 = clampf((inverse_lerp(0, historicos.nvlPrev, valueCm) * 0.5) ,0,1)
						
				historicos.values01.append(value01)
				
				var semaforo = ENUMS.SEMAFORO.NORMAL
				if dataIsMissing:
					semaforo = ENUMS.SEMAFORO.NULL
				elif valueCm >= historicos.nvlPrev and valueCm < historicos.nvlCrit:
					semaforo = ENUMS.SEMAFORO.PREV
				elif valueCm >= historicos.nvlCrit:
					semaforo = ENUMS.SEMAFORO.CRIT
				
				historicos.semaforos.append(semaforo)
				idx+=1
		else:
			for itemHist in _sitioHistoricosArray:
				var hr = itemHist.Tiempo.substr(11,5)
				historicos.valuesHrGrafHorizontal.append(hr)
				
				var valueCm = FormatValueToCm(itemHist.Valor) 
				historicos.values.append(valueCm)
				
				
				var semaforo = ENUMS.SEMAFORO.NORMAL
				if valueCm >= historicos.nvlPrev and valueCm < historicos.nvlCrit:
					semaforo = ENUMS.SEMAFORO.PREV
				elif valueCm >= historicos.nvlCrit:
					semaforo = ENUMS.SEMAFORO.CRIT
				
				historicos.semaforos.append(semaforo)
				
				#Posicionar puntos con valores normalizados
				var value01 = 0.0
				if valueCm > historicos.nvlPrev:
					value01 = clampf(inverse_lerp(historicos.nvlPrev, historicos.nvlCrit, valueCm)  * 0.5 +0.5,0,1)
				else:
					value01 = clampf((inverse_lerp(0, historicos.nvlPrev, valueCm) * 0.5) ,0,1)
				
				historicos.values01.append(value01)
				
# Convierte el JSON array a instancias de array custom
func CastJsonToArrayHistorico(json_array: Array) -> Array[GDs_DATA_HISTORICOS]:
	var custom_array: Array[GDs_DATA_HISTORICOS] = []

#Obtener y setear cada propiedad de la clase GDs_DATA_HISTORICOS para agregarlo al array
	for item_data in json_array:
		var custom_item = GDs_DATA_HISTORICOS.new()
		custom_item.IdSignal = item_data["IdSignal"]
		custom_item.Valor = item_data["Valor"]
		custom_item.Tiempo = item_data["Tiempo"]
		
		custom_array.append(custom_item)
		
	return custom_array
	
func GetFechaInicial(_fechaFinal : String, _hrsParaMostrar):
	var year = int(_fechaFinal.substr(0,4))
	var month = int(_fechaFinal.substr(5,2))
	var day = int(_fechaFinal.substr(8,2))
	var hr = int(_fechaFinal.substr(11,2))
	
	#Calcular hr
	for i in range(_hrsParaMostrar):
		var validateHr = hr - 1
		hr = 23 if validateHr < 0 else validateHr
	
	#Calcular dia, mes y año
	if hr >= 21:
		#Dia
		var validateDay = day - 1
		if validateDay == 0:
			#Mes
			var validateMonth = month - 1
			if validateMonth == 0:
				month = 12
				#Año
				year -= 1
			else:
				month = validateMonth
				
			day = diasDelMes[month]
		else:
			day = validateDay
	
	#Regresar valores a string para poder sustituirlos y armar la fecha final
	var yearString = str(year)
	var monthString = str("0",month) if month <= 9 else str(month)
	var dayString = str("0",day) if day <= 9 else str(day)
	
	var hrString = str("0",hr) if hr <= 9 else str(hr)
	
	#Inyectar valores calculados para la fecha inicial
	var fechaInicial = _fechaFinal
	fechaInicial[0] = yearString[0]
	fechaInicial[1] = yearString[1]
	fechaInicial[2] = yearString[2]
	fechaInicial[3] = yearString[3]
	
	fechaInicial[5] = monthString[0]
	fechaInicial[6] = monthString[1]
	
	fechaInicial[8] = dayString[0]
	fechaInicial[9] = dayString[1]
	
	fechaInicial[11] = hrString[0]
	fechaInicial[12] = hrString[1]
	
	return fechaInicial
	
func StartTimer(_fechaFinal : String):
	var minutes = int(_fechaFinal.substr(14,2))
	var _timerDuration : float = -1
	
	if minutes > 0 and minutes < 15: _timerDuration = 15 - minutes
	elif minutes > 15 and minutes < 30: _timerDuration = 30 - minutes
	elif minutes > 30 and minutes < 45: _timerDuration = 45 - minutes
	else: _timerDuration = 60 - minutes
	
	timerTicking.start(_timerDuration * 60)
	
func StopTimer():
	if not timerTicking.is_stopped():
		timerTicking.stop()

func FormatValueToCm(_value : float) -> float:
	return _value * 100
	
func FormatFecha(_fecha : String) -> String:
	var ultAct : String = "Última Act: " 
	var year = _fecha.substr(0,4)
	var month = _fecha.substr(5,2)
	var day = _fecha.substr(8,2)
	var hr = _fecha.substr(11,2)
	
	var _min = int(_fecha.substr(14,2))
	var fixedMin : int = -1
	
	if _min < 15:
		fixedMin = 0
	elif _min >= 15 and _min < 30:
		fixedMin = 15
	elif _min >= 30 and _min < 45:
		fixedMin = 30
	else:
		fixedMin = 45
		
		
	var minString = str("0",fixedMin) if fixedMin == 0 else str(fixedMin)
	return str(ultAct," ", hr, ":",str(minString)," - ",day,"/",month,"/",year)
	
func CalculateNextMinutes(_minToEvaluate : int) -> int:
	match _minToEvaluate:
		0:
			nextMinExpected = 15
		15:
			nextMinExpected = 30
		30:
			nextMinExpected = 45
		45:
			nextMinExpected = 0
			
			
	return nextMinExpected
