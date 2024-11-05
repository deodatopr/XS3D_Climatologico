extends ColorRect

@export var barraMenus: GDs_BarraMenus

@export var masterVol:HSlider
@export var effectsVol:HSlider
@export var musicVol:HSlider

@export var btnMaster:Button
@export var btnSfx:Button
@export var btnMusic:Button

@export var focusMaster:Control
@export var focusSfx:Control
@export var focusMusic:Control

# Called when the node enters the scene tree for the first time.
func _ready():
	visibility_changed.connect(OnVisibility)
	btnMaster.focus_entered.connect(OnMasterVolumeFocus)
	btnSfx.focus_entered.connect(OnSfxVolumeFocus)
	btnMusic.focus_entered.connect(OnMusicVolumeFocus)
	
	btnMaster.focus_neighbor_left = barraMenus.BtnDatos.get_path()
	btnMaster.focus_neighbor_right = barraMenus.BtnSitios.get_path()
	btnSfx.focus_neighbor_left = barraMenus.BtnDatos.get_path()
	btnSfx.focus_neighbor_right = barraMenus.BtnSitios.get_path()
	btnMusic.focus_neighbor_left = barraMenus.BtnDatos.get_path()
	btnMusic.focus_neighbor_right = barraMenus.BtnSitios.get_path()

func _input(event):
	if event.is_action_pressed("MasterVol+"):
		if focusMaster.visible:
			masterVol.value = masterVol.value + 0.05
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(masterVol.value))
			
		if focusSfx.visible:
			effectsVol.value = effectsVol.value + 0.05
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(effectsVol.value))
		if focusMusic.visible:
			musicVol.value = musicVol.value + 0.05
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(musicVol.value))
	if event.is_action_pressed("MasterVol-"):
		if focusMaster.visible:
			masterVol.value = masterVol.value - 0.05
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(masterVol.value))
		if focusSfx.visible:
			effectsVol.value = effectsVol.value - 0.05
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(effectsVol.value))
		if focusMusic.visible:
			musicVol.value = musicVol.value - 0.05
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(musicVol.value))
func OnVisibility():
	if visible:
		btnMaster.grab_focus()

func OnMasterVolumeFocus():
	focusMaster.show()
	focusSfx.hide()
	focusMusic.hide()

func OnSfxVolumeFocus():
	focusMaster.hide()
	focusSfx.show()
	focusMusic.hide()

func OnMusicVolumeFocus():
	focusMaster.hide()
	focusSfx.hide()
	focusMusic.show()
