extends Control

@export var btn:Button
@export var lbl:Label
@export var current:Control
@export var animSquare:Control
@export var bg:Control
@export var bgLabel:Control
@export var bgLabelWidth:float

var tween:Tween
var squareScale:Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	btn.mouse_entered.connect(btn.grab_focus)
	
	btn.focus_entered.connect(OnFocus)
	btn.focus_exited.connect(OnFocusExited)
	
	current.hide()
	
	bgLabel.size = Vector2(0,bgLabel.size.y)
	animSquare.rotation_degrees = 0
	animSquare.scale = Vector2(0.35,0.35)
	squareScale = animSquare.scale
	lbl.visible_ratio = 0
	bg.show()


func OnFocus():
	tween = create_tween()
	bg.hide()
	tween.tween_property(animSquare,"scale",Vector2.ONE,0.2)
	tween.parallel().tween_property(animSquare,"rotation_degrees",225,0.2)
	tween.parallel().tween_property(lbl,"visible_ratio",1,0.2)
	tween.parallel().tween_property(bgLabel,"size",Vector2(bgLabelWidth,bgLabel.size.y),0.2)
	await  tween.finished
	bg.hide()

func OnFocusExited():
	tween = create_tween()
	tween.tween_property(lbl,"visible_ratio",0,0.2)
	tween.parallel().tween_property(animSquare,"scale",squareScale,0.2)
	tween.parallel().tween_property(animSquare,"rotation_degrees",0,0.2)
	tween.parallel().tween_property(bgLabel,"size",Vector2(0,bgLabel.size.y),0.2)
	await  tween.finished
	bg.show()
