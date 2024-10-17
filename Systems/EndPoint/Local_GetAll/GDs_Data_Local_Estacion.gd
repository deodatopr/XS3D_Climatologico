extends Resource
class_name GDs_Data_Local_Estacion

@export var id:int
@export var nombre:String
@export var estado:= ENUMS.Estado.Mexico
@export var nivelPrev:= 60.0
@export var nivelCrit:= 70.0
@export var tlrncia_prep_pluv:= 15
@export var latitud:String 
@export var longitud:String 
@export var color:Color

@export var LvlEstacion:PackedScene
@export var disponible:bool
