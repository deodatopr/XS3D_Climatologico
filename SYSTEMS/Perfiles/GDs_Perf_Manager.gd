extends Node
class_name GDs_Perf_Manager

@export var contenedorAvenidas: Control
@export var estadoMexico:GDs_Perf_Avenida
@export var estadoMichoacan:GDs_Perf_Avenida

@export_group("Btn Expand All") 
@export var Btn_ExpandAll: Button
@export var Cont_ExpandAll: Control
@export var Arrow1: Control
@export var Arrow2: Control

@export_group("Scroll") 
@export var scroll_avenidas: ScrollContainer


var isExpanded: bool = true
var TweenArrow: Tween
var avenidas: Array[GDs_Perf_Avenida]


@export_group("DEBUG") 
@export var debugEstaciones: GDs_EP_GetAllEstaciones_Debug


func _ready():
	Initialize()
	
func Initialize():
	estadoMexico.OnButtonExpandPressed.connect(CheckExpanded)
	estadoMexico.OnExpand.connect(EnsureIsVisible)
	estadoMichoacan.OnButtonExpandPressed.connect(CheckExpanded)
	estadoMichoacan.OnExpand.connect(EnsureIsVisible)
	OnRefreshSitios()

func OnRefreshSitios():
	debugEstaciones.GetDebugEstaciones()
	estadoMexico.nombre.text = "Mexico"
	estadoMexico.InstantiateItems(debugEstaciones.estaciones_Estruc_Mexico.estaciones.size())
	estadoMexico.RefreshAvenida(debugEstaciones.estaciones_Estruc_Mexico.estaciones)
	
	estadoMichoacan.nombre.text = "Michoacan"
	estadoMichoacan.InstantiateItems(debugEstaciones.estaciones_Estruc_Michoacan.estaciones.size())
	estadoMichoacan.RefreshAvenida(debugEstaciones.estaciones_Estruc_Michoacan.estaciones)


func _on_ExpandAll_pressed():
	Btn_ExpandAll.disabled = true
	isExpanded = !isExpanded
	if isExpanded:
		ExpandAll()
	else:
		CollapseAll()
		
func ExpandAll():
	AnimExpandAll(0)
	for child in contenedorAvenidas.get_children():
		child.Expand()
		child.isExpanded = true
	
	Btn_ExpandAll.disabled = false

func CollapseAll():
	AnimExpandAll(180,-1)
	
	var children = contenedorAvenidas.get_children() as Array[GDs_Perf_Avenida]
	for child in children:
		child.Collapse()
		child.isExpanded = false

	Btn_ExpandAll.disabled = false

func CheckExpanded():
	var areAllCollapsed = true
	for child in avenidas:
		if child.isExpanded and child.visible:
			areAllCollapsed = true
		
	if areAllCollapsed and isExpanded:
		AnimExpandAll(180,-1)
		isExpanded = false
	elif not areAllCollapsed and not isExpanded:
		AnimExpandAll(0)
		isExpanded = true



#----------SCROLL--------------
func EnsureIsVisible(control:Control):
	scroll_avenidas.ensure_control_visible(control)

#----------ANIMATIONS-------------
func AnimExpandAll(_angle: float, _direction:float = 1):
	TweenArrow = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	TweenArrow.tween_property(Cont_ExpandAll,"rotation_degrees",180,.5).from(0)
	TweenArrow.parallel().tween_property(Arrow1,"rotation_degrees",_angle,.2).from_current()
	TweenArrow.parallel().tween_property(Arrow2,"rotation_degrees",_angle + 180,.2).from_current()
