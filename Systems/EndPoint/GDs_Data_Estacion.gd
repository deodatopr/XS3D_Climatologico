extends Node
class_name GDs_Data_Estacion

#ENDPOINT
var id: int
var fecha : String
var nivel : float
var pptn_pluvial : float # en milímetros (mm)
var humedad : float # en porcentaje (%)
var evaporacion : float # en milímetros (mm)
var intsdad_viento : float # en kilómetros por hora (km/h)
var temperatura : float # en grados
var dir_viento : float # en grados

var disp_utr : bool
var fallo_alim_ac : bool
var volt_bat_resp : float

var enlace : bool
var energia_electrica : bool
var rebasa_nvls_presa : bool
var rebasa_tlrncia_prep_pluv : bool

#LOCAL
var nombre:String
var estado := ENUMS.Estado.Mexico
var nivelPrev : float
var nivelCrit : float
var tlrncia_prep_pluv : float
var latitud:String 
var longitud:String 
var disponible:bool
var color:Color
