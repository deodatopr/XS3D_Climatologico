extends Node

@export var pivotCam : Node3D
@export var MarkRef : Node3D
@export var CompassLenght : float

var compassInitialXPosition := 0.0
var pinSiteInitialXPosition := 0.0

@onready var pin_sitio: Panel = $CompassMask/PinSite
@onready var compass: TextureRect = $CompassMask/Compass

func _ready() -> void:
	compassInitialXPosition = compass.position.x
	pinSiteInitialXPosition = pin_sitio.position.x
		
@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	var rotationDegrees = (abs(pivotCam.rotation.y) * 180)/3.1333
	var compassPosition = rotationDegrees * (compass.size.x/6)/180
	
	var rotationDir := 1
	if pivotCam.rotation.y < 0:
		rotationDir = -1
		
	compass.position.x = (compassPosition * rotationDir) + compassInitialXPosition
	
	var pivotCamNormal = pivotCam.transform.basis.z
	#pivotCamNormal = pivotCamNormal.rotated(Vector3.UP, deg_to_rad(40))
	var MarkNormal = (MarkRef.position - pivotCam.position).normalized()
	var dot = pivotCamNormal.dot(MarkNormal)
	var OffsetMark = abs(dot - 1) * (CompassLenght/2)
	

	var RightVectorNormal = pivotCam.transform.basis.x
	var RightDot = RightVectorNormal.dot(MarkNormal)
	
	if RightDot > 0:
		OffsetMark *= -1
	
	pin_sitio.position.x = OffsetMark + pinSiteInitialXPosition
