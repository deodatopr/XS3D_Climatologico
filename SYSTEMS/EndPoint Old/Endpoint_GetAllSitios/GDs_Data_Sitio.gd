extends Node

class_name GDs_DATA_SITIO

var IdSitio : int
var Enlace : bool
var Voltaje : float
var Fecha : String
var SignalsContainer : Array[SgnlsCont] = []

func _init(_sitio : Dictionary) :
	IdSitio = _sitio["IdSitio"]
	Enlace = _sitio["Enlace"]
	Voltaje = _sitio["Voltaje"]
	Fecha = _sitio["Fecha"]
	
	var arraySignalsCont = _sitio["SignalsContainer"]
	for signalCont in arraySignalsCont : 
		var signalContInst = SgnlsCont.new(signalCont)
		SignalsContainer.append(signalContInst)

class SgnlsCont:
	var TipoSignal : int
	var Signals : Array[SgnlsCont_Sgnls] = []
	
	func _init(_signalCont : Dictionary ):
		TipoSignal = _signalCont['TipoSignal']
		
		var arraySignals : Array =_signalCont['Signals']
		for elmtSignal in arraySignals:
			var signalInst : SgnlsCont_Sgnls = SgnlsCont_Sgnls.new(elmtSignal)
			Signals.append(signalInst)
	

class SgnlsCont_Sgnls:
	var Valor : float
	
	func _init(_signal : Dictionary):
		Valor = _signal["Valor"]
		
