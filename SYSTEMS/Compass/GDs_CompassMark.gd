class_name GDs_CompassMark extends Node

var Pivot : Node3D
var MarkRef : Node3D
var CompassLenght : float

func _ready() -> void:
	self.position = Vector2(500, 0)
	
func _initialize(_pivot : Node3D, _markRef : Node3D, _compassLengt : float):
		Pivot = _pivot
		MarkRef = _markRef
		CompassLenght = _compassLengt


func _process(delta: float) -> void:
	var PivotNormal = Pivot.transform.basis.z.normalized()
	var MarkNormal = MarkRef.position.normalized()
	var Dot = (PivotNormal.x * MarkNormal.x) + (PivotNormal.z * MarkNormal.z)
	var OffsetMark = abs(Dot - 1) * (CompassLenght/2)
	
	var RightVectorNormal = Pivot.transform.basis.x.normalized()
	var RightDot = ((RightVectorNormal.x * MarkNormal.x) + (RightVectorNormal.z * MarkNormal.z))
	
	if RightDot < 0:
		OffsetMark *= -1
	
	
	self.pivot_offset.x = OffsetMark
