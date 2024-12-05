class_name GDs_Graficadora_Dropdowns
extends Node

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
	fromDay.item_selected.connect(UpdateAllDropdowns)
	fromMonth.item_selected.connect(UpdateAllDropdowns)
	fromYear.item_selected.connect(UpdateAllDropdowns)
	fromTime.item_selected.connect(UpdateAllDropdowns)
	toDay.item_selected.connect(UpdateAllDropdowns)
	toMonth.item_selected.connect(UpdateAllDropdowns)
	toYear.item_selected.connect(UpdateAllDropdowns)
	toTime.item_selected.connect(UpdateAllDropdowns)
	
	InitializeYearDropdown(fromYear)
	InitializeYearDropdown(toYear)
	InitializeMonthDropdown(fromMonth)
	InitializeMonthDropdown(toMonth)
	InitializedDayDropdown(fromDay)
	InitializedDayDropdown(toDay)
	InitializedTimeDropdown(fromTime)
	InitializedTimeDropdown(toTime)
	
	toYear.disabled = true
	toMonth.disabled = true
	toDay.disabled = true
	toTime.disabled = true

func InitializeYearDropdown(yearOB:OptionButton):
	yearOB.clear()
	yearOB.get_popup().max_size = Vector2(9999,200)
	yearOB.get_popup().min_size = Vector2(100,0)
	
	
	var currentYear = Time.get_datetime_dict_from_system().year
	yearOB.add_item("Año",0)
	for year in 5:
		yearOB.add_item(str(currentYear - year),year + 1)

func InitializeMonthDropdown(monthOB:OptionButton):
	monthOB.clear()
	monthOB.get_popup().max_size = Vector2(9999,200)
	monthOB.get_popup().min_size = Vector2(150,0)
	
	monthOB.add_item("Mes",0)
	
	
	monthOB.add_item("Enero",1)
	monthOB.add_item("Febrero",2)
	monthOB.add_item("Marzo",3)
	monthOB.add_item("Abril",4)
	monthOB.add_item("Mayo",5)
	monthOB.add_item("Junio",6)
	monthOB.add_item("Julio",7)
	monthOB.add_item("Agosto",8)
	monthOB.add_item("Septiembre",9)
	monthOB.add_item("Octubre",10)
	monthOB.add_item("Noviembre",11)
	monthOB.add_item("Diciembre",12)

func InitializedDayDropdown(dayOB:OptionButton):
	dayOB.clear()
	dayOB.get_popup().max_size = Vector2(9999,200)
	dayOB.get_popup().min_size = Vector2(100,200)
	
	dayOB.add_item("Día",0)
	for day in 31:
		dayOB.add_item(str(day + 1),day + 1)

func InitializedTimeDropdown(timeOB:OptionButton):
	timeOB.clear()
	timeOB.get_popup().max_size = Vector2(9999,200)
	timeOB.get_popup().min_size = Vector2(100,0)
	timeOB.add_item("Hora",0)
	for time in 24:
		timeOB.add_item(str(time) + ":00",time + 1)

func UpdateAllDropdowns(arg:int):
	UpdateFromMonthDropdown()
	UpdateFromDayDropdown()
	UpdateFromTimeDropdown()
	
	UpdateToYearDropdown()
	UpdateToMonthDropdown()
	UpdateToDayDropdown()
	UpdateToTimeDropdown()

func SetAllDisable(optionButton:OptionButton, _bool:bool):
	for option in optionButton.item_count:
		optionButton.set_item_disabled(option,_bool)

func UpdateFromMonthDropdown():
	SetAllDisable(fromMonth,false)
	if fromYear.get_item_text(fromYear.selected) == str(Time.get_datetime_dict_from_system().year):
		for month in range(Time.get_datetime_dict_from_system().month + 1,12):
			fromMonth.set_item_disabled(month,true)

func UpdateFromDayDropdown():
	SetAllDisable(fromDay,false)
	match fromMonth.get_item_text(fromMonth.selected):
		"Enero","Marzo","Mayo","Julio","Agosto","Octubre","Diciembre":
			fromDay.set_item_disabled(31,false)
		"Abril","Junio","Septiembre","Noviembre":
			fromDay.set_item_disabled(31,true)
		"Febrero":
			fromDay.set_item_disabled(29,true)
			fromDay.set_item_disabled(30,true)
			fromDay.set_item_disabled(31,true)
			
			
	if fromMonth.selected == Time.get_datetime_dict_from_system().month and fromYear.get_item_text(fromYear.selected) == str(Time.get_datetime_dict_from_system().year):
		for day in range(Time.get_datetime_dict_from_system().day + 1,32):
			fromDay.set_item_disabled(day,true)
	
func UpdateFromTimeDropdown():
	SetAllDisable(fromTime,false)
	if fromDay.selected == Time.get_datetime_dict_from_system().day and fromMonth.selected == Time.get_datetime_dict_from_system().month and fromYear.get_item_text(fromYear.selected) == str(Time.get_datetime_dict_from_system().year):
		for time in range(Time.get_datetime_dict_from_system().hour + 1,24):
			fromTime.set_item_disabled(time ,true)


func UpdateToYearDropdown():
	if fromYear.selected != 0:
		toYear.disabled = false
	else:
		toYear.disabled = true
	
	SetAllDisable(toYear,false)
	for year in range(fromYear.selected + 1, toYear.item_count):
		toYear.set_item_disabled(year,true)

func UpdateToMonthDropdown():
	if fromMonth.selected != 0:
		toMonth.disabled = false
	else:
		toMonth.disabled = true
	
	SetAllDisable(toMonth,false)
	
	if fromYear.selected == toYear.selected:
		for month in range(fromMonth.selected - 1,0, -1):
			toMonth.set_item_disabled(month,true)

func UpdateToDayDropdown():
	if fromDay.selected != 0:
		toDay.disabled = false
	else:
		toDay.disabled = true
	SetAllDisable(toDay,false)
	
	#Deshabilitar opciones menores al dropdown "from"
	if fromYear.selected == toYear.selected and fromMonth.selected == toMonth.selected:
		for day in range(fromDay.selected - 1 , 0,-1):
			toDay.set_item_disabled(day,true)
	
	#deshabilitar opciones mayores a la fecha y hora actual
	if toMonth.selected == Time.get_datetime_dict_from_system().month and toYear.get_item_text(toYear.selected) == str(Time.get_datetime_dict_from_system().year):
		for day in range(Time.get_datetime_dict_from_system().day + 1,32):
			toDay.set_item_disabled(day,true)

func UpdateToTimeDropdown():
	if fromTime.selected != 0:
		toTime.disabled = false
	else:
		toTime.disabled = true
	SetAllDisable(toTime,false)
	
	#Deshabilitar opciones menores al dropdown "from"
	if fromYear.selected == toYear.selected and fromMonth.selected == toMonth.selected and fromDay.selected == toDay.selected:
		for time in range(fromTime.selected,0, -1):
			if time <= 24:
				toTime.set_item_disabled(time,true)
	
	#deshabilitar opciones mayores a la fecha y hora actual
	if toDay.selected == Time.get_datetime_dict_from_system().day and toMonth.selected == Time.get_datetime_dict_from_system().month and toYear.get_item_text(toYear.selected) == str(Time.get_datetime_dict_from_system().year):
		for time in range(Time.get_datetime_dict_from_system().hour + 2,25):
			if time <= 24:
				toTime.set_item_disabled(time,true)
