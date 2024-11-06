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
@export_subgroup("Datos")
@export var precipitacion:Label
@export var humedad:Label
@export var evaporacion:Label
@export var temp:Label
@export var presion:Label
@export var viento:Label


func OnDataRefresh(_estacion:GDs_Data_Estacion):
	id.text = str(_estacion.id)
	idframe.self_modulate = _estacion.color
	nombre.text = _estacion.nombre
	estado.text = UTILITIES.FormatEstado(_estacion.estado)
	
	#TODO: fecha de actualizacion
	
	#Senales
	if _estacion.enlace:
		senal.self_modulate = OnColor
	else:
		senal.self_modulate = OffColor
	if _estacion.disp_utr:
		UTR.self_modulate = OnColor
	else:
		UTR.self_modulate = OffColor
	
	#nivel
	nivel.text = UTILITIES.FormatNivel(_estacion.nivel)
	nivelPrev.text = UTILITIES.FormatNivel(_estacion.nivelPrev)
	nivelCrit.text = UTILITIES.FormatNivel(_estacion.nivelCrit)
	
	nivelBg.self_modulate = ColorNorm
	if _estacion.nivel > _estacion.nivelPrev: nivelBg.self_modulate = ColorPrev
	if _estacion.nivel > _estacion.nivelCrit: nivelBg.self_modulate = ColorCrit
	
	#Datos
	precipitacion.text = UTILITIES.FormatPptn_pluvial(_estacion.pptn_pluvial)
	humedad.text = UTILITIES.FormatHumedad(_estacion.humedad)
	evaporacion.text = UTILITIES.FormatEvaporacion(_estacion.evaporacion)
	temp.text = UTILITIES.FormatTemperatura(_estacion.temperatura)
	presion.text = UTILITIES.FormatPresion(_estacion.temperatura)#TODO cambiar por presion
	viento.text = UTILITIES.FormatIntensidadViento(_estacion.intsdad_viento)#TODO sistema para que regrese N S E O
	
	pass
