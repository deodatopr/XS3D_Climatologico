extends Resource
class_name GDs_Data_Local_Estacion

@export var id:int
@export var nombre:String
@export var estado:= ENUMS.Estado.Mexico
@export var nivelNormal : float = 30.0
@export var nivelPrev : float = 60.0
@export var nivelCrit : float = 70.0
@export var tlrncia_prep_pluv:= 15
@export var latitud:String 
@export var longitud:String 
@export var color:Color
@export var disponible:bool
