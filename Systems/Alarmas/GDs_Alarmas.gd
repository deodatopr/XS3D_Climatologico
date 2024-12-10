class_name GDs_Alarmas
extends Node

@export var ppePresa:ColorRect
@export var ppeTemp:ColorRect
@export var sndAlarm:AudioStreamPlayer

@export_group("Debug")
@export var dbgEnable:bool = false
@export var estadoPresa:int = 0
@export var estadoTemp:int = 0

func Initialize():
	SIGNALS.OnRefresh.connect(OnRefresh)
	OnRefresh()

func _process(_delta):
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
	if APPSTATE.currntSitio.tempVal > CONST.thrshld_temperatura_calida:
		SetTempToPrev()
	if APPSTATE.currntSitio.tempVal > CONST.thrshld_temperatura_alta:
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
	
