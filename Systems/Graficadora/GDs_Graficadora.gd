class_name GDs_Graficadora extends Node

@export_group("INTERNAL REFERENCES")

@export_subgroup("Colores Nivel")
@export var criticLevelColor : Color
@export var criticLevelRange : int
@export var dangerLevelColor : Color
@export var dangerLevelRange : int
@export var safeLevelColor : Color
@export var safeLevelRange : int

@export_subgroup("Dropdowns")
@export var inicio_Ano : OptionButton
@export var inicio_Mes : OptionButton
@export var inicio_Dia : OptionButton
@export var inicio_Hora : OptionButton
@export var inicio_Intervalo : OptionButton

@export_subgroup("Refs Componentes")
@export var fechaAnimPlayer : AnimationPlayer
@export var btnGraficar : Button
@export var degradedChart : Node2D
@export var lineChart : Node2D
@export var ChartBoxContainer : Control
@export var Chart : Control
@export var horChartLines : Control
@export var horTimeInfo : Control
@export var vertInfo : Control
@export var horInfo : Control
@export var ScrollInfo : HScrollBar
@export var SitesBttnContainer : Control
@export var SiteName : Label
@export var lblDatesRange : Label
@export var LoadingScreen : Control
@export var WhitoutHistory : Control
@export var Info : Control
@export var ChartBackground : Control
@export var ChartMaskInitial : Control
@export var ChartValuesMask : Control
@export var btnsSitios : Array[GDs_Graficadora_Item_BtnSitio] = []

const SEPARATION = 80

var dateFromStruct : DateStruct = DateStruct.new()
var dateToStruct : DateStruct = DateStruct.new()

var dataService : GDs_DataService_Manager
var graf_loading : GDs_Graficadora_Anim_Loading

var crrntHistoricos : Array[GDs_Data_EP_Historicos]

var VertLenght : float
var currentCharInfo : int = 12
var totalInfo : int = 52
var linesPool : Array[NinePatchRect]
var valuesPool : Array[NinePatchRect]
var hrsPool : Array[Label]
var datePool : Array[Label]
var isDragingChart : bool
var siteId : int = -1

func Initialize(_dataService : GDs_DataService_Manager, _graf_loading : GDs_Graficadora_Anim_Loading):
	dataService = _dataService
	graf_loading = _graf_loading
	
	btnGraficar.pressed.connect(_RequestGraficar.bind(true))
	SIGNALS.OnBtnGraficadoraMenuPressed.connect(_RequestGraficar.bind(false))
	
	ScrollInfo.scrolling.connect(_on_h_scroll_bar_scrolling)
	ScrollInfo.value_changed.connect(_on_scroll_info_value_changed)
	SIGNALS.On_BtnSitioPressed.connect(OnBtnSitioPressed)
	
	var idx : int = 0
	for btnSitio in btnsSitios:
		var sitio : GDs_Data_Sitio = _dataService.estaciones[idx]
		btnSitio.Initialize(sitio.color,sitio.id,sitio.nombre)
		idx += 1
	
	#obtengo la altura de la grafica
	VertLenght = Chart.size.y
	
	lblDatesRange.visible = false
	
	SiteName.text = "GRAFICADORA"
	lblDatesRange.hide()
	
	degradedChart.hide()
	lineChart.hide()
	ChartValuesMask.hide()
	ScrollInfo.hide()
	horInfo.hide()
	vertInfo.hide()
	ChartMaskInitial.show()

func _ShowChartInfo():
	degradedChart.show()
	lineChart.show()
	ChartValuesMask.show()
	ScrollInfo.show()
	horInfo.show()
	vertInfo.show()
	ChartMaskInitial.hide()

func _RequestGraficar(_isByBtn : bool):
	_GetDatesFromDropdown()
	
	if not Graficar_AreInputsValid(_isByBtn):
		return
		
	dataService.MakeRequest_Historicos(siteId,dateFromStruct.GetDate(),dateToStruct.GetDate())
	
	await SIGNALS.OnRefresh_Hist
	
	totalInfo = dataService.dataHistoricos.size()
	Graficar(dataService.dataHistoricos)
	_ShowChartInfo()
	
func _GetDatesFromDropdown():
	var value_inicio_ano :int = int(inicio_Ano.get_item_text(inicio_Ano.selected) )
	var value_inicio_mes :int = int(inicio_Mes.selected)
	var value_inicio_dia :int = int(inicio_Dia.get_item_text(inicio_Dia.selected) )
	var value_inicio_hora :int= int(inicio_Hora.get_item_text(inicio_Hora.selected).substr(0,2))
	
	APPSTATE.graficadoraRate = inicio_Intervalo.selected
	
	dateFromStruct.Update(value_inicio_ano,value_inicio_mes,value_inicio_dia,value_inicio_hora)
	dateToStruct = dateFromStruct.GetDayBefore()
	

#region [ BUTTONS SIGNALS ]
func OnBtnSitioPressed(_id : int, _name : String):
	siteId = _id
	SiteName.text = _name
	
	for btnSitio in btnsSitios:
		btnSitio.CheckBtnSelected(_id)

func UpdateDatesHorValues():
	if !Info.visible || crrntHistoricos.is_empty():
		return

	#actualiza la separacion entre las lineas verticales y las horas, para mostra mas datos en pantalla
	if currentCharInfo < totalInfo - 1:
		
		horTimeInfo.add_theme_constant_override("separation", int((Chart.size.x/currentCharInfo) - 7))
		horChartLines.add_theme_constant_override("separation", int((Chart.size.x/currentCharInfo)-7))
		#tarda un frame en acomodar la posicion de todas las barras verticales, que son las que guian los puntos de la grafica
		await get_tree().create_timer(0.001).timeout
		#actualizo la posicion de los valores de la grafica
		_Graficar_Puntos()
		_Graficar_Valores(crrntHistoricos)
		
		#actualiza el tamaño del contenedor de las lineas verticales, para que el scrollbar solo recorra el largo de las lineas verticales visibles
		horChartLines.size.x = linesPool[totalInfo - 1].position.x + SEPARATION
		_on_h_scroll_bar_scrolling()
		
		var setFirstRect = false
		var rect1 : Rect2
		var index = datePool.size() - 1
		for time in datePool:
			if !datePool[index].visible:
				index -= 1
				continue
			
			if !setFirstRect:
				rect1.position.x = (index * horTimeInfo.get_theme_constant("separation", "HBoxContainer"))
				rect1.size = datePool[index].size  + Vector2(5, 0)
				setFirstRect = true
				index -= 1
				continue
				
			var rect2 : Rect2
			rect2.position.x = (index * horTimeInfo.get_theme_constant("separation", "HBoxContainer"))
			rect2.size = datePool[index].size + Vector2(5, 0)
			
			if rect1.intersects(rect2):
				setFirstRect = false
				hrsPool[index].visible = false
				datePool[index].visible = false
			index -= 1
#endregion

#region [ GRAFICAR ]
func Graficar(_arrayHistoricos : Array[GDs_Data_EP_Historicos]):
	await get_tree().create_timer(.7).timeout
	
	lblDatesRange.text = str("Rango:   ",UTILITIES.FormatDateGraficadoraRango(_arrayHistoricos[0].tiempo), "   -    ",UTILITIES.FormatDateGraficadoraRango(_arrayHistoricos[_arrayHistoricos.size() - 1].tiempo))
	
	_Graficar_Lineas()
	
	#si no recive valores, muestre la pantalla sin historia
	if _arrayHistoricos.size() > 0:
		var infoModulate : Color = Info.modulate
		infoModulate.a = 0
		Info.modulate = infoModulate
		Info.visible = true
		
		crrntHistoricos.clear()
		crrntHistoricos = _arrayHistoricos
		
		
		#actualizo la posicion de los valores de la grafica
		_Graficar_Puntos()
		_Graficar_Valores(_arrayHistoricos)
		
		#actualiza el tamaño del contenedor de las lineas verticales, para que el scrollbar solo recorra el largo de las lineas verticales visibles
		horChartLines.size.x = linesPool[totalInfo - 1].position.x + SEPARATION
		_on_h_scroll_bar_scrolling()
		UpdateDatesHorValues()
		ScrollInfo.value = 0
		
		await graf_loading.FinishedAnimLoading
		
		WhitoutHistory.visible = false
		LoadingScreen.visible = false
		horChartLines.visible = true
		infoModulate.a = 1
		Info.modulate = infoModulate
		

	else:
		WhitoutHistory.visible = true
		LoadingScreen.visible = false
		
func Graficar_AreInputsValid(_isByBtn : bool) -> bool:
	var dropdownsValid : bool = inicio_Ano.selected != 0 and inicio_Mes.selected != 0 and inicio_Dia.selected != 0 and inicio_Hora.selected != 0 and inicio_Intervalo.selected != 0
	var sitioIdIsValid : bool = siteId >= 0
	
	if not dropdownsValid:
		if _isByBtn:
			fechaAnimPlayer.stop()
			fechaAnimPlayer.play("DropdownMissing")
		return false
		
	if not sitioIdIsValid:
		for btnSitio in btnsSitios:
			btnSitio.PlayMissingSitio()
		return false
	
	ChartBackground.visible = true
	lblDatesRange.visible = true
	Info.visible = false
	WhitoutHistory.visible = false
	horChartLines.visible = false
	
	LoadingScreen.visible = true
	graf_loading.CargandoDatos()

	ScrollInfo.value = ScrollInfo.max_value
	return true

func _Graficar_Valores(_data : Array[GDs_Data_EP_Historicos]):
	#seteo los valores de la grafica
	for i in totalInfo:
		#seteo texto de la hora
		if not _data[i].tiempo.is_empty():
			var date = _data[i].tiempo.split("T")
			var timeHrMin = _data[i].tiempo.substr(11,5)
			hrsPool[i].text = timeHrMin
			hrsPool[i].position.y = 0
			datePool[i].text = date[0].erase(0, 2)
			datePool[i].position.y = 17
		else:
			hrsPool[i].text = "---"
			datePool[i].text = "---"
			
		#seteo la posicion del value en y
		valuesPool[i].position.y = lerpf(VertLenght, 0.0, _data[i].valor/20.0) - (valuesPool[i].size.y/2)
		
		#obtiene todos los nodos hijos de los circulos de los valores para poder pintarlos
		var ValuesColor : Array[NinePatchRect] = []
		var ValueLabel : Label
		for value in valuesPool[i].get_children():
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
					
		#acomodo los puntos de la grafica, del poligono2d y de la linea2d en y
		degradedChart.polygon[i].y = lerpf(VertLenght, 0.0, _data[i].valor/20.0)
		lineChart.points[i].y = lerpf(VertLenght, 0.0, _data[i].valor/20.0)

func _Graficar_Puntos():
	#segun la posicion de las lineas verticales acomoda los puntos y los circulos de los valores en esa posicion
	var points = PackedVector2Array()
	var firstLinePosition : float
	var lastLinePosition : float
	var IsFirstLinePosition : bool = true
	
	#recorre todas las lineas verticales de la grafica para acomdar los puntos en la grafica
	var index := 0
	for Line in horChartLines.get_children():
		if Line.visible:
			if IsFirstLinePosition:
				firstLinePosition = Line.position.x
				IsFirstLinePosition = false
			points.append(Vector2(Line.position.x, 50))
			lastLinePosition = Line.position.x
			
			valuesPool[index].position.x = Line.position.x
			index += 1
	
	lineChart.points = points
	#añade dos puntos en la parte de bajo de la grafica para el poligono2d, para que se vea correctamente el degradado del poligono
	points.append(Vector2(lastLinePosition, VertLenght))
	points.append(Vector2(firstLinePosition, VertLenght))
	degradedChart.polygon = points

func _Graficar_Lineas():
	#tras actualizar el promedio de las muestras, cambia la cantidad de lineas, valores y horas que mostrara
	var index := 0
	linesPool.clear()
	for Line in horChartLines.get_children():
		if index >= totalInfo:
			Line.visible = false
		else:
			Line.visible = true
			linesPool.append(Line)
		index += 1
		
	index = 0
	valuesPool.clear()
	for value in ChartBoxContainer.get_children():
		if value.get_class() == "NinePatchRect":
			if index >= totalInfo:
				value.visible = false
			else:
				value.visible = true
				valuesPool.append(value)
			index += 1
	
	index = 0
	hrsPool.clear()
	datePool.clear()
	for label in horTimeInfo.get_children(true):
		if index >= totalInfo:
			label.visible = false
		else:
			label.visible = true
			label.get_child(0).add_theme_font_size_override("font_size", 17)
			hrsPool.append(label.get_child(0))
			label.get_child(1).add_theme_font_size_override("font_size", 12)
			datePool.append(label.get_child(1))
		index += 1
#endregion

#region [ SCROLL ]
func _input(event):
	if event is InputEventMouseMotion and isDragingChart:
		var delta = event.relative.x
		if delta > 0:
			ScrollInfo.value -= currentCharInfo / 12.0
		elif delta < 0:
			ScrollInfo.value += currentCharInfo / 12.0

func _on_chart_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		isDragingChart = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
		isDragingChart = false

func _on_h_scroll_bar_scrolling():
	#mueve en x todos lo valores de la grafica segun el valor del scrollbar y el tamaño del contenedor de las lineas verticales
	var HorPosition : float = (ScrollInfo.value*-(horChartLines.size.x-Chart.size.x))/ScrollInfo.max_value
	horChartLines.position.x = HorPosition
	degradedChart.position.x = HorPosition
	lineChart.position.x = HorPosition
	ChartBoxContainer.position.x = HorPosition
	horTimeInfo.position.x = HorPosition + abs(hrsPool[0].position.x)

func _on_scroll_info_value_changed(_arg):
	_on_h_scroll_bar_scrolling()
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
		
