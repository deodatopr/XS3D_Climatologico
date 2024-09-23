extends Control

@export var dragX : bool = true
@export var dragY : bool = true

func _ready():
	gui_input.connect(_on_gui_input)

func _on_gui_input(event):
	if event is InputEventScreenDrag :
		if dragX:
			position.x += event.relative.x
		if dragY:
			position.y += event.relative.y
