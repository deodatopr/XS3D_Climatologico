extends Node

class_name GDs_CamLimits

var limitAerVertical : Vector2
var limitAerHorizontal : Vector2
var limitDronVertical : Vector2
var limitDronHorizontal : Vector2

var lastValidAerX : float
var lastValidAerZ : float
var lastValidDronX : float
var lastValidDronZ : float

var currentMode : int
var desactivarLimites : bool

#region [ PUBLIC ]

func Initialize(_limitAerVertical : Vector2,_limitAerHorizontal : Vector2,_limitDronVertical : Vector2,_limitDronHorizontal : Vector2):
	limitAerVertical = _limitAerVertical
	limitAerHorizontal = _limitAerHorizontal	
	limitDronVertical = _limitDronVertical
	limitDronHorizontal = _limitDronHorizontal
	
func OnChangeCameraMode(mode : int):
	currentMode = mode
	
func GetValidPosHorizontal(currentPosX : float) -> float:
	if currentMode == ENUMS.MODO.AEREO:
		return GetValidPosAerHorizontal(currentPosX)
	else:
		return GetValidPosDronHorizontal(currentPosX)
		
func GetValidPosVertical(currentPosZ : float) -> float:
	if currentMode == ENUMS.MODO.AEREO:
		return GetValidPosAerVertical(currentPosZ)
	else:
		return GetValidPosDronVertical(currentPosZ)
#endregion
	
#region [ PRIVATE ]
# Limite Aerea
func GetValidPosAerHorizontal(currentPosX : float) -> float:
	if currentPosX >= limitAerHorizontal.y and currentPosX <= limitAerHorizontal.x:
		lastValidAerX = currentPosX
		return currentPosX
	
	return lastValidAerX
	
func GetValidPosAerVertical(currentPosZ : float) -> float:
	if currentPosZ <= limitAerVertical.x and currentPosZ >= limitAerVertical.y:
		lastValidAerZ = currentPosZ
		return currentPosZ
	
	return lastValidAerZ
	
	
# Limite  Dron
func GetValidPosDronHorizontal(currentPosX : float) -> float:
	if currentPosX >= limitDronHorizontal.y and currentPosX <= limitDronHorizontal.x:
		lastValidDronX = currentPosX
		return currentPosX
	
	return lastValidDronX
	
func GetValidPosDronVertical(currentPosZ : float) -> float:
	if currentPosZ <= limitDronVertical.x and currentPosZ >= limitDronVertical.y:
		lastValidDronZ = currentPosZ
		return currentPosZ
	
	return lastValidDronZ
#endregion

