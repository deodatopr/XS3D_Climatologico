extends Node

@export var camManager : GDs_Cam_Manager
@export var worldEnv : WorldEnvironment

var environment : Environment
var tween : Tween

func _ready():
	camManager.OnCamChangeMode.connect(OnCamModeChanged)
	environment = worldEnv.environment
	
func OnCamModeChanged():
	tween = get_tree().create_tween()
	tween.tween_property(environment,"adjustment_saturation",.2,.7)
	tween.chain().tween_property(environment,"adjustment_saturation",1,.7)
