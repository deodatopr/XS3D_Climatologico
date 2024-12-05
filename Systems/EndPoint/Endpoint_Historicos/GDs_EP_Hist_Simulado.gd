class_name GDs_EP_Hist_Simulado  extends Node

var arrayDatos : Array[GDs_Data_EP_Historicos] = []
var dateValue : String

func GenerateRandomValues(_fromDate : String):
	arrayDatos.clear()
	
	#Each 15 min a sample, 96 samples in 24 hours
	var totalSamplesByDay : int = 96
	
	var year : int =  int(_fromDate.substr(0,4))
	var month : int = int(_fromDate.substr(5,2))
	var day : int = int(_fromDate.substr(8,2))
	var hour : int = int(_fromDate.substr(10,2))
	var minute : int = int(_fromDate.substr(13,2))
	
	for n in totalSamplesByDay:
		var fixedMonth : String = str("0",month) if month < 10 else str(month)
		var fixedDay : String = str("0",day) if day < 10 else str(day)
		var fixedHour : String = str("0",hour) if hour < 10 else str(hour)
		var fixedMinute : String = str("0",minute) if minute < 10 else str(minute)
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
	
	#Filtrar datos de historicos para solo obtener por hora, en total 24
	# NOTA: int(_sample.tiempo.substr(13,2)) == 0 : Comparamos los minutos solo cuando sea 0 es cuando es una hora y oslo agregar eso al array final
	arrayDatos = arrayDatos.filter(func(_sample : GDs_Data_EP_Historicos): return int(_sample.tiempo.substr(13,2)) == 0)

	SIGNALS.OnRequestResult_Hist_Success.emit()
		
func GetHistoricos() -> Array[GDs_Data_EP_Historicos]:
	return arrayDatos
