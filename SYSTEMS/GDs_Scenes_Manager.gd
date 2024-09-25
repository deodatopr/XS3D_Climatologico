class_name GDs_Scenes_Manager
extends Node

@export var dataService : GDs_DataService_Manager
@export var curtain : GDs_Curtain
@export var sceneParentRoot: Node

@export var lvlMapa:PackedScene

signal OnInstantiateMapa3D
signal OnInstantiateEstacion
signal OnUnloadScene
var instanceEstacion : Node3D
var estacion: GDs_Data_Estacion
var lastIdEstacionVisited : int = -1
var instanceMapa
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Initialize()
	pass # Replace with function body.

func Initialize():
	SIGNALS.OnGoToEstacionBtnPressed.connect(GoToEstacion)
	ProcessToLoadMapa()
	pass

func GoToMapa3D():
	#Mostrar cortina
	curtain.Show()
	await  curtain.OnCurtainCovered
	await get_tree().create_timer(0.5).timeout
	
	#Descargar estacion si es que esta cargada
	lastIdEstacionVisited = -1
	if instanceEstacion:
		ProcessToUnloadEstacion()
		await get_tree().create_timer(0.25).timeout
	
	#cargar Mapa3D
	ProcessToLoadMapa()
	
	await get_tree().create_timer(0.5).timeout
	curtain.Hide()

func GoToEstacion(idEstacion:int):
	if lastIdEstacionVisited == idEstacion:
		return
	estacion = dataService.GetEstacionById(idEstacion) as GDs_Data_Estacion
	
	if not estacion.disponible:
		return
	
	curtain.Show()
	await curtain.OnCurtainCovered
	
	if instanceMapa:
		ProcessToUnloadMapa3D()
	
	if instanceEstacion:
		ProcessToUnloadEstacion()
	
	ProcessToLoadEstacion()
	lastIdEstacionVisited = idEstacion
	
	await get_tree().create_timer(0.5).timeout
	curtain.Hide()

func ProcessToLoadMapa():
	instanceMapa = lvlMapa.instantiate()
	instanceMapa.process_mode = Node.PROCESS_MODE_ALWAYS
	sceneParentRoot.add_child(instanceMapa)
	sceneParentRoot.move_child(instanceMapa,0)
	
	if not instanceMapa.is_node_ready():
		await instanceMapa.ready
	
	
	
	OnInstantiateMapa3D.emit()

func ProcessToUnloadMapa3D():
	instanceMapa.free()
	instanceMapa = null

func ProcessToLoadEstacion():
	instanceEstacion = estacion.LvlEstacion.instantiate()
	instanceEstacion.process_mode = Node.PROCESS_MODE_ALWAYS
	sceneParentRoot.add_child(instanceEstacion)
	sceneParentRoot.move_child(instanceEstacion,0)
	
	if not instanceEstacion.is_node_ready():
		await instanceEstacion.ready
	
	OnInstantiateEstacion.emit()

func ProcessToUnloadEstacion():
	instanceEstacion.free()
	instanceEstacion = null
