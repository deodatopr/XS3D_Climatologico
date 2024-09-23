extends Control
class_name GRAFICADORA

@export var ScriptGraficarPuntos: GDs_Graficadora_Valores

@export var ContLabelsSitio: Control
@export var LblNombreAvenida: Label
@export var LblIdLocal: Label
@export var LblNombreSitio: Label
@export var LblFechaAct: Label
@export var ContGrafica: Control
@export var ContLoading: Control
@export var ContSinHistoricos: Control
@export var ScrollGrafClip: ScrollContainer

@export_group("Labels cms")
@export var Lblcms : Array[Label]
@export_group("Labels hrs")
@export var Lblhrs : Array[Label]

@export_group("AnimLoading")
@export var Line1: TextureProgressBar
@export var Line2: TextureProgressBar
@export var Line3: TextureProgressBar
@export var Dot1: Control
@export var Dot2: Control
@export var Dot3: Control
@export var Dot4: Control

var loadingTween: Tween
var historicosReady:= false

func _ready():
	SIGNALS.OnButtonMapa3DPressed.connect(HideAll)

func HideContLoading():
	ContLoading.hide()
	
func ShowSitioInfo():
	LblNombreAvenida.show()
	ContLabelsSitio.show()

func ShowContainersLoading():
	LblNombreAvenida.hide()
	ContGrafica.hide()
	ContLoading.show()
	ContLabelsSitio.hide()
	ContSinHistoricos.hide()

func HideLabelSitio():
	ContLabelsSitio.hide()

func HideAll():
	ContLoading.hide()
	ContGrafica.hide()
	ContSinHistoricos.hide()
	ContLabelsSitio.hide()

func SetSitioData(historicos: GDs_Historico):
	if DEBUG.perf_RndNiveles:
		var TestHasData := true
		var TestValuesNvlGrafVertical : Array[float] = [20,15,10,5,0]
		var TestValuesNvlGrafHorizontal : Array[String] = ["05:45","06:00","06:15","06:30","06:45","07:00","07:15","07:30","07:45","08:00","08:15","08:30"]
		var TestFecha = "Ultima Act: 8:30 - 14/03/2024"
		
		historicos.hasData = TestHasData
		historicos.valuesNvlGrafVertical = TestValuesNvlGrafVertical
		historicos.valuesHrGrafHorizontal = TestValuesNvlGrafHorizontal
		historicos.fecha = TestFecha
	
	
	LblNombreAvenida.text = historicos.estructura
	LblIdLocal.text = str(historicos.idLocal)
	LblNombreSitio.text = historicos.nameSitio
	LblFechaAct.text = historicos.fecha
	
	# Graficadora iniciar hasta el final del scroll
	ScrollGrafClip.scroll_horizontal = 854
	
	if not historicos.hasData:
		ContSinHistoricos.show()
	else:
		ContGrafica.show()
		
		var _indx = 0
		for cm in Lblcms:
			cm.text = str(historicos.valuesNvlGrafVertical[_indx])
			_indx +=1
		
		_indx = 0
		
		if historicos.valuesHrGrafHorizontal.size() > 0:
			for hr in Lblhrs:
				hr.text = str(historicos.valuesHrGrafHorizontal[_indx])
				_indx +=1
		
		ScriptGraficarPuntos.Graficar(historicos.values, historicos.values01, historicos.semaforos)
	
	 
func CargandoDatos():	
#------LOGO ANIMATION--------
	Line1.value = 0
	Line2.value = 0
	Line3.value = 0
	Dot1.scale = Vector2(0,0)
	Dot2.scale = Vector2(0,0)
	Dot3.scale = Vector2(0,0)
	Dot4.scale = Vector2(0,0)
	
	
	loadingTween = create_tween().set_ease(Tween.EASE_IN_OUT)
	loadingTween.tween_property(Line1,"value",100,0.3)
	loadingTween.parallel().tween_property(Dot1,"scale",Vector2(1,1),0.3)
	loadingTween.tween_property(Line2,"value",100,0.3)
	loadingTween.parallel().tween_property(Dot2,"scale",Vector2(1,1),0.3)
	loadingTween.tween_property(Line3,"value",100,0.3)
	loadingTween.parallel().tween_property(Dot3,"scale",Vector2(1,1),0.3)
	loadingTween.tween_property(Dot4,"scale",Vector2(1,1),0.3)
	
	await loadingTween.finished
	
	if historicosReady:
		ContLoading.hide()
	else:
		CargandoDatos()
