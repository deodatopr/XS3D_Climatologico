class_name GDs_EP_GetAllSitios_Error extends Node

var CR_LocalEstaciones: GDs_CR_LocalSitios

func Initialize(_CR_LocalEstaciones: GDs_CR_LocalSitios):
	CR_LocalEstaciones = _CR_LocalEstaciones
		
func GetEstaciones_NoData() -> Array[GDs_Data_EP_Sitio]:
	var estaciones : Array[GDs_Data_EP_Sitio]
	
	var fecha: String = "---- -- ----- --:--"
	var ac: bool = false
	var volt: float = NAN
	var utr: bool = false
	var enlace: bool = false
	var presaSnsr: bool = false
	var presaVal: float = NAN
	var pcptnSnsr: bool = false
	var pcptnVal: float = NAN
	var prsnSnsr: bool = false
	var prsnVal: float = NAN
	var rSolSnsr: bool = false
	var rSolVal: float = NAN
	var humTempSnsr: bool = false
	var humVal: float = NAN
	var tempVal: float = NAN
	var vntoSnsr: bool = false
	var vntoInt: float = NAN
	var vntoDir: float = NAN
	
	
	var idx : int = 0
	for sitioCR in CR_LocalEstaciones.LocalEstaciones:
		var estacionNoValues = {
		"id" : idx + 1,
		"fch": fecha,
		"ac": ac,
		"volt": volt,
		"utr": utr,
		"enlace": enlace,
		"presaSnsr": presaSnsr,
		"presaVal": presaVal,
		"pcptnSnsr": pcptnSnsr,
		"pcptnVal": pcptnVal,
		"prsnSnsr": prsnSnsr,
		"prsnVal": prsnVal,
		"rSolSnsr": rSolSnsr,
		"rSolVal": rSolVal,
		"humTempSnsr": humTempSnsr,
		"humVal": humVal,
		"tempVal": tempVal,
		"vntoSnsr": vntoSnsr,
		"vntoInt": vntoInt,
		"vntoDir": vntoDir
		}
		
		var estacion : GDs_Data_EP_Sitio = GDs_Data_EP_Sitio.new(estacionNoValues)

		estaciones.append(estacion)
		idx+=1
		
	return estaciones
	
func GetEstaciones_LastData(_lastSitiosData : Array[GDs_Data_EP_Sitio]) -> Array[GDs_Data_EP_Sitio]:
	return _lastSitiosData
