class_name GDs_Scenes_Manager extends Node

@export var sceneParentRoot: Node
@export var sitios : Dictionary = {}

signal OnSectorLoaded
signal OnSectorUnloaded

var dataService : GDs_DataService_Manager
var curtain : GDs_Curtain
var instanceSector : GDs_Sector
var lastIdSectorVisited : int = -1

func _ready():
	SIGNALS.OnGoToSitio.connect(GoToSector)

func Initialize(_dataService : GDs_DataService_Manager, _curtain : GDs_Curtain):
	dataService = _dataService
	curtain = _curtain
	
func GetRndIdSite() -> int:
	var rndId : int = randi_range(0,sitios.size() -1)
	return sitios.keys()[rndId]

func GoToSector(_id : int):
	var _lvlSector : PackedScene = sitios[_id] as PackedScene
	
	#Mostrar cortina
	curtain.Show()
	await  curtain.OnCurtainCovered
	await get_tree().create_timer(0.5).timeout
	
	#Descargar sector si es que esta cargada
	lastIdSectorVisited = -1
	if instanceSector:
		_ProcessToUnloadSector()
		await get_tree().create_timer(0.25).timeout
	
	#Cargar nuevo sector
	_ProcessToLoadSector(_lvlSector)
	
	await get_tree().create_timer(0.5).timeout
	curtain.Hide()

func _ProcessToLoadSector(_lvlSector : PackedScene):
	instanceSector = _lvlSector.instantiate() as GDs_Sector
	instanceSector.process_mode = Node.PROCESS_MODE_ALWAYS
	
	sceneParentRoot.add_child(instanceSector)
	sceneParentRoot.move_child(instanceSector,0)
	
	if not instanceSector.is_node_ready():
		await instanceSector.ready
	
	instanceSector.Initialize(dataService)
	OnSectorLoaded.emit()

func _ProcessToUnloadSector():
	instanceSector.free()
	instanceSector = null
