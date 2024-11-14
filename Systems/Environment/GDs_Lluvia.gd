extends Node

@export var worldEnv : WorldEnvironment

@export_group("Lights")
@export var lightSunSky : DirectionalLight3D
@export var lightSunFly : DirectionalLight3D
@export var lightRain : DirectionalLight3D

@export var miClouds : MeshInstance3D

@export var sndsTruenos : AudioStreamPlayer
@export var sndsTormenta : AudioStreamPlayer

@export var lensDrop : ColorRect
@export var rainFlyParticles : GPUParticles3D
@export var rainSkyParticles : GPUParticles3D

@export var timerCurve : Timer

var presetEnvSky_Sunny : Environment = preload("uid://buu228l4r1lse")
var presetEnvSky_Rain : Environment = preload("uid://hlek0c7p6ya0")
var presetEnvFly_Sunny : Environment = preload("uid://d0njvq6rqh23r")
var presetEnvFly_Rain : Environment = preload("uid://ow45nqgfxtnq")

var lightSunFlyEnergyMult : float
var originalSky : Texture2D

func _ready():
	#Save original values
	lightSunFlyEnergyMult = lightSunFly.light_energy
	SIGNALS.OnLluviaSet.connect(_OnLluviaSet)
	SIGNALS.OnCameraChangedMode.connect(SwitchRainEnvironment)
	UTILITIES.TurnOffObject(rainFlyParticles)
	UTILITIES.TurnOffObject(rainSkyParticles)

func _exit_tree():
	_RestoreValues()

func _SinLluvia():
	UTILITIES.TurnOnObject(miClouds)
	UTILITIES.TurnOffObject(lightRain)
	
	
	if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
		worldEnv.environment = presetEnvSky_Sunny
		UTILITIES.TurnOnObject(lightSunSky)
		UTILITIES.TurnOffObject(lightSunFly)
	else:
		worldEnv.environment = presetEnvFly_Sunny
		UTILITIES.TurnOffObject(lightSunSky)
		UTILITIES.TurnOnObject(lightSunFly)
	
	UTILITIES.TurnOffObject(rainSkyParticles)
	UTILITIES.TurnOffObject(rainFlyParticles)
	lensDrop.hide()
	
	_RestoreValues()
	
func _ConLluvia():
	UTILITIES.TurnOffObject(miClouds)
	
	UTILITIES.TurnOffObject(lightSunSky)
	UTILITIES.TurnOffObject(lightSunFly)
	UTILITIES.TurnOnObject(lightRain)
	
	if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
		worldEnv.environment = presetEnvSky_Rain
	else:
		worldEnv.environment = presetEnvFly_Rain
	
	
	UTILITIES.TurnOnObject(rainFlyParticles)
	UTILITIES.TurnOnObject(rainSkyParticles)

	lensDrop.show()

func _OnLluviaSet(_lluviaIntensity : int):
	match _lluviaIntensity:
		ENUMS.LluviaIntsdad.SinLluvia:
			_SinLluvia()
		ENUMS.LluviaIntsdad.ConLluvia:
			_ConLluvia()

func SwitchRainEnvironment(_cam:int):
	if DEBUG.lLuvia == ENUMS.LluviaIntsdad.SinLluvia: return
	if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
		worldEnv.environment = presetEnvSky_Rain
	else:
		worldEnv.environment = presetEnvFly_Rain


func _RestoreValues():
	lightSunFly.light_energy = lightSunFlyEnergyMult
	
func Anim_Truenos_PlaySndsTrueno():
	sndsTruenos.play()
	sndsTormenta.play()
