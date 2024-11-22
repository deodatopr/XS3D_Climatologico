extends Node

@export var fadeInDuration : float = 2
var audioTween : Tween

func _ready():
	SIGNALS.OnSitioReady.connect(_OnSitioReady)

func _OnSitioReady():
	#Inicia audio con fade In al iniciar un sitio	
	var targetAudio : float = AUDIO.MasterVolume
	audioTween = create_tween()
	audioTween.tween_method(AudioFadeIn,0.0,targetAudio,fadeInDuration)

func AudioFadeIn(_value : float):
	AUDIO.MasterVolume = _value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(_value))
	
func _exit_tree():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(0))
