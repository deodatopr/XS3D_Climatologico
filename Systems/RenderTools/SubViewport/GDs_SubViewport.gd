extends Node


#Fps
@export var limit_fps : int = 20
@export var txt_fps_limited : Label  	# Fps_Limited
@export var txt_fps_realtime : Label 	# Fps_RealTime


#Render Scale
@export var sld_scale: HSlider 			# Sld - Scale
@export var txt_scale: Label 			# Txt - Scale


#Render
@export var txt_resolution: Label		# Txt - Resolution
@export var txt_viewport: Label			# Txt - Viewport'

#Viewport
@export var sub_viewport: SubViewport	# Sub Viewport

func _ready() -> void:
	Engine.max_fps = limit_fps
	txt_fps_limited.text = str(limit_fps)
	sub_viewport.scaling_3d_scale = sld_scale.value
	txt_scale.text = str( sld_scale.value )


func _process(_delta: float) -> void:
	txt_fps_realtime.text = str( Engine.get_frames_per_second() )
	txt_resolution.text = str( get_viewport().size )
	txt_viewport.text = str( sub_viewport.size )


func _on_sld__scale_value_changed(value: float) -> void:
	sub_viewport.scaling_3d_scale = sld_scale.value
	txt_scale.text = str( sld_scale.value )
