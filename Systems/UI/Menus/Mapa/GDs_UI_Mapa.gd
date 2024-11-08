class_name GDs_MenuMapa
extends Control

@export var barraMenus:GDs_BarraMenus
@export var popUp:GDs_PopUpVerSitio
@export var mapPoints:Array[GDs_MapPoint]

@export_group("Audios")
@export var clickSnd:AudioStreamPlayer
@export var focusSnd:AudioStreamPlayer

var currentSitio:=0#IDX del array
var sitioIdPressed:=-1

# Called when the node enters the scene tree for the first time.
func Initialize(_estaciones:Array[GDs_Data_Estacion], current:int):
	currentSitio = current
	visibility_changed.connect(OnVisibility)
	var idx = 0
	for point in mapPoints:
		#CONECTAR SENALES
		point.OnSitioPressed.connect(OnAnySitioPressed)
		point.focus_entered.connect(PlayFocusSound)
		
		#ASIGNAR NEIGHBOR
		point.focus_neighbor_left = barraMenus.BtnSitios.get_path()
		point.focus_neighbor_right = barraMenus.BtnDatos.get_path()
		
		
		if idx == currentSitio:
			point.Initialize(_estaciones[idx],true)
		else:
			point.Initialize(_estaciones[idx],false)
		idx += 1
	popUp.OnCancelarVerSitio.connect(GrabLastFocus)


func OnVisibility():
	if visible:
		mapPoints[currentSitio].grab_focus()

func OnAnySitioPressed(_estacion:GDs_Data_Estacion):
	if not _estacion.disponible:
		return
	
	#AUDIO
	if not APPSTATE.popUpOpened:
		clickSnd.play()
	
	sitioIdPressed = _estacion.id
	popUp.OpenPopUp(_estacion)

func GrabLastFocus():
	if visible:
		mapPoints[sitioIdPressed-1].grab_focus()
	
func PlayFocusSound():
	focusSnd.play()
