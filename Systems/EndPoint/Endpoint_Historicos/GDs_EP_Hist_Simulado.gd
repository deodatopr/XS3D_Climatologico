class_name GDs_EP_Hist_Simulado  extends Node

var arrayDatos : Array[GDs_Data_EP_Historicos] = []
var dateValue : String

func GenerateRandomValues(Samples : int, _fromDate : String):
	arrayDatos.clear()
	
	var year : int =  int(_fromDate.substr(0,4))
	var month : int = int(_fromDate.substr(5,2))
	var day : int = int(_fromDate.substr(8,2))
	var hour : int = int(_fromDate.substr(10,2))
	var minute : int = int(_fromDate.substr(13,2))
	
	
	for n in Samples:
		var fixedMonth : String = str("0",month) if month < 10 else str(month)
		var fixedDay : String = str("0",day) if day < 10 else str(day)
		var fixedHour : String = str("0",hour) if hour < 10 else str(hour)
		var fixedMinute : String = str("0",hour) if hour < 10 else str(hour)
		dateValue = str(year,"-",fixedMonth,"-",fixedDay,"T",fixedHour,":",fixedMinute,":00")
		
		var rng = RandomNumberGenerator.new()
		var NewData : GDs_Data_EP_Historicos = GDs_Data_EP_Historicos.new()
		NewData.idSignals = 1
		NewData.valor = rng.randi_range(0, 20)
		NewData.tiempo = dateValue
		arrayDatos.append(NewData)
		
		minute -= 15
		
		if minute < 0:
			minute += 60
			hour -= 1
			
		if hour < 0:
			hour = 23
			day -= 1
			
		if day == 0:
			if month == 3 and year%4 == 0:
				day = 29
				month -= 1
			elif month == 3  and year%4 != 0:
				day = 28
				month -= 1
			elif month == 1 or month == 2 or month == 4 or month == 6 or month == 8 or month == 9 or month == 11:
				day = 31
				month -= 1
			elif month == 5 or month == 7 or month == 10 or month == 12:
				day = 30
				month -= 1
		
		if month == 0:
			year -= 1
			month = 12
	
	SIGNALS.OnRequestResult_Hist_Success.emit()
		
func GetHistoricos() -> Array[GDs_Data_EP_Historicos]:
	return arrayDatos

func GetSamplesFromDate(_fromDate : String, _toDate : String)->int:

	var fromHour : String = _fromDate.substr(11,2)
	var toHour : String =  _toDate.substr(11,2)

	var delimiter : String = "T"
	
	var indexFrom : int = _fromDate.find(delimiter)
	var fromDate = _fromDate.substr(0,indexFrom).split("-")
	
	var indexTo : int = _toDate.find(delimiter)
	var toDate = _toDate.substr(0,indexTo).split("-")
	
	var FinalSamples : int = 0
	FinalSamples += abs((int(fromHour) - int(toHour))*4)
	
	var years = abs(int(fromDate[0]) - int(toDate[0]))
	FinalSamples += years * 365 * 24 * 4
	
	var months = abs(int(fromDate[1]) - int(toDate[1]))
	FinalSamples += months * 30 * 24 * 4
	FinalSamples += (months/2) * 24 * 4
	
	var days = abs(int(fromDate[2]) - int(toDate[2]))
	FinalSamples += days * 24 * 4
	
	return FinalSamples
