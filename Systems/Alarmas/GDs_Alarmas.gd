extends Node

@export var ppePresa:ColorRect
@export var ppeTemp:ColorRect
@export var sndAlarm:AudioStreamPlayer

@export_group("Debug")
@export var dbgEnable:bool = false
@export var estadoPresa:int = 0
@export var estadoTemp:int = 0

func _ready():
	SIGNALS.OnRefresh.connect(OnRefresh)

func _process(delta):
	if dbgEnable:
		match estadoPresa:
			0:
				SetPresaToNorm()
			1:
				SetPresaToPrev()
			2:
				SetPresaToCrit()
		match estadoTemp:
			0:
				SetTempToNorm()
			1:
				SetTempToPrev()
			2:
				SetTempToCrit()

func OnRefresh():
	if dbgEnable: return
	SetPresaToNorm()
	if APPSTATE.currntSitio.enPrev:
		SetPresaToPrev()
	if APPSTATE.currntSitio.enCrit:
		SetPresaToCrit()
	
	SetTempToNorm()
	if APPSTATE.currntSitio.temperatura > 24:
		SetTempToPrev()
	if APPSTATE.currntSitio.temperatura > 28:
		SetTempToCrit()

func SetPresaToNorm():
	ppePresa.hide()
	AudioServer.set_bus_mute(3,true)
	ppePresa.material.set_shader_parameter("stop",0)
	

func SetPresaToPrev():
	ppePresa.show()
	AudioServer.set_bus_mute(3,true)
	ppePresa.material.set_shader_parameter("isCritico",false)
	ppePresa.material.set_shader_parameter("stop",1)
	

func SetPresaToCrit():
	ppePresa.show()
	if AudioServer.is_bus_mute(3):
			AudioServer.set_bus_mute(3,false)
	ppePresa.material.set_shader_parameter("isCritico",true)
	ppePresa.material.set_shader_parameter("stop",1)
	


func SetTempToNorm():
	ppeTemp.hide()
func SetTempToPrev():
	ppeTemp.show()
	ppeTemp.material.set_shader_parameter("intensity",0.1)
func SetTempToCrit():
	ppeTemp.show()
	ppeTemp.material.set_shader_parameter("intensity",0.2)
	
