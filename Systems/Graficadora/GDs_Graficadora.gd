class_name GDs_Graficadora extends Node

@export_group("INTERNAL REFERENCES")

@export_subgroup("Colores Nivel")
@export var criticLevelColor : Color
@export var criticLevelRange : int
@export var dangerLevelColor : Color
@export var dangerLevelRange : int
@export var safeLevelColor : Color
@export var safeLevelRange : int

@export_subgroup("Pivots")
@export var pivotYMaxValue : Control
@export var pivotYMinValue : Control

@export_subgroup("Dropdowns")
@export var dpwnAno : OptionButton
@export var dpwnMes : OptionButton
@export var dpwnDia : OptionButton
@export var dpwnHora : OptionButton
@export var dpwnIntervalo : OptionButton

@export_subgroup("Items list")
@export var degraded_2d : Node2D
@export var line_2d : Node2D
@export var itemsPointsValues : Control
@export var itemsDates : Control

@export_subgroup("Refs Componentes")
@export var lblSiteName : Label
@export var lblDatesRange : Label
@export var btnGraficar : Button
@export var containerNodes2d : Control
@export var containerVertValuesLimits : Control
@export var popupLoading : Control
@export var popupNoHistory : Control
@export var scrollContainerGraphic : ScrollContainer
@export var graphicInitial : Control
@export var graphic : Control
@export var fechaAnimPlayer : AnimationPlayer
@export var sitiosAnimPlayer : AnimationPlayer
@export var joystickAnim : Control
@export var btnsSitios : Array[GDs_Graficadora_Item_BtnSitio] = []

var dateFromStruct : DateStruct = DateStruct.new()
var dateToStruct : DateStruct = DateStruct.new()

var dataService : GDs_DataService_Manager
var graf_loading : GDs_Graficadora_Anim_Loading

var itemsGrafPoints : Array[Control]
var itemsGrafDates_Hour : Array[Control]
var itemsGrafDates_Date : Array[Control]

var siteId : int = -1

func Initialize(_dataService : GDs_DataService_Manager, _graf_loading : GDs_Graficadora_Anim_Loading):
	dataService = _dataService
	graf_loading = _graf_loading
	
	#Connect signals
	btnGraficar.pressed.connect(_RequestGraficar.bind(true))
	SIGNALS.OnBtnGraficadoraMenuPressed.connect(_RequestGraficar.bind(false))
	SIGNALS.On_BtnSitioPressed.connect(OnBtnSitioPressed)
	
	#Initialize sitios Btns
	var idx : int = 0
	for btnSitio in btnsSitios:
		var sitio : GDs_Data_Sitio = _dataService.estaciones[idx]
		btnSitio.Initialize(sitio.color,sitio.id,sitio.nombre)
		idx += 1
		
	#Get graphic items (points & dates)
	for grafPoint in itemsPointsValues.get_children(true):
		itemsGrafPoints.append(grafPoint)
		
	for grafDate in itemsDates.get_children(true):
		itemsGrafDates_Hour.append(grafDate.get_child(0))
		itemsGrafDates_Date.append(grafDate.get_child(1))
		
	_ShowInitialGraphic()


func _ShowInitialGraphic():
	#Show only initial graphic
	lblSiteName.text = "GRAFICADORA"
	lblDatesRange.hide()
	
	graphicInitial.show()
	graphic.hide()
	

func _ShowGraphic():
	lblDatesRange.show()
	
	graphicInitial.hide()
	graphic.show()
	
func _ShowPopup_Loading(_show : bool):
	btnGraficar.disabled = _show
	
	for btnSitio in btnsSitios:
		btnSitio.disabled = _show
		
	dpwnAno.disabled = _show
	dpwnMes.disabled = _show
	dpwnDia.disabled = _show
	dpwnHora.disabled = _show
	dpwnIntervalo.disabled = _show
	
	if _show:
		popupLoading.show()
		itemsDates.hide()
		itemsPointsValues.hide()
		containerVertValuesLimits.hide()
		degraded_2d.hide()
		line_2d.hide()
		popupNoHistory.hide()
		scrollContainerGraphic.get_h_scroll_bar().hide()
		joystickAnim.hide()
		lblDatesRange.text ="Rango:   --/--/-- --:--     -     --/--/-- --:--"
	else:
		popupLoading.hide()
		itemsDates.show()
		itemsPointsValues.show()
		containerVertValuesLimits.show()
		degraded_2d.show()
		line_2d.show()
		itemsDates.show()
		scrollContainerGraphic.get_h_scroll_bar().show()
		joystickAnim.show()
	
func _ShowPopup_NoHistory():
	popupNoHistory.show()
	
	popupLoading.hide()
	itemsDates.hide()
	itemsPointsValues.hide()
	containerVertValuesLimits.hide()
	degraded_2d.hide()
	line_2d.hide()
	joystickAnim.hide()
	lblDatesRange.text ="Rango:   --/--/-- --:--     -     --/--/-- --:--"


func _RequestGraficar(_isByBtn : bool):
	_GetDatesFromDropdown()
	
	if not _Graficar_AreInputsValid(_isByBtn):
		return
	
	dataService.MakeRequest_Historicos(siteId,dateFromStruct.GetDate(),dateToStruct.GetDate())
	_ShowPopup_Loading(true)
	await SIGNALS.OnRefresh_Hist
	
	_ShowGraphic()
	Graficar(dataService.dataHistoricos)
	
func _GetDatesFromDropdown():
	var value_ano :int = int(dpwnAno.get_item_text(dpwnAno.selected))
	var value_mes :int = int(dpwnMes.selected)
	var value_dia :int = int(dpwnDia.get_item_text(dpwnDia.selected))
	var value_hora :int= int(dpwnHora.get_item_text(dpwnHora.selected).substr(0,2))
	
	APPSTATE.graficadoraRate = dpwnIntervalo.selected
	
	dateFromStruct.Update(value_ano,value_mes,value_dia,value_hora)
	dateToStruct = dateFromStruct.GetDayBefore()
	
#region [ BUTTONS SIGNALS ]
func OnBtnSitioPressed(_id : int, _name : String):
	siteId = _id
	lblSiteName.text = _name
	
	for btnSitio in btnsSitios:
		btnSitio.CheckBtnSelected(_id)

#region [ GRAFICAR ]
func Graficar(_arrayHistoricos : Array[GDs_Data_EP_Historicos]):	
	#si no recibe valores, muestre la pantalla sin historia
	if _arrayHistoricos.size() > 0:
		_Graficar_Valores(_arrayHistoricos)
		
		await graf_loading.FinishedAnimLoading

		_ShowPopup_Loading(false)
		
		scrollContainerGraphic.scroll_horizontal = 0
		itemsPointsValues.modulate.a = 1
		lblDatesRange.text = str("Rango:   ",UTILITIES.FormatDateGraficadoraRango(_arrayHistoricos[0].tiempo), "   -    ",UTILITIES.FormatDateGraficadoraRango(_arrayHistoricos[_arrayHistoricos.size() - 1].tiempo))
	else:
		_ShowPopup_NoHistory()
		
func _Graficar_AreInputsValid(_isByBtn : bool) -> bool:
	var dropdownsValid : bool = dpwnAno.selected != 0 and dpwnMes.selected != 0 and dpwnDia.selected != 0 and dpwnHora.selected != 0 and dpwnIntervalo.selected != 0
	var sitioIdIsValid : bool = siteId >= 0
	
	if not dropdownsValid:
		if _isByBtn:
			fechaAnimPlayer.stop()
			fechaAnimPlayer.play("DropdownMissing")
		return false
		
	if not sitioIdIsValid:
		sitiosAnimPlayer.stop()
		sitiosAnimPlayer.play("SiteMissing")
		return false
	
	popupNoHistory.visible = false
	
	scrollContainerGraphic.visible = true
	lblDatesRange.visible = true
	popupLoading.visible = true
	
	graf_loading.CargandoDatos()
	return true

func _Graficar_Valores(_data : Array[GDs_Data_EP_Historicos]):
	itemsPointsValues.show()
	itemsPointsValues.modulate.a = 0
	await get_tree().create_timer(.05).timeout
	#seteo los valores de la grafica
	for i in 24:
		#seteo texto de la hora
		if not _data[i].tiempo.is_empty():
			var date = _data[i].tiempo.split("T")
			var timeHrMin = _data[i].tiempo.substr(11,5)
			itemsGrafDates_Hour[i].text = timeHrMin
			itemsGrafDates_Date[i].text = date[0].erase(0, 2)
		else:
			itemsGrafDates_Hour[i].text = "---"
			itemsGrafDates_Date[i].text = "---"
			
		#seteo la posicion del value en y
		var posY01 : float = inverse_lerp(0,20,_data[i].valor)
		var posY : float = lerpf(pivotYMinValue.global_position.y, pivotYMaxValue.global_position.y,posY01)
		itemsGrafPoints[i].global_position.y = posY
		
		#obtiene todos los nodos hijos de los circulos de los valores para poder pintarlos
		var ValuesColor : Array[NinePatchRect] = []
		var ValueLabel : Label
		for value in itemsGrafPoints[i].get_children():
			if value.get_class() == "NinePatchRect":
				ValuesColor.append(value)
			elif value.get_class() == "Label":
				ValueLabel = value
		ValueLabel.text = str(_data[i].valor)
		
		#pinta todos los nodos de los colores segun el peligro
		for value in ValuesColor:
			if _data[i].valor >= criticLevelRange:
				value.modulate = criticLevelColor
			elif _data[i].valor < criticLevelRange and _data[i].valor >= dangerLevelRange:
				value.modulate = dangerLevelColor
			elif _data[i].valor < dangerLevelRange and _data[i].valor >= safeLevelRange:
				value.modulate = safeLevelColor
					
		#acomodo los puntos de la grafica, del poligono2d y de la linea2d
		var pointForNodes2d : float = lerpf(containerNodes2d.size.y, 0,posY01)
		degraded_2d.polygon[i+1].y = pointForNodes2d
		line_2d.points[i+1].y = pointForNodes2d

#endregion

class DateStruct:
	var year : int
	var month : int
	var day : int
	var hour : int
	
	func Update(_year : int,_month : int, _day : int, _hour : int):
		year = _year
		month = _month
		day = _day
		hour = _hour
		
	func GetDate()-> String:
		var fixedMonth : String = str("0",month) if month < 10 else str(month)
		var fixedDay : String = str("0",day) if day < 10 else str(day)
		var fixedHour : String = str("0",hour) if hour < 10 else str(hour)
		return str(year,"-",fixedMonth,"-",fixedDay,"T",fixedHour,":00:00")
		
	func GetDayBefore() -> DateStruct:
		var fixedHour : int = hour
		var fixedDay : int = day
		var fixedMonth : int = month
		var fixedYear : int = year
		
		fixedHour -= 1
		
		if fixedHour < 0:
			fixedHour = 23
			fixedDay -= 1
			
		if fixedDay == 0:
			if fixedMonth == 3 and year%4 == 0:
				fixedDay = 29
				fixedMonth -= 1
			elif fixedMonth == 3  and year%4 != 0:
				fixedDay = 28
				fixedMonth -= 1
			elif fixedMonth == 1 or fixedMonth == 2 or fixedMonth == 4 or fixedMonth == 6 or fixedMonth == 8 or fixedMonth == 9 or fixedMonth == 11:
				fixedDay = 31
				fixedMonth -= 1
			elif fixedMonth == 5 or fixedMonth == 7 or fixedMonth == 10 or fixedMonth == 12:
				fixedDay = 30
				fixedMonth -= 1
		
		if fixedMonth == 0:
			fixedYear -= 1
			fixedMonth = 12
		
		var dayBefore : DateStruct = DateStruct.new()
		dayBefore.Update(fixedYear,fixedMonth,fixedDay,fixedHour)
		
		return dayBefore
		
