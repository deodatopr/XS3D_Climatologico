extends Node

@export var worldEnv : WorldEnvironment
@export var lightSunSky : DirectionalLight3D
@export var lightSunFly : DirectionalLight3D

@export var animTruenos : AnimationPlayer
@export var sndsTruenos : AudioStreamPlayer
@export var sndsTormenta : AudioStreamPlayer

@onready var sky_rain = preload("uid://djudm04t7vifd")

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

func _LluviaNada():
	if animTruenos.is_playing():
		animTruenos.stop()
		
	_RestoreValues()
	
func _LluviaModerada():
	var panoramaSkyMat : PanoramaSkyMaterial = worldEnv.environment.sky.sky_material
	panoramaSkyMat.panorama = sky_rain

		
func _LluviaIntensa():
	print(animTruenos.is_playing())
	if not animTruenos.is_playing():
		var panoramaSkyMat : PanoramaSkyMaterial = worldEnv.environment.sky.sky_material
		panoramaSkyMat.panorama = sky_rain
		
		animTruenos.play("anim_Truenos")

func _OnLluviaSet(_lluviaIntensity : int):
	print(_lluviaIntensity)
	match _lluviaIntensity:
		ENUMS.LluviaIntsdad.Nada:
			_LluviaNada()
		ENUMS.LluviaIntsdad.Moderada:
			_LluviaModerada()
		ENUMS.LluviaIntsdad.Intensa:
			_LluviaIntensa()

func _RestoreValues():
	worldEnv.environment.background_energy_multiplier = worldEnvEnergyMult
	lightSunSky.light_energy = lightSunSkyEnergyMult
	lightSunFly.light_energy = lightSunFlyEnergyMult
	var panoramaSkyMat : PanoramaSkyMaterial = worldEnv.environment.sky.sky_material
	panoramaSkyMat.panorama = originalSky
	
func Anim_Truenos_PlaySndsTrueno():
	sndsTruenos.play()
	sndsTormenta.play()
