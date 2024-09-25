extends Node
class_name GDs_Orchestrator_Main

@export var splash : GDs_Splash
@export var curtain : GDs_Curtain
@export var serviceData_manager : GDs_DataService_Manager

func _ready():
	splash.Show()
	await splash.OnFinishSplash
	
	curtain.Show()
	await curtain.OnCurtainCovered
	
	#mngServiceData.Initialize()
	#await mngServiceData.OnDataRefresh
	
	
	
	curtain.Hide()
	await curtain.OnCurtainFinished
	
