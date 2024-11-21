extends Control

@export var menuBtn: OptionButton
var dropdown: PopupMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menuBtn.get_popup().transparent_bg = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
