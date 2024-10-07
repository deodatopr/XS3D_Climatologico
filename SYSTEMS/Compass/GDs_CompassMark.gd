class_name GDs_CompassMark extends Node

var Pivot : Node3D
var MarkRef : Node3D
var CompassLenght : float
@export var CenterMark : float

func _ready() -> void:
	self.position = Vector2(366, 11)
	
func _initialize(_pivot : Node3D, _markRef : Node3D, _compassLengt : float):
		Pivot = _pivot
		MarkRef = _markRef
		CompassLenght = _compassLengt


func _process(delta: float) -> void:
	var PivotNormal = (Pivot.transform.basis * Vector3.FORWARD).normalized()
	#PivotNormal = PivotNormal.rotated(Vector3.UP, deg_to_rad(40))
	var MarkNormal = (MarkRef.position - Pivot.position).normalized()
	var Dot = -MarkNormal.dot(PivotNormal)
	var OffsetMark = clamp((abs(Dot - 1) * (CompassLenght/2)), -(CompassLenght/2), (CompassLenght/2))
	
	print(Dot)
	
	var RightVectorNormal = (Pivot.transform.basis * Vector3.RIGHT).normalized()
	var RightDot = ((RightVectorNormal.x * MarkNormal.x) + (RightVectorNormal.z * MarkNormal.z))
	
	if RightDot < 0:
		OffsetMark *= -1
	
	self.pivot_offset.x = OffsetMark
