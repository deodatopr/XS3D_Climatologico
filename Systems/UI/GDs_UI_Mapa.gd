extends ColorRect

@export var testBtn:Button

# Called when the node enters the scene tree for the first time.
func _ready():
	visibility_changed.connect(OnVisibility)


func OnVisibility():
	if visible:
		testBtn.grab_focus()
