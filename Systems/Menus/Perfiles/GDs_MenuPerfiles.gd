class_name  GDs_MenuPerfiles
extends Control

@export_group("Refs Externas")
@export var barraMenu:GDs_BarraMenus
@export var popUp:GDs_PopUpVerSitio
@export_group("Refs Internas")
@export var sitios: Array[GDs_Perf_Sitio]

var lastOneFocused:= 0
# Called when the node enters the scene tree for the first time.
func _ready():
	visibility_changed.connect(OnShowHide)
	popUp.OnCancelarVerSitio.connect(CancelarVerSitio)
	InitializeSitios()

func _input(event):
	if visible:
		if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
			GetCurrentFocus()

func DataRefresh(_estaciones : Array[GDs_Data_Estacion]):
	var idx=0
	for sitio in sitios:
		sitio.DataRefresh(_estaciones[idx])
		idx += 1

func OnShowHide():
	if visible:
		sitios[lastOneFocused].button.grab_focus()

func InitializeSitios():
	#Conectar vecinos superior e inferior
	sitios[0].button.focus_neighbor_top = sitios[7].button.get_path()
	sitios[7].button.focus_neighbor_bottom = sitios[0].button.get_path()
	
	for sitio in sitios:
		#Conectar vecinos
		sitio.button.focus_neighbor_left = barraMenu.BtnConfig.get_path()
		sitio.button.focus_neighbor_right = barraMenu.BtnMapa.get_path()
		#Conectar senales
		sitio.OnSitioPressed.connect(OnAnySitioPressed)
		popUp.OnCancelarVerSitio.connect(sitio.OnPopUpCancelar)

func GetCurrentFocus():
	var idx = 0
	for sitio in sitios:
		if sitio.button.has_focus():
			lastOneFocused = idx
		idx+=1

func OnAnySitioPressed():
	GetCurrentFocus()
	sitios[lastOneFocused].button.release_focus()
	popUp.show()
	

func CancelarVerSitio():
	sitios[lastOneFocused].button.grab_focus()
