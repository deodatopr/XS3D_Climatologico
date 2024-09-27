extends Node

class_name GDs_Graficadora_Valores

@export var chartTools : Control 
@export var chartLine : Line2D
@export var chartGradient : Polygon2D
@export var pivotPosMin : Control
@export var pivotPosMax : Control
@export var pointsGraf : Array[NinePatchRect] = []
@export var labelsPoints : Array[Label]

@export var colorNormal : Color
@export var colorPrev : Color
@export var colorCrit : Color
@export var colorError : Color


func Graficar(_values : Array[float],_values01 : Array[float], _semaforos : Array[int]):
	if DEBUG.perf_RndNiveles:
		print_rich("[color=orange]---------- NOTA: DEBUG VALORES DE LA GRAFICA ACTIVADO --------- [/color]")
	#DEBUG GRAFICA
		var testValues01 : Array[float] = []
		var rng = RandomNumberGenerator.new()
				
		var testValues : Array[float] = []
		for j in range(12):
			testValues.append( roundf( rng.randf_range(0,25) ) )
			
		for i in range(12):
			testValues01.append(clampf(inverse_lerp(0,20,testValues[i]),0,1))
		
		var testSemaforos : Array[int] = []
		for k in range(12):
			var sem : int = -1
			if testValues[k] < 10:
				sem = ENUMS.SEMAFORO.NORMAL
			elif testValues[k] >= 10  and testValues[k] < 20:
				sem = ENUMS.SEMAFORO.PREV
			else:
				sem = ENUMS.SEMAFORO.CRIT
			
			testSemaforos.append(sem)
			
		_values01 = testValues01
		_values = testValues
		_semaforos = testSemaforos
	
	var idx : int = 0
	for lblPoint in labelsPoints:
		#Poner valores de cada punto de la grafica
		lblPoint.text = "null" if is_nan(_values[idx]) else str(round(_values[idx]))
		idx += 1
	
	idx = 0
	for value01 in _values01:
	#Poner los puntos en su lugar
		var posX = pointsGraf[idx].position.x
		var posY : float =  lerpf(pivotPosMin.position.y,pivotPosMax.position.y, value01)
		var posTarget = Vector2(posX,posY)
		pointsGraf[idx].position = posTarget
		
	#Color de los puntos
		if _semaforos[idx] == ENUMS.SEMAFORO.NORMAL:
			pointsGraf[idx].self_modulate = colorNormal
		elif _semaforos[idx] == ENUMS.SEMAFORO.PREV:
			pointsGraf[idx].self_modulate = colorPrev
		elif _semaforos[idx] == ENUMS.SEMAFORO.CRIT:
			pointsGraf[idx].self_modulate = colorCrit
		else:
			pointsGraf[idx].self_modulate = colorError
			
	#Puntos de la Linea2D y Gradiente
		var posPointChart = Vector2(chartLine.points[idx].x, lerpf(0,chartTools.size.y * -1, value01))
		chartLine.points[idx] = posPointChart
		chartGradient.polygon[idx + 1] = posPointChart
		idx += 1
