extends Node

@export var dataService : GDs_DataService_Manager

@export var criticLevelColor : Color
@export var criticLevelRange : int
@export var dangerLevelColor : Color
@export var dangerLevelRange : int
@export var safeLevelColor : Color
@export var safeLevelRange : int

@export_group("Internal References")
@export var degradedChart : Node2D
@export var lineChart : Node2D
@export var ChartBoxContainer : Control
@export var Chart : Control
@export var horChartLines : Control
@export var horTimeInfo : Control
@export var ScrollInfo : Control
@export var FromDateInfo : DatePicker
@export var ToDateInfo : DatePicker
@export var SitesBttnContainer : Control
@export var SiteName : Label
@export var SiteSeparation : Label
@export var LastUpdate : Label
@export var LoadingScreen : Control
@export var WhitoutHistory : Control
@export var InitialChart : Control
@export var Info : Control
@export var ChartBackground : Control

const SEPARATION = 80

var DebugSamples : int
var VertLenght : float
var currentCharInfo : int = 12
var TotalInfo : int = 52
var linesActivePool : Array[NinePatchRect]
var ValuesActivePool : Array[NinePatchRect]
var HrsActivePool : Array[Label]
var DateActivePool : Array[Label]
var finalSamples : Array[GDs_Data_EP_Historicos]
var SiteID : int
var isDragingChart : bool

func _ready():
	#obtengo la altura de la grafica
	VertLenght = Chart.size.y
	
	#conecto las señal de press a los botones de los sition, pasando el texto del boton que es el nombre del sitio
	var index = 1
	for Bttn in SitesBttnContainer.get_children():
		Bttn.pressed.connect(self._site_Pressed.bind(Bttn.text, index))
		index += 1
	
	#conecto la señal de los botones de los calendarios para que cierren si se selecciona uno u otro
	FromDateInfo.date_picker_button.pressed.connect(self._toggleCalendarBttn.bind(FromDateInfo.date_picker_button))
	ToDateInfo.date_picker_button.pressed.connect(self._toggleCalendarBttn.bind(ToDateInfo.date_picker_button))
	
	FromDateInfo.ConfirmDate.connect(self._date_change)
	ToDateInfo.ConfirmDate.connect(self._date_change)

func _date_change():
	_site_Pressed(SiteName.text, SiteID)

func _Initialize_chart_to_zero():
	var EmptyChart : Array[GDs_Data_EP_Historicos]
	for i in 51:
		var NewData : GDs_Data_EP_Historicos = GDs_Data_EP_Historicos.new()
		NewData.valor = 0
		NewData.tiempo = Time.get_datetime_string_from_system()
		EmptyChart.append(NewData)
		
	LastUpdate.visible = false
	SiteSeparation.visible = false

#funcion para que los calendarios se cierren si se abre el otro y vicebersa
func _toggleCalendarBttn(_selectedCalendar : Button):
	if _selectedCalendar == FromDateInfo.date_picker_button:
		ToDateInfo.date_picker_panel.visible = false
		ToDateInfo.hour_picker.visible = false
	else:
		FromDateInfo.date_picker_panel.visible = false
		FromDateInfo.hour_picker.visible = false


func Graficar(_data : Array[GDs_Data_EP_Historicos]):
	#seteo los valores de la grafica
	for i in TotalInfo:
		#seteo texto de la hora
		if !_data[i].tiempo.is_empty():
			var date = _data[i].tiempo.split("T")
			var timeHrMin = _data[i].tiempo.get_slice("T", 1)
			timeHrMin = timeHrMin.erase(5, 3)
			HrsActivePool[i].text = timeHrMin
			HrsActivePool[i].position.y = 0
			DateActivePool[i].text = date[0].erase(0, 2)
			DateActivePool[i].position.y = 17
		else:
			HrsActivePool[i].text = "---"
			DateActivePool[i].text = "---"
			
		#seteo la posicion del value en y
		ValuesActivePool[i].position.y = lerpf(VertLenght, 0.0, _data[i].valor/20.0) - (ValuesActivePool[i].size.y/2)
		
		#obtiene todos los nodos hijos de los circulos de los valores para poder pintarlos
		var ValuesColor : Array[NinePatchRect] = []
		var ValueLabel : Label
		for value in ValuesActivePool[i].get_children():
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

func _site_Pressed(_name : String, _site : int):
	if _name.is_empty() or _site == 0:
		return

	#convierto en string las horas de los calendarios
	var fromhour = FromDateInfo.Hour_Bttn_Selected.text.split(":")
	var tohour = ToDateInfo.Hour_Bttn_Selected.text.split(":")
	
	#reviso cual de los botones del las fechas es mas reciente
	if FromDateInfo.final_date_data["year"] > ToDateInfo.final_date_data["year"]:
		var mostCurrentDate = FromDateInfo
		FromDateInfo = ToDateInfo
		ToDateInfo = mostCurrentDate
		var mostCurrentHour = fromhour
		fromhour = tohour
		tohour = mostCurrentHour
	elif FromDateInfo.final_date_data["month"] > ToDateInfo.final_date_data["month"] and FromDateInfo.final_date_data["year"] == ToDateInfo.final_date_data["year"]:
		var mostCurrentDate = FromDateInfo
		FromDateInfo = ToDateInfo
		ToDateInfo = mostCurrentDate
		var mostCurrentHour = fromhour
		fromhour = tohour
		tohour = mostCurrentHour
	elif FromDateInfo.final_date_data["day"] > ToDateInfo.final_date_data["day"] and FromDateInfo.final_date_data["month"] == ToDateInfo.final_date_data["month"] and FromDateInfo.final_date_data["year"] == ToDateInfo.final_date_data["year"]:
		var mostCurrentDate = FromDateInfo
		FromDateInfo = ToDateInfo
		ToDateInfo = mostCurrentDate
		var mostCurrentHour = fromhour
		fromhour = tohour
		tohour = mostCurrentHour
	elif int(fromhour[0]) > int(tohour[0]) and FromDateInfo.final_date_data["day"] == ToDateInfo.final_date_data["day"] and FromDateInfo.final_date_data["month"] == ToDateInfo.final_date_data["month"] and FromDateInfo.final_date_data["year"] == ToDateInfo.final_date_data["year"]:
		var mostCurrentDate = FromDateInfo
		FromDateInfo = ToDateInfo
		ToDateInfo = mostCurrentDate
		var mostCurrentHour = fromhour
		fromhour = tohour
		tohour = mostCurrentHour
		
	#convierto a string las fechas seleccionadas en los calendarios
	var fromdate : String = str(FromDateInfo.final_date_data["year"], "-", FromDateInfo.final_date_data["month"], "-", FromDateInfo.final_date_data["day"])
	var todate : String = str(ToDateInfo.final_date_data["year"], "-", ToDateInfo.final_date_data["month"], "-", ToDateInfo.final_date_data["day"])
	LastUpdate.text = fromhour[0] + ":" + fromhour[1] + " " + fromdate + " - " + tohour[0] + ":" + tohour[1] + " " + todate
	
	#revisa si las fechas y horas son iguales para salir de la funcion
	if fromdate == todate and fromhour[0] == tohour[0]:
		return
	
	ChartBackground.visible = true
	LastUpdate.visible = true
	SiteSeparation.visible = true
	InitialChart.visible = false
	Info.visible = false
	WhitoutHistory.visible = false
	horChartLines.visible = false
	LoadingScreen.visible = true
	
	#cambia el nombre del sitio
	SiteName.text = _name
	SiteID = _site

	ScrollInfo.value = ScrollInfo.max_value
	
func _updateRequestData(_arrayHistoricos : Array[GDs_Data_EP_Historicos]):
	_updateChartSamples()
	
	#si no recive valores, muestre la pantalla sin historia
	if finalSamples.size() > 0:
		WhitoutHistory.visible = false
		Info.visible = true
		horChartLines.visible = true
		LoadingScreen.visible = false
		#tarda un frame en acomodar la posicion de todas las barras verticales, que son las que guian los puntos de la grafica
		await get_tree().create_timer(0.01).timeout
		#actualizo la posicion de los valores de la grafica
		_updateChart()
		Graficar(finalSamples)
		
		#actualiza el tamaño del contenedor de las lineas verticales, para que el scrollbar solo recorra el largo de las lineas verticales visibles
		horChartLines.size.x = linesActivePool[TotalInfo - 1].position.x + SEPARATION
		_on_h_scroll_bar_scrolling()
	
	else:
		WhitoutHistory.visible = true
		LoadingScreen.visible = false
	
func _on_min_info_pressed():
	if !Info.visible:
		return
	#actualiza la separacion entre las lineas verticales y las horas, para mostra menos datos en pantalla
	if currentCharInfo != 1:
		currentCharInfo -= 1
	
		horTimeInfo.add_theme_constant_override("separation", int((Chart.size.x/currentCharInfo)-7))
		horChartLines.add_theme_constant_override("separation", int((Chart.size.x/currentCharInfo)-7))
		#tarda un frame en acomodar la posicion de todas las barras verticales, que son las que guian los puntos de la grafica
		await get_tree().create_timer(0.001).timeout
		#actualizo la posicion de los valores de la grafica
		_updateChart()
		Graficar(finalSamples)
		
		#actualiza el tamaño del contenedor de las lineas verticales, para que el scrollbar solo recorra el largo de las lineas verticales visibles
		horChartLines.size.x = linesActivePool[TotalInfo - 1].position.x + SEPARATION
		_on_h_scroll_bar_scrolling()
		
		var setFirstRect = false
		var rect1 : Rect2
		var rect2 : Rect2
		var invisibleRects : Dictionary
		var index = DateActivePool.size() - 1
		for time in DateActivePool:
				
			if DateActivePool[index].visible and !setFirstRect:
				rect1.position.x = (index * horTimeInfo.get_theme_constant("separation", "HBoxContainer"))
				rect1.size = DateActivePool[index].size  + Vector2(5, 0)
				setFirstRect = true
				index -= 1
				continue
			else:
				var invisibleRect : Rect2
				invisibleRect.position.x = (index * horTimeInfo.get_theme_constant("separation", "HBoxContainer"))
				invisibleRect.size = DateActivePool[index].size  + Vector2(5, 0)
				invisibleRects[invisibleRect] = index
				index -= 1
			
			if DateActivePool[index].visible and setFirstRect:
				rect2.position.x = (index * horTimeInfo.get_theme_constant("separation", "HBoxContainer"))
				rect2.size = DateActivePool[index].size  + Vector2(5, 0)
				
				for rect in invisibleRects.keys():
					if !rect.intersects(rect1) and !rect.intersects(rect2):
						HrsActivePool[invisibleRects[rect]].visible = true
						DateActivePool[invisibleRects[rect]].visible = true
						break
						
				rect1 = rect2
				invisibleRects.clear()
				index -= 1
				continue

func _on_more_info_bttn_pressed():
	if !Info.visible:
		return
	#actualiza la separacion entre las lineas verticales y las horas, para mostra mas datos en pantalla
	if currentCharInfo < TotalInfo - 1:
		currentCharInfo += 1
		
		horTimeInfo.add_theme_constant_override("separation", int((Chart.size.x/currentCharInfo) - 7))
		horChartLines.add_theme_constant_override("separation", int((Chart.size.x/currentCharInfo)-7))
		#tarda un frame en acomodar la posicion de todas las barras verticales, que son las que guian los puntos de la grafica
		await get_tree().create_timer(0.001).timeout
		#actualizo la posicion de los valores de la grafica
		_updateChart()
		Graficar(finalSamples)
		
		#actualiza el tamaño del contenedor de las lineas verticales, para que el scrollbar solo recorra el largo de las lineas verticales visibles
		horChartLines.size.x = linesActivePool[TotalInfo - 1].position.x + SEPARATION
		_on_h_scroll_bar_scrolling()
		
		var setFirstRect = false
		var rect1 : Rect2
		var index = DateActivePool.size() - 1
		for time in DateActivePool:
			if !DateActivePool[index].visible:
				index -= 1
				continue
			
			if !setFirstRect:
				rect1.position.x = (index * horTimeInfo.get_theme_constant("separation", "HBoxContainer"))
				rect1.size = DateActivePool[index].size  + Vector2(5, 0)
				setFirstRect = true
				index -= 1
				continue
				
			var rect2 : Rect2
			rect2.position.x = (index * horTimeInfo.get_theme_constant("separation", "HBoxContainer"))
			rect2.size = DateActivePool[index].size + Vector2(5, 0)
			
			if rect1.intersects(rect2):
				setFirstRect = false
				HrsActivePool[index].visible = false
				DateActivePool[index].visible = false
			index -= 1

func _updateChart():
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
			
			ValuesActivePool[index].position.x = Line.position.x
			index += 1
	
	lineChart.points = points
	#añade dos puntos en la parte de bajo de la grafica para el poligono2d, para que se vea correctamente el degradado del poligono
	points.append(Vector2(lastLinePosition, VertLenght))
	points.append(Vector2(firstLinePosition, VertLenght))
	degradedChart.polygon = points

func _on_h_scroll_bar_scrolling():
	#mueve en x todos lo valores de la grafica segun el valor del scrollbar y el tamaño del contenedor de las lineas verticales
	var HorPosition : float = (ScrollInfo.value*-(horChartLines.size.x-Chart.size.x))/ScrollInfo.max_value
	horChartLines.position.x = HorPosition
	degradedChart.position.x = HorPosition
	lineChart.position.x = HorPosition
	ChartBoxContainer.position.x = HorPosition
	horTimeInfo.position.x = HorPosition + abs(HrsActivePool[0].position.x)

func _updateChartSamples():
	#tras actualizar el promedio de las muestras, cambia la cantidad de lineas, valores y horas que mostrara
	var index := 0
	linesActivePool.clear()
	for Line in horChartLines.get_children():
		if index >= TotalInfo:
			Line.visible = false
		else:
			Line.visible = true
			linesActivePool.append(Line)
		index += 1
		
	index = 0
	ValuesActivePool.clear()
	for value in ChartBoxContainer.get_children():
		if value.get_class() == "NinePatchRect":
			if index >= TotalInfo:
				value.visible = false
			else:
				value.visible = true
				ValuesActivePool.append(value)
			index += 1
	
	index = 0
	HrsActivePool.clear()
	DateActivePool.clear()
	for label in horTimeInfo.get_children(true):
		if index >= TotalInfo:
			label.visible = false
		else:
			label.visible = true
			label.get_child(0).add_theme_font_size_override("font_size", 17)
			HrsActivePool.append(label.get_child(0))
			label.get_child(1).add_theme_font_size_override("font_size", 12)
			DateActivePool.append(label.get_child(1))
		index += 1
			
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


func _on_scroll_info_value_changed(_arg):
	_on_h_scroll_bar_scrolling()
