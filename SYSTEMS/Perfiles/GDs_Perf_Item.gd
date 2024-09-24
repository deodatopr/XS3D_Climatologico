extends Control
class_name Perf_Item

@export_group("Expand / Collapse")
@export var buttonExpandir:Button
@export var collapsedSize: float
@export var expandedSize: float

var isOpen : bool

func _ready():
	buttonExpandir.toggled.connect(OnPressedShowExtraInfo)

func RefreshInfo():
	pass

func OnPressedShowExtraInfo(_toggle:bool):
	if _toggle:
		OpenItemExtraInfo()
	elif not _toggle:
		CloseItemExtraInfo()

func OpenItemExtraInfo():
	isOpen = true
	var tween: Tween
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 'custom_minimum_size', Vector2(720,expandedSize),0.2)
	tween.parallel().tween_property(self, 'size', Vector2(720,expandedSize),0.2)
		
func CloseItemExtraInfo():
	isOpen = false
	var tween: Tween
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 'custom_minimum_size', Vector2(720,collapsedSize),0.2)
	tween.parallel().tween_property(self, 'size', Vector2(720,collapsedSize),0.2)
	
func On_Graficodora_Btn_Pressed():
	pass

func OnSitioPressed():
	pass
