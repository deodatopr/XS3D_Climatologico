extends Control
class_name GDs_Perf_Avenida

var estaciones : Array[Perf_Item]

@export var nombre:Label

@export_group("Expand")
@export var RootContainer: Control
@export var ItemContainer: VBoxContainer
@export var ButtonAvenida: Button
@export var ImgArrowExpand: Control

@export_group("Instantiate Items")
@export var sitioItem: PackedScene
@export var vBoxContainer: Control


#----UI
var isExpanded: bool = true
var tween: Tween
var tweenArrow: Tween

signal OnButtonExpandPressed
signal OnExpand(container:Control)

func _ready():
	pass

func RefreshAvenida(_estaciones: Array[GDs_Data_Estacion]):
# Refresh Sitios
	var idx = 0
	for estacion in estaciones:
		estacion.RefreshInfo(_estaciones[idx])
		idx += 1

func InstantiateItems(_sitios: int):
	for sitio in _sitios:
		var newsitio = sitioItem.instantiate()
		vBoxContainer.add_child(newsitio)
		estaciones.append(newsitio)
#---------------UI------------------
func _on_button_pressed():
	isExpanded = !isExpanded
	if isExpanded:
		Expand()
	else:
		Collapse()
	OnButtonExpandPressed.emit()

func Expand():
	ItemContainer.show()
	AnimExpandArrow(180)
	OnExpand.emit(RootContainer)

func Collapse():
	AnimExpandArrow(0)
	ItemContainer.hide()
	var _idx = 0
	for estacion in estaciones:
		_idx += 1

func AnimExpandArrow(_rotation: float):
	tweenArrow = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tweenArrow.tween_property(ImgArrowExpand,"rotation_degrees",_rotation,0.2).from_current()
