class_name GDs_Data_Sitio extends Node

#ENDPOINT
var id: int
var fecha: String
var ac: bool
var volt: float
var utr: bool
var enlace: bool
var presaSnsr: bool
var presaVal: float
var pcptnSnsr: bool
var pcptnVal: float
var prsnSnsr: bool
var prsnVal: float
var rSolSnsr: bool
var rSolVal: float
var humTempSnsr: bool
var humVal: float
var tempVal: float
var vntoSnsr: bool
var vntoInt: float
var vntoDir: float


#LOCAL
var nombre:String
var estado := ENUMS.Estado.Mexico
var nivelNormal : float
var nivelPrev : float
var nivelCrit : float
var tlrncia_prep_pluv : float
var latitud:String 
var longitud:String 
var disponible:bool
var color:Color

#EXTRAS
var enPrev : bool
var enCrit : bool
