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
var presetEnvSky_Rain : Environment = preload("uid://pmji8hv2eh0f")

var presetEnvFly_Sunny : Environment = preload("uid://d0njvq6rqh23r")
var presetEnvFly_Rain : Environment = preload("uid://ow45nqgfxtnq")

var worldEnvEnergyMult : float
var lightSunSkyEnergyMult : float
var lightSunFlyEnergyMult : float
var originalSky : Texture2D

func _ready():
	#Save original values
	worldEnvEnergyMult = worldEnv.environment.background_energy_multiplier
	lightSunSkyEnergyMult = lightSunSky.light_energy
	lightSunFlyEnergyMult = lightSunFly.light_energy
	var panoramaSkyMat : PanoramaSkyMaterial = worldEnv.environment.sky.sky_material
	originalSky = panoramaSkyMat.panorama
	
	SIGNALS.OnLluviaSet.connect(_OnLluviaSet)

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
	
	rainSkyParticles.hide()
	rainFlyParticles.hide()
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
	
	
	rainSkyParticles.show()
	rainFlyParticles.show()
	lensDrop.show()

func _OnLluviaSet(_lluviaIntensity : int):
	match _lluviaIntensity:
		ENUMS.LluviaIntsdad.SinLluvia:
			_SinLluvia()
		ENUMS.LluviaIntsdad.ConLluvia:
			_ConLluvia()

func _RestoreValues():
	worldEnv.environment.background_energy_multiplier = worldEnvEnergyMult
	lightSunSky.light_energy = lightSunSkyEnergyMult
	lightSunFly.light_energy = lightSunFlyEnergyMult
	var panoramaSkyMat : PanoramaSkyMaterial = worldEnv.environment.sky.sky_material
	panoramaSkyMat.panorama = originalSky
	
func Anim_Truenos_PlaySndsTrueno():
	sndsTruenos.play()
	sndsTormenta.play()
