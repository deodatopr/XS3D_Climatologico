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

var dataService : GDs_DataService_Manager
var isExpanded: bool = true
var firstTime : bool
var TweenArrow: Tween
var avenidas: Array[GDs_Perf_Avenida]
	
func Initialize(_dataService : GDs_DataService_Manager):
	dataService = _dataService
	
	estadoMexico.OnButtonExpandPressed.connect(_CheckExpanded)
	estadoMexico.OnExpand.connect(_EnsureIsVisible)
	estadoMichoacan.OnButtonExpandPressed.connect(_CheckExpanded)
	estadoMichoacan.OnExpand.connect(_EnsureIsVisible)
	
	estadoMexico.nombre.text = "Mexico"
	estadoMexico.InstantiateItems(dataService.estaciones_Estruc_Mexico.estaciones.size())	
	
	estadoMichoacan.nombre.text = "Michoacan"
	estadoMichoacan.InstantiateItems(dataService.estaciones_Estruc_Michoacan.estaciones.size())
	
	OnDataRefresh()

func OnDataRefresh():
	estadoMexico.RefreshAvenida(dataService.estaciones_Estruc_Mexico.estaciones)
	estadoMichoacan.RefreshAvenida(dataService.estaciones_Estruc_Michoacan.estaciones)

func _OnExpandAll_pressed():
	Btn_ExpandAll.disabled = true
	isExpanded = !isExpanded
	if isExpanded:
		_ExpandAll()
	else:
		_CollapseAll()
		
func _ExpandAll():
	_AnimExpandAll(0)
	for child in contenedorAvenidas.get_children():
		child.Expand()
		child.isExpanded = true
	
	Btn_ExpandAll.disabled = false

func _CollapseAll():
	_AnimExpandAll(180,-1)
	
	var children = contenedorAvenidas.get_children() as Array[GDs_Perf_Avenida]
	for child in children:
		child.Collapse()
		child.isExpanded = false

	Btn_ExpandAll.disabled = false

func _CheckExpanded():
	var areAllCollapsed = true
	for child in avenidas:
		if child.isExpanded and child.visible:
			areAllCollapsed = true
		
	if areAllCollapsed and isExpanded:
		_AnimExpandAll(180,-1)
		isExpanded = false
	elif not areAllCollapsed and not isExpanded:
		_AnimExpandAll(0)
		isExpanded = true

#----------SCROLL--------------
func _EnsureIsVisible(control:Control):
	scroll_avenidas.ensure_control_visible(control)

#----------ANIMATIONS-------------
func _AnimExpandAll(_angle: float, _direction:float = 1):
	TweenArrow = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	TweenArrow.tween_property(Cont_ExpandAll,"rotation_degrees",180,.5).from(0)
	TweenArrow.parallel().tween_property(Arrow1,"rotation_degrees",_angle,.2).from_current()
	TweenArrow.parallel().tween_property(Arrow2,"rotation_degrees",_angle + 180,.2).from_current()
