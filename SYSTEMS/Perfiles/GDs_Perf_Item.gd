extends Control
class_name Perf_Item

@export_group("Expand / Collapse")
@export var buttonExpandir:Button
@export var collapsedSize: float
@export var expandedSize: float

@export_group("Datos")
@export var id:Label
@export var nombre:Label
@export var fecha:Label

@export var enlaceOn:Control
@export var enlaceOff:Control
@export var energiaOn:Control
@export var energiaOff:Control
@export var nvlNorm:Control
@export var nvlCrit:Control
@export var pptnNorm:Control
@export var pptnCrit:Control

@export var barraNvl:GDs_BarraNivel
@export var barraPptn:GDs_BarraNivel

@export var humedad:Label
@export var evaporacion:Label
@export var intViento:Label
@export var temperatura:Label
@export var dirViento:Label
@export var DispUTR:Label
@export var Voltaje:Label


var isOpen : bool
var estacionId:int

func _ready():
	buttonExpandir.toggled.connect(OnPressedShowExtraInfo)

func RefreshInfo(estacion:GDs_Data_Estacion):
	estacionId = estacion.id
	id.text = str(estacion.id)
	nombre.text = estacion.nombre
	fecha.text = estacion.fecha
	
	enlaceOn.visible = estacion.enlace
	enlaceOff.visible = !estacion.enlace
	energiaOn.visible = estacion.energia_electrica
	energiaOff.visible = !estacion.energia_electrica
	nvlNorm.visible = !estacion.rebasa_nvls_presa
	nvlCrit.visible = estacion.rebasa_nvls_presa
	pptnNorm.visible = !estacion.rebasa_tlrncia_prep_pluv
	pptnCrit.visible = estacion.rebasa_tlrncia_prep_pluv
	
	barraNvl.FillBarData(estacion.nivel,estacion.nivelPrev,estacion.nivelCrit)
	barraPptn.FillBarData(estacion.pptn_pluvial,estacion.tlrncia_prep_pluv,estacion.tlrncia_prep_pluv)
	
	humedad.text = UTILITIES.FormatHumedad(estacion.humedad)
	evaporacion.text = UTILITIES.FormatEvaporacion(estacion.evaporacion)
	intViento.text = UTILITIES.FormatIntensidadViento(estacion.intsdad_viento)
	temperatura.text = UTILITIES.FormatTemperatura(estacion.temperatura)
	dirViento.text = UTILITIES.FormatDirViento(estacion.dir_viento)
	DispUTR.text = "true"
	Voltaje.text = UTILITIES.FormatBateriaV(estacion.volt_bat_resp)
	
	

func OnPressedShowExtraInfo(_toggle:bool):
	if _toggle:
		OpenItemExtraInfo()
	elif not _toggle:
		CloseItemExtraInfo()

func OpenItemExtraInfo():
	isOpen = true
	var tween: Tween
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 'custom_minimum_size', Vector2(720,expandedSize),0.2)
	tween.parallel().tween_property(self, 'size', Vector2(720,expandedSize),0.2)
		
func CloseItemExtraInfo():
	isOpen = false
	var tween: Tween
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 'custom_minimum_size', Vector2(720,collapsedSize),0.2)
	tween.parallel().tween_property(self, 'size', Vector2(720,collapsedSize),0.2)
	
func On_Graficodora_Btn_Pressed():
	pass

func OnSitioPressed():
	SIGNALS.OnGoToEstacionBtnPressed.emit(estacionId)
