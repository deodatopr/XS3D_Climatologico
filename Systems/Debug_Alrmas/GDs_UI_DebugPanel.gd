extends Control

@export var modoDatos: OptionButton
@export var datosRandom: CheckButton
@export var lblAuto:Control
@export var lblManual:Control
@export var intervalo: HSlider
@export var intervaloPerc: Label
@export var precipitacion: OptionButton
@export var temperatura: OptionButton
@export var alarma: OptionButton
@export var bateria: OptionButton
@export var conexion: OptionButton
var dropdown: PopupMenu

var allowSliderChange:bool


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
	
	datosRandom.toggled.connect(OnDatosAleatoriosChanged)
	
	intervalo.drag_ended.connect(OnDragEnded)
	intervalo.drag_started.connect(func c(): allowSliderChange = false)
	intervalo.value_changed.connect(OnIntervaloChanged)

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
	
	intervalo.value = DEBUG.timeToRefresh
	intervaloPerc.text = str(DEBUG.timeToRefresh) + "s"
	precipitacion.disabled = DEBUG.simuladoRandom
	temperatura.disabled = DEBUG.simuladoRandom
	alarma.disabled = DEBUG.simuladoRandom
	bateria.disabled = DEBUG.simuladoRandom
	conexion.disabled = DEBUG.simuladoRandom
	

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
		datosRandom.disabled = true
		lblAuto.self_modulate.a = 0.7
		lblManual.self_modulate.a = 0.7
		intervalo.editable = false
		SIGNALS.OnDatosSimuladosOFF.emit()
	else:
		DEBUG.modoDatos = ENUMS.ModoDatos.Simulado
		precipitacion.disabled = false
		temperatura.disabled = false
		alarma.disabled = false
		bateria.disabled = false
		conexion.disabled = false
		datosRandom.disabled = false
		lblAuto.self_modulate.a = 1.0
		lblManual.self_modulate.a = 1.0
		intervalo.editable = true
		SIGNALS.OnDatosSimuladosON.emit()
	SIGNALS.OnDebugRefresh.emit()

func OnDatosAleatoriosChanged(toggle:bool):
	DEBUG.simuladoRandom = toggle
	SIGNALS.OnDebugRefresh.emit()
	
	precipitacion.disabled = toggle
	temperatura.disabled = toggle
	alarma.disabled = toggle
	bateria.disabled = toggle
	conexion.disabled = toggle

func OnDragEnded(changed:bool):
	if not changed: return
	allowSliderChange = true
	intervaloPerc.text = str(intervalo.value) + "s"
	DEBUG.timeToRefresh = intervalo.value
	SIGNALS.OnDebugRefresh.emit()

func OnIntervaloChanged(value:float):
	if not allowSliderChange: return
	intervaloPerc.text = str(value) + "s"
	DEBUG.timeToRefresh = value
	SIGNALS.OnDebugRefresh.emit()

func OnPrecipitacionMouseEntered():
	modoDatos.release_focus()
	temperatura.release_focus()
	alarma.release_focus()
	bateria.release_focus()
	conexion.release_focus()
func OnPrecipitacionChanged(idx:int):
	#SIN LLUVIA
	if idx == 0:
		DEBUG.lLuvia = ENUMS.LluviaIntsdad.SinLluvia
	#CON LLUVIA
	else:
		DEBUG.lLuvia = ENUMS.LluviaIntsdad.ConLluvia
	SIGNALS.OnDebugRefresh.emit()


func OnTemperaturaMouseEntered():
	modoDatos.release_focus()
	precipitacion.release_focus()
	alarma.release_focus()
	bateria.release_focus()
	conexion.release_focus()
func OnTemperaturaChanged(idx:int):
	DEBUG.temperatura = idx
	SIGNALS.OnDebugRefresh.emit()
	

func OnAlarmaMouseEntered():
	modoDatos.release_focus()
	precipitacion.release_focus()
	temperatura.release_focus()
	bateria.release_focus()
	conexion.release_focus()
func OnAlarmaChanged(idx:int):
	DEBUG.alarmas = idx
	SIGNALS.OnDebugRefresh.emit()

func OnBateriaMouseEntered():
	modoDatos.release_focus()
	precipitacion.release_focus()
	temperatura.release_focus()
	alarma.release_focus()
	conexion.release_focus()
func OnBateriaChanged(idx:int):
	DEBUG.bateria = idx
	SIGNALS.OnDebugRefresh.emit()

func OnConexionMouseEntered():
	modoDatos.release_focus()
	precipitacion.release_focus()
	temperatura.release_focus()
	alarma.release_focus()
	bateria.release_focus()
func OnConexionChanged(idx:int):
	DEBUG.requestResult = idx
	SIGNALS.OnDebugRefresh.emit()
