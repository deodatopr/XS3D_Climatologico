class_name GDs_Graficadora_Item_BtnSitio extends Button

@export var idPatch : Control
@export var lblId : Label
@export var lblName : Label

var id : int

func Initialize(_siteColor : Color, _id : int, _name : String):
	id = _id
	
	idPatch.self_modulate = _siteColor
	lblId.text = str(_id)
	lblName.text = _name
	
func OnBtnPressed():
	SIGNALS.On_BtnSitioPressed.emit(id)
