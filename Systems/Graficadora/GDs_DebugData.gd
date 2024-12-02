extends Node
class_name GDs_Debug

var GlobalDicDate : Dictionary

func _randomValues(Samples : int, _fromDate : String, _fromHour : String, _fromMin : String)->Array[GDs_Data]:
	var RandomData : Array[GDs_Data] = []
	var fromDate = _fromDate.split("-")
	GlobalDicDate = Time.get_datetime_dict_from_system()
	GlobalDicDate.year = int(fromDate[0])
	GlobalDicDate.month = int(fromDate[1])
	GlobalDicDate.day = int(fromDate[2])
	GlobalDicDate.hour = int(_fromHour)
	GlobalDicDate.minute = int(_fromMin)
	var GlobalDate:String = str(GlobalDicDate.year, "-", GlobalDicDate.month, "-", GlobalDicDate.day, "T", GlobalDicDate.hour if GlobalDicDate.hour > 9 else str("0", GlobalDicDate.hour), ":", GlobalDicDate.minute if GlobalDicDate.minute > 9 else str("0", GlobalDicDate.minute), ":", GlobalDicDate.second if GlobalDicDate.second > 9 else str("0", GlobalDicDate.second))
	#if randi() & 1:
	for n in Samples:
		var rng = RandomNumberGenerator.new()
		var NewData : GDs_Data = GDs_Data.new()
		NewData.idSignals = 1
		NewData.valor = rng.randi_range(0, 20)
		NewData.tiempo = GlobalDate
		RandomData.append(NewData)
		
		GlobalDicDate.minute -= 15
		
		if GlobalDicDate.minute < 0:
			GlobalDicDate.minute += 60
			GlobalDicDate.hour -= 1
			
		if GlobalDicDate.hour < 0:
			GlobalDicDate.hour = 23
			GlobalDicDate.day -= 1
			
		if GlobalDicDate.day == 0:
			if GlobalDicDate.month == 3 and GlobalDicDate.year%4 == 0:
				GlobalDicDate.day = 29
				GlobalDicDate.month -= 1
			elif GlobalDicDate.month == 3  and GlobalDicDate.year%4 != 0:
				GlobalDicDate.day = 28
				GlobalDicDate.month -= 1
			elif GlobalDicDate.month == 1 or GlobalDicDate.month == 2 or GlobalDicDate.month == 4 or GlobalDicDate.month == 6 or GlobalDicDate.month == 8 or GlobalDicDate.month == 9 or GlobalDicDate.month == 11:
				GlobalDicDate.day = 31
				GlobalDicDate.month -= 1
			elif GlobalDicDate.month == 5 or GlobalDicDate.month == 7 or GlobalDicDate.month == 10 or GlobalDicDate.month == 12:
				GlobalDicDate.day = 30
				GlobalDicDate.month -= 1
		
		if GlobalDicDate.month == 0:
			GlobalDicDate.year -= 1
			GlobalDicDate.month = 12
			
		GlobalDate = str(GlobalDicDate.year, "-", GlobalDicDate.month, "-", GlobalDicDate.day, "T", GlobalDicDate.hour if GlobalDicDate.hour > 9 else str("0", GlobalDicDate.hour), ":", GlobalDicDate.minute if GlobalDicDate.minute > 9 else str("0", GlobalDicDate.minute), ":", GlobalDicDate.second if GlobalDicDate.second > 9 else str("0", GlobalDicDate.second))
		
	return RandomData
		
	#return RandomData

func _getSamplesFromDate(_fromDate : String, _toDate : String, _fromHour : String, _toHour : String)->int:
	var FinalSamples = 0
	var fromDate = _fromDate.split("-")
	var toDate = _toDate.split("-")
	
	FinalSamples += abs((int(_fromHour) - int(_toHour))*4)
	
	var years = abs(int(fromDate[0]) - int(toDate[0]))
	FinalSamples += years * 365 * 24 * 4
	
	var months = abs(int(fromDate[1]) - int(toDate[1]))
	FinalSamples += months * 30 * 24 * 4
	FinalSamples += (months/2) * 24 * 4
	
	var days = abs(int(fromDate[2]) - int(toDate[2]))
	FinalSamples += days * 24 * 4
	
	return FinalSamples
