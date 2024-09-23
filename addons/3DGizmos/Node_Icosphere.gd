@tool

## [color=yellow][b]TO USE THE 'CODE LIBRARY':[/b][/color] [br][b]Note: [/b][i]Get the Gizmo Node into a [br]'Variable Reference' then call: [br][br][color=green]  var name.[b]Set3DGizmOptions ( )
class_name GzmoIcoSphere extends Node3D


# VARIABLES  - - - - - - - - - -  - - - - - - - - - - 

## [color=green][b]Gizmo Visible:[/b][/color] [br]  Both: Editor/Game (On).[br]  Editor: Only.[br]  Game: Only.[br]  None: Editor/Game (Off).
@export_enum('Both','Editor','Game', 'None') var GizmoVisible : int = 0:
	set(value):
		GizmoVisible = value
		GizmoUpdate()

## [color=green][b]Gizmo Wireframe:[/b][/color] [br]  On: Enable Wireframe Mode. [br]  Off: Disable Wireframe Mode.
@export var GizmoWireframe : bool = true:
	set(value):
		GizmoWireframe = value
		GizmoUpdate()		

## [color=green][b]Gizmo Base Color:[/b][/color] [br]Change the 'Solid and Wireframe' Color.
@export var GizmoBaseColor : Color = Color.WHITE:
	set(value):
		GizmoBaseColor = value
		GizmoUpdate()

## [color=green][b]Gizmo Life Time:[/b][/color] [br]     0 = Always Visible.[br]     By Code: This value will be overriden if is changed by code.
@export var GizmoLifetime : float = 0

@onready var myMesh : MeshInstance3D = $'.'
@onready var myMat : Material
var myApplyMat : bool = false


# METODOS   - - - - - - - - - -  - - - - - - - - - - 

# START
func _ready() -> void:
	if Engine.is_editor_hint():
		myMesh.mesh = preload('Msh_IcoSphere.obj')
		myMesh.set_surface_override_material(0, preload('Gizmo_Mat.tres'))
		myMesh.cast_shadow = 0
		myMesh.gi_mode = 0
	else :
		GameLifeTime (0, GizmoLifetime)
	GizmoUpdate ()

#UPDATE
func GizmoUpdate () -> void:
	# VISIBLE
	if !myMesh == null:
		if GizmoVisible == 0 :	# Both
			myMesh.process_mode = Node.PROCESS_MODE_INHERIT
			myMesh.visible = true
		elif GizmoVisible == 1 :	# Editor Mode
			if Engine.is_editor_hint():
				myMesh.process_mode = Node.PROCESS_MODE_INHERIT
				myMesh.visible = true
			else :
				myMesh.process_mode = Node.PROCESS_MODE_DISABLED
				myMesh.visible = false
		elif GizmoVisible == 2 :	# Game Mode
			if !Engine.is_editor_hint():
				myMesh.process_mode = Node.PROCESS_MODE_INHERIT
				myMesh.visible = true
			else :
				myMesh.process_mode = Node.PROCESS_MODE_DISABLED
				myMesh.visible = false
		elif GizmoVisible == 3 :	# None Mode
			myMesh.process_mode = Node.PROCESS_MODE_DISABLED
			myMesh.visible = false

		#SHADER PARAMETERS
		if !myApplyMat :
			myMat = myMesh.get_active_material(0).duplicate()
			myMesh.set_surface_override_material(0, myMat)
			myApplyMat = true
		myMat.set_shader_parameter( "basecolor", GizmoBaseColor )
		myMat.set_shader_parameter("Wireframe", GizmoWireframe)

# LIBRARY BY CODE
func Set3DGizmOptions ( Orign : Vector3, Rotate : Vector3, Size : Vector3, LifeTime : float = 0) :
	position = Orign
	rotation_degrees = Rotate
	scale = Size
	if !visible :
		visible  = true
		process_mode = Node.PROCESS_MODE_ALWAYS
	GameLifeTime (LifeTime, 0)

# TIMER
func GameLifeTime (GameMode : float, EditorMode : float) :
	if GameMode > 0 :
		await get_tree().create_timer(GameMode).timeout
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
	elif EditorMode > 0: 
		await get_tree().create_timer(EditorMode).timeout
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
