extends Node

class_name GDs_MngOcclusion

@export var mngCam : GDs_MngCam

@export_category("RANGE TO SHOW")

@export_subgroup('AEREO')
@export var debugDisabledAereo : bool = false
@export var distMaxAereo : float
@export var distMinAereo : float
@export var objsAereo : Array[Node3D] = []

@export_subgroup('DRON')
@export var debugDisabledDron : bool = false
@export var distMaxDron : float
@export var distMinDron : float
@export var objsDron : Array[Node3D] = []

#@export_subgroup('CARRO')
#@export var debugDisabledCarro : bool = false
#@export var distMaxCarro : float
#@export var distMinCarro : float
#@export var ObjsCarro : Array[Node3D] = []

var lastStateShow : bool = true
var allowOcclusion : bool

func _init():
	allowOcclusion = false

func _ready():
	SIGNALS.OnMapa_OcclusionByButton.connect(OnMapa_OcclusionByBtn)
	mngCam.OnCameraChangeHeight.connect(OnCameraChangeHeight)

	
func OnMapa_OcclusionByBtn():
	allowOcclusion = true

func OnCameraChangeHeight(camHeight : float):
	if not allowOcclusion:
		return
	
	# OBJETOS AEREO
	if objsAereo.size() > 0:
		for objAereo in objsAereo:
			if debugDisabledAereo:
				print_rich("[color=orange] ------- [ OCCLUDER ] DEBUG DISABLE AEREO ACTIVADO ------- [/color]")
				break
				
			if camHeight >= distMinAereo and camHeight <= distMaxAereo:
				objAereo.show()
				objAereo.process_mode = Node.PROCESS_MODE_INHERIT
			else:
				objAereo.hide()
				objAereo.process_mode = Node.PROCESS_MODE_DISABLED
			
	# OBJETOS DRON
	if objsDron.size() > 0:
		for objDron in objsDron:
			if debugDisabledDron:
				print_rich("[color=orange] ------- [ OCCLUDER ] DEBUG DISABLE DRON ACTIVADO ------- [/color]")
				break
				
			if camHeight >= distMinDron and camHeight <= distMaxDron:
				objDron.show()
				objDron.process_mode = Node.PROCESS_MODE_INHERIT
			else:
				objDron.hide()
				objDron.process_mode = Node.PROCESS_MODE_DISABLED
	
	## OBJETOS CARRO
	#if ObjsCarro.size() > 0:
		#for objCarro in ObjsCarro:
			#if debugDisabledCarro:
				#print_rich("[color=orange] ------- [ OCCLUDER ] DEBUG DISABLE CARRO ACTIVADO ------- [/color]")
				#break
			#
			#if camHeight >= distMinCarro and camHeight <= distMaxCarro:
				#objCarro.show()
				#objCarro.process_mode = Node.PROCESS_MODE_INHERIT
			#else:
				#objCarro.hide()
				#objCarro.process_mode = Node.PROCESS_MODE_DISABLED
