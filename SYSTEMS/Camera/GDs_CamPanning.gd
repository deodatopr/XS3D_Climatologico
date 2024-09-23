extends Node

class_name GDs_CamPanning

@export var pivotPanning: Node3D

var camlimits : GDs_CamLimits
var speed : float
var speedAereo : float
var speedDron : float

var touch_points : Dictionary = {}
var initial_pos : Vector2
var isDragging: bool
var draggingDirection: float
var desactivarLimites : bool
var enablePanning : bool

func Initialize(_camLimits : GDs_CamLimits, _speedAereo : float, _speedDron : float, _desactivarLimites : bool):
	camlimits = _camLimits
	speedAereo = _speedAereo
	speedDron = _speedDron
	desactivarLimites = _desactivarLimites
	
	speed = speedAereo
	
func OnChangeCameraMode(mode : int):
	if mode == ENUMS.MODO.AEREO:
		speed = speedAereo
	else:
		speed = speedDron

func EnablePanning(_enable : bool):
	enablePanning = _enable

func _unhandled_input(event):
	if not enablePanning:
		return
	
	if event is InputEventScreenTouch:
		handleTouchInput(event)
	elif event is InputEventScreenDrag:
		handleTouchDrag(event)

func handleTouchInput(event : InputEventScreenTouch):
	if event.pressed:
		initial_pos = event.position
		touch_points[event.index] = event.position
	else:
		touch_points.erase(event.index)
		draggingDirection = 0
		isDragging = false

func handleTouchDrag(event : InputEventScreenDrag):
	
	touch_points[event.index] = event.position
	draggingDirection = signf(initial_pos.y - event.position.y) * -1
	isDragging = touch_points.size() == 1
	
	var currentPos = pivotPanning.position
	currentPos -= (Vector3(event.relative.x, 0, event.relative.y) * speed)

	if not desactivarLimites:
		var movX = camlimits.GetValidPosHorizontal(currentPos.x)
		var movZ = camlimits.GetValidPosVertical(currentPos.z)
		
		currentPos.x = movX
		currentPos.z = movZ
	else:
		print_rich("[color=orange]--------- NOTA: LIMITES DE CAMARA DESACTIVADO ---------- [/color]")
	
	pivotPanning.position = currentPos
