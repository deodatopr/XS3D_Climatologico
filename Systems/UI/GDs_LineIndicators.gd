extends Control
@export var vertical:= false
##If false it will use the Y axis
@export var useXaxis:=true
##If false it will use the cam position instead
@export var useCamRotation:=false
@export var width:=0

var initialPosX:float
var initialPosY:float
# Called when the node enters the scene tree for the first time.
func _ready():
	initialPosX = position.x
	initialPosY = position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if vertical:
		if useCamRotation:
			if useXaxis:
				position.y = initialPosY + (int(CAM.rotation.x*3) % width)
			else:
				position.y = initialPosY + (int(CAM.rotation.y*3) % width)
		else:
			position.y = initialPosY + (int(CAM.position.z) % width)
	else:
		if useCamRotation:
			position.x = initialPosX + (int(CAM.rotation.y*3) % width)
		else:
			#FIXME cambiar por inputs en lugar dee position
			position.x = initialPosX + (int(CAM.position.x) % width)
	