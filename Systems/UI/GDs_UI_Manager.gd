extends Control

@export_group("Refs externas")
@export var dataService:GDs_DataService_Manager
@export_subgroup("Vista Drones")
@export var vistaSky:Control
@export var vistaFree:GDs_VistaFree
@export_subgroup("Refs Minimap")
@export var cam_manager:GDs_Cam_Manager
@export var worldMark:Node3D
@export var map:Node3D
@export_group("Refs internas")
@export var menuPerfiles:GDs_MenuPerfiles

var isFirstRun : bool = true
var tween:Tween

func _ready():
	#TODO: Quitar esto del ready y usar el Initialize en orquestador
	Initialize()

func Initialize():
	dataService.OnDataRefresh.connect(DataRefresh)
	
	vistaFree.cam_manager = cam_manager
	vistaFree.worldMark = worldMark
	vistaFree.map = map
	vistaFree.Initialize()

func DataRefresh():
	menuPerfiles.DataRefresh(dataService.estaciones)
