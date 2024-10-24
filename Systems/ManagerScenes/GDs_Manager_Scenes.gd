class_name GDs_Scenes_Manager extends Node

@export var curtain : GDs_Curtain
@export var sceneParentRoot: Node

signal OnSectorLoaded
signal OnSectorUnloaded

var instanceSector : Node3D
var lastIdSectorVisited : int = -1

func GoToSector(_lvlSector : PackedScene):
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
	instanceSector = _lvlSector.instantiate()
	instanceSector.process_mode = Node.PROCESS_MODE_ALWAYS
	sceneParentRoot.add_child(instanceSector)
	sceneParentRoot.move_child(instanceSector,0)
	
	if not instanceSector.is_node_ready():
		await instanceSector.ready
	
	OnSectorLoaded.emit()

func _ProcessToUnloadSector():
	instanceSector.free()
	instanceSector = null
