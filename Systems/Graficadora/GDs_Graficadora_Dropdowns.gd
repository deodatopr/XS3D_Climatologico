class_name GDs_Graficadora_Dropdowns extends Node

@export var fromYear:OptionButton
@export var toYear:OptionButton
@export var fromMonth:OptionButton
@export var toMonth:OptionButton
@export var fromDay:OptionButton
@export var toDay:OptionButton
@export var fromTime:OptionButton
@export var toTime:OptionButton

# Called when the node enters the scene tree for the first time.
func Initialize():
	InitializeYearDropdown(fromYear)
	InitializeYearDropdown(toYear)
	InitializeMonthDropdown(fromMonth)
	InitializeMonthDropdown(toMonth)
	InitializedDayDropdown(fromDay)
	InitializedDayDropdown(toDay)
	InitializedTimeDropdown(fromTime)
	InitializedTimeDropdown(toTime)

func InitializeYearDropdown(yearOB:OptionButton):
	yearOB.clear()
	var currentYear = Time.get_datetime_dict_from_system().year
	yearOB.add_item("Año",0)
	for year in 5:
		yearOB.add_item(str(currentYear - year)+"   ",year + 1)

func InitializeMonthDropdown(monthOB:OptionButton):
	monthOB.clear()
	monthOB.get_popup().max_size = Vector2(9999,200)
	
	monthOB.add_item("Mes",0)
	
	
	monthOB.add_item("Enero  ",1)
	monthOB.add_item("Febrero  ",2)
	monthOB.add_item("Marzo  ",3)
	monthOB.add_item("Abril  ",4)
	monthOB.add_item("Mayo  ",5)
	monthOB.add_item("Junio  ",6)
	monthOB.add_item("Julio  ",7)
	monthOB.add_item("Agosto  ",8)
	monthOB.add_item("Septiembre   ",9)
	monthOB.add_item("Octubre   ",10)
	monthOB.add_item("Noviembre   ",11)
	monthOB.add_item("Diciembre   ",12)

func InitializedDayDropdown(dayOB:OptionButton):
	dayOB.clear()
	dayOB.get_popup().max_size = Vector2(9999,200)
	
	dayOB.add_item("Día",0)
	for day in 31:
		dayOB.add_item(str(day + 1) + "   ",day + 1)

func InitializedTimeDropdown(timeOB:OptionButton):
	timeOB.clear()
	timeOB.get_popup().max_size = Vector2(9999,200)
	timeOB.get_popup().min_size = Vector2(100,0)
	timeOB.add_item("Hora",0)
	for time in 24:
		timeOB.add_item(str(time) + ":00",time + 1)

#func UpdateFromTimeDropdown():
	#if fromDay.selected ==
	#pass 
