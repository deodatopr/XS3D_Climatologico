class_name GDs_BarraInfo
extends Control

@export_group("Data Refresh")
@export_subgroup("Color, ID & Nombre")
@export var id:Label
@export var idframe:Control
@export var nombre:Label
@export var estado:Label
@export var fecha:Label
@export_subgroup("Senales")
@export var senal:Control
@export var UTR:Control
@export var OnColor:Color
@export var OffColor:Color
@export_subgroup("Nivel")
@export var nivel:Label
@export var nivelBg:Control
@export var nivelNorm:Label
@export var nivelPrev:Label
@export var nivelCrit:Label
@export var ColorNorm:Color
@export var ColorPrev:Color
@export var ColorCrit:Color
@export var animColor:Color
@export_subgroup("Datos")
@export var precipitacion:Label
@export var humedad:Label
@export var evaporacion:Label
@export var temp:Label
@export var presion:Label
@export var viento:Label
@export var lblBateria : Label

var tween:Tween

func OnDataRefresh():
	var sitio : GDs_Data_Estacion = APPSTATE.currntSitio
	
	id.text = str(sitio.id)
	idframe.self_modulate = sitio.color
	nombre.text = sitio.nombre
	estado.text = UTILITIES.FormatEstado(sitio.estado)
	
	#Senales
	if sitio.enlace:
		senal.self_modulate = OnColor
	else:
		senal.self_modulate = OffColor
	if sitio.disp_utr:
		UTR.self_modulate = OnColor
	else:
		UTR.self_modulate = OffColor
	
	#nivel
	nivel.text = UTILITIES.FormatNivel(sitio.nivel)
	nivelPrev.text = UTILITIES.FormatNiveles(sitio.nivelPrev)
	nivelCrit.text = UTILITIES.FormatNiveles(sitio.nivelCrit)
	
	nivelBg.self_modulate = ColorNorm
	StopAnimation()
	if sitio.nivel > sitio.nivelPrev: 
		nivelBg.self_modulate = ColorPrev
		PlayAnimation(ColorPrev,0.4)
	if sitio.nivel > sitio.nivelCrit: 
		nivelBg.self_modulate = ColorCrit
		PlayAnimation(ColorCrit,0.3)
	
	#Datos
	precipitacion.text = UTILITIES.FormatPptn_pluvial(sitio.pptn_pluvial)
	humedad.text = UTILITIES.FormatHumedad(sitio.humedad)
	evaporacion.text = UTILITIES.FormatEvaporacion(sitio.evaporacion)
	temp.text = UTILITIES.FormatTemperatura(sitio.temperatura)
	presion.text = UTILITIES.FormatPresion(sitio.presion)
	viento.text = UTILITIES.FormatIntensidadViento(sitio.intsdad_viento)#TODO sistema para que regrese N S E O
	lblBateria.text = UTILITIES.FormatBateriaV(sitio.volt_bat_resp)

func PlayAnimation(_color:Color,_speed:float):
	tween = create_tween().set_loops(0)
	tween.tween_property(nivelBg,"self_modulate",animColor,_speed)
	tween.tween_property(nivelBg,"self_modulate",_color,_speed)
	
func StopAnimation():
	if tween:
		if tween.is_running(): tween.kill()
