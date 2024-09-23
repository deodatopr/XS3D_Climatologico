class_name GDs_MngScenes extends Node

@export var dataService : DATA_SERVICE
@export var curtain : GDs_Curtain

@export var ASSETS_parentRoot : Node
@export var timerDestroyObject : Timer
@export var lvlMapa : PackedScene


signal OnInstanciateMapa3D(_mapa3d : GDs_RefExtMapa)
signal OnUnloadScene()

var instanceMapa3D : GDs_RefExtMapa
var instanceSitio : Node3D

var lastDayTimeMapa3d : int = -1
var lastIdSitioVisited : int = -1
var sitio : GDs_SITIO

func _ready():
	SIGNALS.OnVerSitioPressed.connect(GoToSitio)
	
func GoToMapa3d():
	curtain.Show()
	await  curtain.OnCurtainCovered
	
	timerDestroyObject.start(0.05)
	await timerDestroyObject.timeout
	
	#Descargar sitio si es que está cargado
	lastIdSitioVisited = -1
	if instanceSitio:
		ProcessToUnloadSitio()
		timerDestroyObject.start(0.25)
		await timerDestroyObject.timeout
	
	#Cargar mapa3d
	ProcessToLoadMapa3d()
	
	timerDestroyObject.start(0.5)
	await timerDestroyObject.timeout
	
	curtain.Hide()
	
func GoToSitio(_idSitio : int):
	#Regresar si intentas ir al mismo sitio
	if lastIdSitioVisited == _idSitio:
		return
	
	#Regresar si no tiene escena el sitio
	sitio = dataService.GetSitioById(_idSitio)
	if not sitio.LvlDisponible:
		return
	
	curtain.Show()
	await  curtain.OnCurtainCovered
	
	SIGNALS.OnGoToSitio.emit()
	
	#Checar si mapa esta cargado y descargarlo de memoria
	if instanceMapa3D:
		ProcessToUnloadMapa3D()
		timerDestroyObject.start(0.2)
		await timerDestroyObject.timeout
	
	#Checar si estas en un sitio y quieres cambiarte a otro, descargar de memoria el anterior
	if instanceSitio:
		ProcessToUnloadSitio()
		timerDestroyObject.start(0.2)
		await timerDestroyObject.timeout
	
	#Cargar el sitio
	ProcessToLoadSitio(_idSitio)
	
	timerDestroyObject.start(0.2)
	await timerDestroyObject.timeout
	
	SIGNALS.OnSitioInstanciated.emit(sitio)
	
	lastIdSitioVisited = _idSitio
	curtain.Hide()
	
func ExitMapa3dOrSitio():
	curtain.Show()
	await  curtain.OnCurtainCovered
	
	if instanceMapa3D:
		ProcessToUnloadMapa3D()
	
	if instanceSitio:
		ProcessToUnloadSitio()
	
	timerDestroyObject.start(0.5)
	await timerDestroyObject.timeout
	lastIdSitioVisited = -1
	
	OnUnloadScene.emit()
	curtain.Hide()
	
#region [ LOAD/UNLOAD MAPA ]
func ProcessToLoadMapa3d():
	if lastDayTimeMapa3d != -1:
		STATE.dayTime = lastDayTimeMapa3d
	
	#Instanciar mapa3D
	instanceMapa3D = lvlMapa.instantiate() as GDs_RefExtMapa
	instanceMapa3D.process_mode = Node.PROCESS_MODE_ALWAYS
	instanceMapa3D.Initialize(dataService)
	
	#Acomodarlo en jerarquia
	ASSETS_parentRoot.add_child(instanceMapa3D)
	ASSETS_parentRoot.move_child(instanceMapa3D,0)
	
	if not instanceMapa3D.is_node_ready():
		await instanceMapa3D.ready
	
	#Aviso de que fue instanciado para sistemas se reseten o inicialicen
	lastDayTimeMapa3d = STATE.dayTime
	OnInstanciateMapa3D.emit(instanceMapa3D)
	SIGNALS.OnMapa3DInstanciated.emit()
	
func ProcessToUnloadMapa3D():
	instanceMapa3D.free()
	instanceMapa3D = null
#endregion

#region [ LOAD/UNLOAD SITIO ]
func ProcessToLoadSitio(_idSitio : int):
	#Cambiar a modo lluvia si esta en critico
	if sitio.estaEnNivelCritico:
		if lastDayTimeMapa3d == ENUMS.DAYTIME.DIA or lastDayTimeMapa3d == ENUMS.DAYTIME.TARDE:
			STATE.dayTime = ENUMS.DAYTIME.LLUVIALUZ
		else:
			STATE.dayTime = ENUMS.DAYTIME.LLUVIANOCHE
	
	#Instanciar sitio
	instanceSitio = sitio.LvlSitio.instantiate()
	
	#Acomodarlo en jerarquia
	ASSETS_parentRoot.add_child(instanceSitio)
	ASSETS_parentRoot.move_child(instanceSitio,0)
	
	#Esperar a que esta listo el sitio
	if not instanceSitio.is_node_ready():
		await instanceSitio.ready
	
func ProcessToUnloadSitio():
	instanceSitio.free()
	instanceSitio = null
#endregion
