extends Control

@export_group("External Refs")
@export var barraMenus: GDs_BarraMenus

@export_group("Master")
@export var masterVol:HSlider
@export var masterBtn:Button
@export var MasterOnFocus:Control
@export var MasterPercentage:Label

@export_group("Music")
@export var musicVol:HSlider
@export var musicBtn:Button
@export var MusicOnFocus:Control
@export var MusicPercentage:Label

@export_group("SFX")
@export var sfxVol:HSlider
@export var SFXBtn:Button
@export var SFXOnFocus:Control
@export var SFXPercentage:Label

# Called when the node enters the scene tree for the first time.
func _ready():
	visibility_changed.connect(OnVisibility)
	masterBtn.focus_entered.connect(OnMasterVolumeFocus)
	SFXBtn.focus_entered.connect(OnSfxVolumeFocus)
	musicBtn.focus_entered.connect(OnMusicVolumeFocus)
	
	masterBtn.focus_neighbor_left = barraMenus.BtnDatos.get_path()
	masterBtn.focus_neighbor_right = barraMenus.BtnSitios.get_path()
	SFXBtn.focus_neighbor_left = barraMenus.BtnDatos.get_path()
	SFXBtn.focus_neighbor_right = barraMenus.BtnSitios.get_path()
	musicBtn.focus_neighbor_left = barraMenus.BtnDatos.get_path()
	musicBtn.focus_neighbor_right = barraMenus.BtnSitios.get_path()
	
	masterVol.value_changed.connect(MasterVolChanged)
	sfxVol.value_changed.connect(SFXVolChanged)
	musicVol.value_changed.connect(MusicVolChanged)
	
	
	masterVol.value = AUDIO.MasterVolume
	sfxVol.value = AUDIO.SFXVolume
	musicVol.value = AUDIO.MusicVolume

func _input(event):
	if event.is_action_pressed("MasterVol+"):
		if MasterOnFocus.visible:
			masterVol.value = masterVol.value + 0.05
		if SFXOnFocus.visible:
			sfxVol.value = sfxVol.value + 0.05
		if MusicOnFocus.visible:
			musicVol.value = musicVol.value + 0.05
		if not visible:
			masterVol.value = masterVol.value + 0.05
			
	if event.is_action_pressed("MasterVol-"):
		if MasterOnFocus.visible:
			masterVol.value = masterVol.value - 0.05
		if SFXOnFocus.visible:
			sfxVol.value = sfxVol.value - 0.05
		if MusicOnFocus.visible:
			musicVol.value = musicVol.value - 0.05
		if not visible:
			masterVol.value = masterVol.value - 0.05
func OnVisibility():
	if visible:
		masterBtn.grab_focus()

func OnMasterVolumeFocus():
	MasterOnFocus.show()
	SFXOnFocus.hide()
	MusicOnFocus.hide()

func OnSfxVolumeFocus():
	MasterOnFocus.hide()
	SFXOnFocus.show()
	MusicOnFocus.hide()

func OnMusicVolumeFocus():
	MasterOnFocus.hide()
	SFXOnFocus.hide()
	MusicOnFocus.show()

func MasterVolChanged(_value:float):
	AUDIO.MasterVolume = _value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(_value))
	MasterPercentage.text = str(_value * 100) + "%"

func SFXVolChanged(_value:float):
	AUDIO.SFXVolume = _value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(_value))
	SFXPercentage.text = str(_value * 100) + "%"
	
func MusicVolChanged(_value:float):
	AUDIO.MusicVolume = _value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(_value))
	MusicPercentage.text = str(_value * 100) + "%"
