extends ColorRect

@export var root:Control
@export var masterVol:HSlider

func _input(event):
	if event.is_action_pressed("MasterVol-"):
		if not root.visible:
			masterVol.value = masterVol.value - 0.05
	if event.is_action_pressed("MasterVol+"):
		if not root.visible:
			masterVol.value = masterVol.value + 0.05
