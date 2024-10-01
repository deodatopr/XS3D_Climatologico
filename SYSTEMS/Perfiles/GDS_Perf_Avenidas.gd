class_name GDs_Perf_Avenida extends Control

@export var nombre:Label

@export_group("Expand")
@export var RootContainer: Control
@export var ItemContainer: VBoxContainer
@export var ButtonAvenida: Button
@export var ImgArrowExpand: Control

@export_group("Instantiate Items")
@export var estacionItem: PackedScene
@export var vBoxContainer: Control

var estaciones : Array[Perf_Item]

var isExpanded: bool = true
var tween: Tween
var tweenArrow: Tween

signal OnButtonExpandPressed
signal OnExpand(container:Control)

func InstantiateItems(_estaciones: int):
	for estacion in _estaciones:
		var newsitio = estacionItem.instantiate()
		vBoxContainer.add_child(newsitio)
		estaciones.append(newsitio)
		
func RefreshAvenida(_estaciones: Array[GDs_Data_Estacion]):
	var idx = 0
	for estacion in estaciones:
		estacion.RefreshInfo(_estaciones[idx])
		idx += 1

#---------------UI------------------
func _on_button_pressed():
	isExpanded = !isExpanded
	if isExpanded:
		_Expand()
	else:
		_Collapse()
	OnButtonExpandPressed.emit()

func _Expand():
	ItemContainer.show()
	_AnimExpandArrow(180)
	OnExpand.emit(RootContainer)

func _Collapse():
	_AnimExpandArrow(0)
	ItemContainer.hide()
	var _idx = 0
	for estacion in estaciones:
		_idx += 1

func _AnimExpandArrow(_rotation: float):
	tweenArrow = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tweenArrow.tween_property(ImgArrowExpand,"rotation_degrees",_rotation,0.2).from_current()
