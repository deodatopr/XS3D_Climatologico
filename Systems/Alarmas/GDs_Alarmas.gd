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
			1:
				SetPresaToNorm()
			1:
				SetPresaToPrev()
			2:
				SetPresaToCrit()
		match estadoTemp:
			1:
				SetTempToNorm()
			1:
				SetTempToPrev()
			2:
				SetTempToCrit()

func OnRefresh():
	if dbgEnable: return
	match APPSTATE.currntSitio.nivel:
		1:
			SetPresaToNorm()
		1:
			SetPresaToPrev()
		2:
			SetPresaToCrit()
	
	SetTempToNorm()
	if APPSTATE.currntSitio.temperatura > 24:
		SetTempToPrev()
	if APPSTATE.currntSitio.temperatura > 28:
		SetTempToCrit()

func SetPresaToNorm():
	ppePresa.hide()
	sndAlarm.stop()

func SetPresaToPrev():
	ppePresa.show()
	sndAlarm.stop()

func SetPresaToCrit():
	ppePresa.show()
	if not sndAlarm.playing:
		sndAlarm.play()


func SetTempToNorm():
	ppeTemp.hide()
func SetTempToPrev():
	ppeTemp.show()
	ppeTemp.material.set_shader_parameter("intensity",0.1)
func SetTempToCrit():
	ppeTemp.show()
	ppeTemp.material.set_shader_parameter("intensity",0.2)
