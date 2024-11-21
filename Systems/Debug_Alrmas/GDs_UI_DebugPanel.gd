extends Control

@export var modoDatos: OptionButton
@export var precipitacion: OptionButton
@export var temperatura: OptionButton
@export var alarma: OptionButton
@export var bateria: OptionButton
@export var conexion: OptionButton
var dropdown: PopupMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	visibility_changed.connect(func v():if visible: modoDatos.grab_focus())
	
	modoDatos.get_popup().transparent_bg = true
	precipitacion.get_popup().transparent_bg = true
	temperatura.get_popup().transparent_bg = true
	alarma.get_popup().transparent_bg = true
	bateria.get_popup().transparent_bg = true
	conexion.get_popup().transparent_bg = true
	
	modoDatos.mouse_entered.connect(OnModoDatosMouseEntered)
	modoDatos.item_selected.connect(OnModoDatosChanged)
	

	precipitacion.mouse_entered.connect(OnPrecipitacionMouseEntered)
	precipitacion.item_selected.connect(OnPrecipitacionChanged)
	
	temperatura.mouse_entered.connect(OnTemperaturaMouseEntered)
	temperatura.item_selected.connect(OnTemperaturaChanged)
	
	alarma.mouse_entered.connect(OnAlarmaMouseEntered)
	alarma.item_selected.connect(OnAlarmaChanged)
	
	bateria.mouse_entered.connect(OnBateriaMouseEntered)
	bateria.item_selected.connect(OnBateriaChanged)
	
	conexion.mouse_entered.connect(OnConexionMouseEntered)
	conexion.item_selected.connect(OnConexionChanged)

func OnModoDatosMouseEntered():
	precipitacion.release_focus()
	temperatura.release_focus()
	alarma.release_focus()
	bateria.release_focus()
	conexion.release_focus()
func OnModoDatosChanged(idx:int):
	#Servidor
	if idx == 1:
		DEBUG.modoDatos = ENUMS.ModoDatos.Endpoint
		precipitacion.disabled = true
		temperatura.disabled = true
		alarma.disabled = true
		bateria.disabled = true
		conexion.disabled = true
	else:
		DEBUG.modoDatos = ENUMS.ModoDatos.Simulado
		precipitacion.disabled = false
		temperatura.disabled = false
		alarma.disabled = false
		bateria.disabled = false
		conexion.disabled = false
	SIGNALS.OnDebugRefresh.emit()

func OnPrecipitacionMouseEntered():
	modoDatos.release_focus()
	temperatura.release_focus()
	alarma.release_focus()
	bateria.release_focus()
	conexion.release_focus()
func OnPrecipitacionChanged(idx:int):
	#SIN LLUVIA
	if idx == 1:
		print_debug("asd")
		DEBUG.lLuvia = ENUMS.LluviaIntsdad.SinLluvia
	#CON LLUVIA
	else:
		print_debug("asdasdasd")
		DEBUG.lLuvia = ENUMS.LluviaIntsdad.ConLluvia
	SIGNALS.OnDebugRefresh.emit()


func OnTemperaturaMouseEntered():
	modoDatos.release_focus()
	precipitacion.release_focus()
	alarma.release_focus()
	bateria.release_focus()
	conexion.release_focus()
func OnTemperaturaChanged(idx:int):
	DEBUG.temperatura = idx - 1
	SIGNALS.OnDebugRefresh.emit()
	

func OnAlarmaMouseEntered():
	modoDatos.release_focus()
	precipitacion.release_focus()
	temperatura.release_focus()
	bateria.release_focus()
	conexion.release_focus()
func OnAlarmaChanged(idx:int):
	DEBUG.alarmas = idx - 1
	SIGNALS.OnDebugRefresh.emit()

func OnBateriaMouseEntered():
	modoDatos.release_focus()
	precipitacion.release_focus()
	temperatura.release_focus()
	alarma.release_focus()
	conexion.release_focus()
func OnBateriaChanged(idx:int):
	DEBUG.bateria = idx - 1
	SIGNALS.OnDebugRefresh.emit()

func OnConexionMouseEntered():
	modoDatos.release_focus()
	precipitacion.release_focus()
	temperatura.release_focus()
	alarma.release_focus()
	bateria.release_focus()
func OnConexionChanged(idx:int):
	DEBUG.requestResult = idx - 1
	SIGNALS.OnDebugRefresh.emit()
