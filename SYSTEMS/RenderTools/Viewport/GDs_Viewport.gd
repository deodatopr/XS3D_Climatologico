class_name GDs_Viewport extends Node

# Render Scale
@onready var myViewport = $'.'

#Fps
@export var FPS_Realtime : Label
@export var FPS_limited : Label

# Resolutions
@export var resolutionOS: Label
@export var resolutionViewport: Label
@export var renderScale: Label
@export var DrawCalls: Label
@export var PolyCount: Label

@export var toggleStats : bool

var draw_calls : int
var poly_count : int

func _ready() -> void:
	FPS_limited.text = str(ProjectSettings.get_setting("application/run/max_fps"))					# Show Limited FPS
	resolutionOS.text = str( get_viewport().size.x, " x ", get_viewport().size.y, ' px' )			# Show Resolution OS
	resolutionViewport.text = str( myViewport.size.x, " x ", myViewport.size.y, ' px' )				# Show Resolution Viewport
	renderScale.text = str(ProjectSettings.get_setting("rendering/scaling_3d/scale")*100, ' %')		# Show RenderScaleAndroid

func _process(_delta) -> void:
	FPS_Realtime.text = str( Engine.get_frames_per_second() )	# Show Realtime FPS
	
	draw_calls = get_viewport().get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME)
	poly_count = get_viewport().get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_PRIMITIVES_IN_FRAME)
	DrawCalls.text = str( draw_calls )	# Draw Calls
	PolyCount.text = str(poly_count )	# Poly Count
	#print("Draw Calls: ", draw_calls, ' | Polycount: ', poly_count)
