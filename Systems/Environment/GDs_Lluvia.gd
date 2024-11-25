class_name GDs_Lluvia extends Node

@export var worldEnv : WorldEnvironment

@export_group("Lights")
@export var lightSunSky : DirectionalLight3D
@export var lightSunFly : DirectionalLight3D
@export var lightRain : DirectionalLight3D

@export var miClouds : MeshInstance3D

@export var sndsTruenos : AudioStreamPlayer

@export var lensDrop : ColorRect
@export var lensDroplets : ColorRect
@export var rainFlyParticles : GPUParticles3D
@export var rainSkyParticles : GPUParticles3D

@export_group("Truenos")
@export var minTrueno : int = 10
@export var maxTrueno : int = 30
@export var timerTruenos : Timer
@export var curveTrueno : Curve

var thunderIsPlaying : bool
var timeCurve : float

var initWorldEnvIntensity : float
var initDirLightIntensity : float

var presetEnvSky_Sunny : Environment = preload('res://Systems/Camera/Presets/Preset_Env_Sky_Sunny.tres')
var presetEnvSky_Rain : Environment = preload("uid://hlek0c7p6ya0")
var presetEnvFly_Sunny : Environment = preload('res://Systems/Camera/Presets/Preset_Env_Fly_Sunny.tres')
var presetEnvFly_Rain : Environment = preload("uid://ow45nqgfxtnq")

func Initialize():
	if APPSTATE.currntSitio.lloviendo:
		_ConLluvia()
	else:
		_SinLluvia()
		
func _ready():
	#Save original values
	SIGNALS.OnRefresh.connect(_OnRefresh)
	SIGNALS.OnCameraChangedMode.connect(SwitchRainEnvironment)
	UTILITIES.TurnOffObject(rainFlyParticles)
	UTILITIES.TurnOffObject(rainSkyParticles)
	
	timerTruenos.timeout.connect(_Timeout)
	
	#Direct & Indirect lighting
	initWorldEnvIntensity = worldEnv.environment.background_intensity
	initDirLightIntensity = lightRain.light_energy
	

func _process(delta):
	if thunderIsPlaying:
		worldEnv.environment.background_intensity = initWorldEnvIntensity * curveTrueno.sample(timeCurve)
		lightRain.light_energy = initDirLightIntensity * curveTrueno.sample(timeCurve)
		timeCurve += delta
		
		if timeCurve > 1.0:
			thunderIsPlaying = false
			timerTruenos.start(randi_range(minTrueno,maxTrueno))
			
	
	
func _Timeout():
	timeCurve = 0.0
	worldEnv.environment.background_intensity = initWorldEnvIntensity
	lightRain.light_energy = initDirLightIntensity
	
	sndsTruenos.play()
	thunderIsPlaying = true
	
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
	lensDroplets.hide()
	thunderIsPlaying = false
	timerTruenos.stop()

	
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
	lensDroplets.show()
	
	if timerTruenos.is_stopped():
		timerTruenos.start(randi_range(minTrueno,maxTrueno))

func _OnRefresh():
	if APPSTATE.currntSitio.lloviendo:
		_ConLluvia()
	else:
		_SinLluvia()

func SwitchRainEnvironment(_cam:int):
	if not APPSTATE.currntSitio.lloviendo: return
	if APPSTATE.camMode == ENUMS.Cam_Mode.sky:
		worldEnv.environment = presetEnvSky_Rain
		lensDroplets.hide()
	else:
		worldEnv.environment = presetEnvFly_Rain
		lensDroplets.show()
