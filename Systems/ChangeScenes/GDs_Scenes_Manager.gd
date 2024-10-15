class_name GDs_Scenes_Manager extends Node

@export var dataService : GDs_DataService_Manager
@export var curtain : GDs_Curtain
@export var sceneParentRoot: Node
@export var lvlMapa:PackedScene

signal OnInstantiateMapa
signal OnInstantiateEstacion
#signal OnUnloadScene

var instanceEstacion : Node3D
var instanceMapa : Node3D
var estacion: GDs_Data_Estacion

var lastIdEstacionVisited : int = -1

func Initialize():
	#SIGNALS.OnGoToEstacionBtnPressed.connect(GoToEstacion)
	_ProcessToLoadMapa()

func GoToMapa3D():
	#Mostrar cortina
	curtain.Show()
	await  curtain.OnCurtainCovered
	await get_tree().create_timer(0.5).timeout
	
	#Descargar estacion si es que esta cargada
	lastIdEstacionVisited = -1
	if instanceEstacion:
		_ProcessToUnloadEstacion()
		await get_tree().create_timer(0.25).timeout
	
	#cargar Mapa3D
	_ProcessToLoadMapa()
	
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
		_ProcessToUnloadMapa()
	
	if instanceEstacion:
		_ProcessToUnloadEstacion()
	
	_ProcessToLoadEstacion()
	lastIdEstacionVisited = idEstacion
	
	await get_tree().create_timer(0.5).timeout
	curtain.Hide()

#region [ Load / Unload Mapa ]
func _ProcessToLoadMapa():
	instanceMapa = lvlMapa.instantiate()
	instanceMapa.process_mode = Node.PROCESS_MODE_ALWAYS
	sceneParentRoot.add_child(instanceMapa)
	sceneParentRoot.move_child(instanceMapa,0)
	
	if not instanceMapa.is_node_ready():
		await instanceMapa.ready
	
	OnInstantiateMapa.emit()

func _ProcessToUnloadMapa():
	instanceMapa.free()
	instanceMapa = null
#endregion

#region [ Load / Unload Estacion ]
func _ProcessToLoadEstacion():
	instanceEstacion = estacion.LvlEstacion.instantiate()
	instanceEstacion.process_mode = Node.PROCESS_MODE_ALWAYS
	sceneParentRoot.add_child(instanceEstacion)
	sceneParentRoot.move_child(instanceEstacion,0)
	
	if not instanceEstacion.is_node_ready():
		await instanceEstacion.ready
	
	OnInstantiateEstacion.emit()

func _ProcessToUnloadEstacion():
	instanceEstacion.free()
	instanceEstacion = null
#endregion
