extends Node
@export var anim:AnimationPlayer
@export var debugAnim:AnimationPlayer
@export var duration:float

# Called when the node enters the scene tree for the first time.
func _ready():
	SIGNALS.OnDatosSimuladosON.connect(PlayDebugAnim)
	SIGNALS.OnDatosSimuladosOFF.connect(StopDebugAnim)
	
	await get_tree().create_timer(duration).timeout
	anim.stop()	

func _input(event):
	if event.is_action_pressed("UI_Info"):
		anim.stop()

func PlayDebugAnim():
	debugAnim.play("DebugBlink")

func StopDebugAnim():
	debugAnim.stop()
