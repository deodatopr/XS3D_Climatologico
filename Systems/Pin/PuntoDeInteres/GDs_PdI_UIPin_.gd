class_name GDs_PdI_UIPin
extends Control

@export var lblNombre:Label
@export var anim:AnimationPlayer

var cameraFly:Camera3D
var cameraSky:Camera3D
var pinWorldPos:GDs_PdI_WorldPin

var currentCam:Camera3D
var isInitialized: bool = false

var isClosed: bool = true
var isOpened: bool = false

func _ready():
	anim.play("Close")


func Initialize():
	SIGNALS.OnCameraChangedMode.connect(OnChangeCamera)
	lblNombre.text = " " + pinWorldPos.nombre + " "
	lblNombre.visible_ratio = 1
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
