extends Node

@export_group("AnimLoading")
@export var Line1: TextureProgressBar
@export var Line2: TextureProgressBar
@export var Line3: TextureProgressBar
@export var Dot1: Control
@export var Dot2: Control
@export var Dot3: Control
@export var Dot4: Control

var loadingTween: Tween

func _ready():
	CargandoDatos()

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
	
	await get_tree().create_timer(1).timeout
	
	CargandoDatos()
	
	#if historicosReady:
		#ContLoading.hide()
	#else:
		#CargandoDatos()
