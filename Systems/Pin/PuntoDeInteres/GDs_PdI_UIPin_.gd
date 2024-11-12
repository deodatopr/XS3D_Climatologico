class_name GDs_PdI_UIPin
extends Control

@export var lblNombre:Label
@export var anim:AnimationPlayer
@export var littlePoint:Control

var cameraFly:Camera3D
var cameraSky:Camera3D
var pinWorldPos:GDs_PdI_WorldPin

var currentCam:Camera3D
var isInitialized: bool = false

var isClosed: bool = true
var isOpened: bool = false

var tween:Tween

func _ready():
	anim.play("Close")
	PlayLittlePoint()


func Initialize():
	SIGNALS.OnCameraChangedMode.connect(OnChangeCamera)
	lblNombre.text = " " + pinWorldPos.nombre + " "
	lblNombre.visible_ratio = 0
	currentCam = cameraFly
	isInitialized = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not isInitialized: return
	visible = currentCam.is_position_in_frustum(pinWorldPos.global_position)
	position = currentCam.unproject_position(pinWorldPos.global_position)
	
	
	if position.distance_to(get_viewport_rect().size/2) <= 200 and not isOpened:
		anim.play("Open")
		isOpened = true
		isClosed = false
		
	elif position.distance_to(get_viewport_rect().size/2) > 200 and not isClosed:
		anim.play("Close")
		isClosed = true
		isOpened = false
		
	

func OnChangeCamera(cam:int):
	if cam == ENUMS.Cam_Mode.sky:
		currentCam = cameraSky
	else:
		currentCam = cameraFly

func PlayBlinking():
	anim.play("Blink")

func PlayLittlePoint():
	tween = create_tween().set_loops(0)
	tween.tween_property(littlePoint,"self_modulate",Color.TRANSPARENT,0.2)
	tween.tween_property(littlePoint,"self_modulate",Color.WHITE,0.2)
