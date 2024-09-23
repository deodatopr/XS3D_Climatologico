extends Node
class_name GDs_Data_EP_Estacion

var id: int
var fecha : String
var nivel : float
var pptn_pluvial : float # en milímetros (mm)
var humedad : float # en porcentaje (%)
var evaporacion : float # en milímetros (mm)
var intsdad_viento : float # en kilómetros por hora (km/h)
var dir_viento : float # en grados
var temperatura : float # en grados

var disp_utr : bool
var fallo_alim_ac : bool
var volt_bat_resp : float

var enlace : bool
var energia_electrica : bool
var rebasa_nvls_presa : bool
var rebasa_tlrncia_prep_pluv : bool


func _init(_estacion : Dictionary) :
	id = _estacion["IdSitio"]
	fecha = _estacion["fecha"]
	nivel = _estacion["nivel"]
	pptn_pluvial = _estacion["pptn_pluvial"]
	humedad = _estacion["humedad"]
	evaporacion = _estacion["evaporacion"]
	intsdad_viento = _estacion["intsdad_viento"]
	dir_viento = _estacion["dir_viento"]
	temperatura = _estacion["temperatura"]
	
	disp_utr = _estacion["disp_utr"]
	fallo_alim_ac = _estacion["fallo_alim_ac"]
	volt_bat_resp = _estacion["volt_bat_resp"]
	
	enlace = _estacion["enlace"]
	energia_electrica = _estacion["energia_electrica"]
	rebasa_nvls_presa = _estacion["rebasa_nvls_presa"]
	rebasa_tlrncia_prep_pluv = _estacion["rebasa_tlrncia_prep_pluv"]
