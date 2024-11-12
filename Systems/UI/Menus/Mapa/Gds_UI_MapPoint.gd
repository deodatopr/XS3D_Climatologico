class_name GDs_MapPoint
extends Control

@export var btn:Button
@export var lblNombre:Label
@export var lblId:Label
@export var animSquare:Control
@export var bg:Control
@export var bgLabel:Control
@export var bgLabelWidth:float

var tween:Tween
var currenttween:Tween
var squareScale:Vector2
var color:Color

var estacion:GDs_Data_Estacion

signal OnSitioPressed(_estacion:GDs_Data_Estacion)

# Called when the node enters the scene tree for the first time.
func Initialize(_estacion:GDs_Data_Estacion, playCurrentAnim:bool):
	estacion = _estacion
	
	btn.mouse_entered.connect(btn.grab_focus)
	btn.focus_entered.connect(OnFocus)
	btn.focus_exited.connect(OnFocusExited)
	btn.pressed.connect(OnPressed)
	
	bgLabel.size = Vector2(0,bgLabel.size.y)
	animSquare.rotation_degrees = 0
	animSquare.scale = Vector2(0.45,0.45)
	squareScale = animSquare.scale
	lblNombre.visible_ratio = 0
	bg.show()
	lblId.hide()
	
	#Inyectar datos
	lblId.text = str(_estacion.id)
	lblNombre.text = _estacion.nombre
	color = _estacion.color
	animSquare.modulate = color
	if playCurrentAnim:
		PlayCurrentSitioAnimation()

func OnPressed():
	OnSitioPressed.emit(estacion)

func OnFocus():
	tween = create_tween()
	bg.hide()
	lblId.show()
	tween.tween_property(animSquare,"scale",Vector2.ONE,0.2)
	tween.parallel().tween_property(animSquare,"rotation_degrees",225,0.2)
	tween.parallel().tween_property(lblNombre,"visible_ratio",1,0.2)
	tween.parallel().tween_property(bgLabel,"size",Vector2(bgLabelWidth,bgLabel.size.y),0.2)
	await  tween.finished
	bg.hide()
	lblId.show()
	

func OnFocusExited():
	tween = create_tween()
	tween.tween_property(lblNombre,"visible_ratio",0,0.2)
	tween.parallel().tween_property(animSquare,"scale",squareScale,0.2)
	tween.parallel().tween_property(animSquare,"rotation_degrees",0,0.2)
	tween.parallel().tween_property(bgLabel,"size",Vector2(0,bgLabel.size.y),0.2)
	await  tween.finished
	bg.show()
	lblId.hide()
	

func PlayCurrentSitioAnimation():
	currenttween = create_tween().set_loops(0)
	currenttween.tween_property(animSquare,"modulate",Color.WHITE,0.4)
	currenttween.tween_property(animSquare,"modulate",color,0.4)
