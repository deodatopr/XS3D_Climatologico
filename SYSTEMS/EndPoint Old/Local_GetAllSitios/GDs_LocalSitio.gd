extends Resource

class_name GDs_LocalSitio

@export var IdLocal : int
@export var IdSitio : int
@export var Estructura : int
@export var NombreEstructura : String
@export var Abreviacion : String
@export var Direccion : String
@export var NvlNormal : float
@export var NvlPreventivo : float = 0.05
@export var NvlCritico : float = 0.25
@export var lvlSitio : PackedScene
@export var disponible : bool
@export var unSoloSentido:bool
