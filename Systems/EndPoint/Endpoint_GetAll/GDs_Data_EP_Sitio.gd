class_name GDs_Data_EP_Sitio extends Node

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

func _init(_sitio : Dictionary) :
	id = _sitio["id"]
	fecha = _sitio["fch"]
	ac = _sitio["ac"]
	volt = _sitio["volt"]
	utr = _sitio["utr"]
	enlace = _sitio["enlace"]
	presaSnsr = _sitio["presaSnsr"]
	presaVal = _sitio["presaVal"]
	pcptnSnsr = _sitio["pcptnSnsr"]
	pcptnVal = _sitio["pcptnVal"]
	prsnSnsr = _sitio["prsnSnsr"]
	prsnVal = _sitio["prsnVal"]
	rSolSnsr = _sitio["rSolSnsr"]
	rSolVal = _sitio["rSolVal"]
	humTempSnsr = _sitio["humTempSnsr"]
	humVal = _sitio["humVal"]
	tempVal = _sitio["tempVal"]
	vntoSnsr = _sitio["vntoSnsr"]
	vntoInt = _sitio["vntoInt"]
	vntoDir = _sitio["vntoDir"]
