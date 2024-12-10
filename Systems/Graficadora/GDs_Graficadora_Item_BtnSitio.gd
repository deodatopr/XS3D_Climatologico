class_name GDs_Graficadora_Item_BtnSitio extends Button

@export var idPatch : Control
@export var lblId : Label
@export var lblName : Label


var id : int
var siteName : String

func Initialize(_siteColor : Color, _id : int, _name : String):
	id = _id
	siteName = _name
	
	idPatch.self_modulate = _siteColor
	lblId.text = str(_id)
	lblName.text = _name
	
	pressed.connect(OnBtnPressed)

func CheckBtnSelected(_idCurrentSitio : int):
	button_pressed = _idCurrentSitio == id

func OnBtnPressed():
	SIGNALS.On_BtnSitioPressed.emit(id,siteName)
