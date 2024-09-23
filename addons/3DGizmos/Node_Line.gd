@tool

## [color=yellow][b]TO USE THE 'CODE LIBRARY':[/b][/color] [br][b]Note: [/b][i]Get the Gizmo Node into a [br]'Variable Reference' then call: [br][br][color=green]  var name.[b]Set3DGizmOptions ( )
class_name GzmoLine extends Node3D

var test : bool
# VARIABLES  - - - - - - - - - -  - - - - - - - - - - 

## [color=green][b]Gizmo Visible:[/b][/color] [br]  Both: Editor/Game (On).[br]  Editor: Only.[br]  Game: Only.[br]  None: Editor/Game (Off).
@export_enum('Both','Editor','Game', 'None') var GizmoVisible : int = 0:
	set(value):
		GizmoVisible = value
		GizmoUpdate()

## [color=green][b]Gizmo Wireframe:[/b][/color] [br]  On: Enable Wireframe Mode. [br]  Off: Disable Wireframe Mode.
@export var GizmoWireframe : bool = false:
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


@export_group('LINE PROPERTIES')

## [color=green][b]Gizmo Size:[/b][/color] [br]     Change the 'Size of Thckness' of the line.
@export_range(0.01, 10) var Size : float = 1.0 :
	set (value):
		Size = value
		LineProperties()

## [color=green][b]Gizmo Length:[/b][/color] [br]     Change the 'Length distance' of the line.
@export var Length : float = 1.0 :
	set (value):
		Length = value
		LineProperties()
		
## [color=green][b]Gizmo Look At Using:[/b][/color] [br]     None: Diabled Position. [br]     Using Node3D: Object as the new position. [br]     Using Position: Vector3 as the new position.
@export_enum('None', 'Node3D', 'Position') var LookAtUsing : int = 0 :
	set (value) :
		LookAtUsing = value
		notify_property_list_changed()

## [color=green][b]Gizmo Look At Object:[/b][/color] [br][i] It will be the objectPos to LookAt dynamically.
@export var LookAtNode : Node3D

## [color=green][b]Gizmo Look At Position:[/b][/color] [br][i] It will be the new position to LookAt dynamically.
@export var LookAtPosition : Vector3

## [color=green][b]Gizmo Lookat in Editor Mode:[/b][/color] [br][i]It will enable the Look at danycally in Editor as Game Mode.
@export var LookAtInEditor : bool = true 

var DistanceAB : float


# UI - - - - - - - - - -  - - - - - - - - - - 

func _validate_property(property: Dictionary) -> void:
	if property.name in ['LookAtNode'] and LookAtUsing != 1:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name in ['LookAtPosition'] and LookAtUsing != 2:
		property.usage = PROPERTY_USAGE_NO_EDITOR


# METODOS   - - - - - - - - - -  - - - - - - - - - - 


# start
func _ready() -> void:
	if Engine.is_editor_hint():
		myMesh.mesh = preload('Msh_Line.obj')
		myMesh.set_surface_override_material(0, preload('Gizmo_Mat.tres'))
		myMesh.cast_shadow = 0
		myMesh.gi_mode = 0
	else :
		GameLifeTime (0, GizmoLifetime)
	GizmoUpdate ()
	LineProperties ()
	
# line properties
func LineProperties () :
	if LookAtUsing == 0 : 
		scale = Vector3(Size, Size, Length)

# REAL-TIME
func _process(delta: float) -> void:
	if Engine.is_editor_hint() :
		# EDITOR MODE
		if LookAtUsing == 1 :
			if !LookAtNode == null : 
				if LookAtInEditor :
					myMesh.look_at( LookAtNode.position, Vector3.UP, true )
					DistanceAB = position.distance_to(LookAtNode.position)
					scale = Vector3(Size, Size, DistanceAB)
		elif LookAtUsing == 2 :
			if LookAtInEditor :
				myMesh.look_at( LookAtPosition, Vector3.UP, true )
				DistanceAB = position.distance_to(LookAtPosition)
				scale = Vector3(Size, Size, DistanceAB)
		else : 
			LineProperties ()
	else :
		# GAME MODE
		if LookAtUsing == 1 :
			if !LookAtNode == null : 
				myMesh.look_at( LookAtNode.position, Vector3.UP, true )
				DistanceAB = position.distance_to(LookAtNode.position)
				scale = Vector3(Size, Size, DistanceAB)
		elif LookAtUsing == 2 :
			myMesh.look_at( LookAtPosition, Vector3.UP, true )
			DistanceAB = position.distance_to(LookAtPosition)
			scale = Vector3(Size, Size, DistanceAB)

# update
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


# LIBRARY BY CODE - - - - - - - - - -  - - - - - - - - - - 

# call
func Set3DGizmOptions ( Orign : Vector3, Target : Vector3, LifeTime : float = 0) :
	position = Orign
	
	LookAtUsing = 0 	#None
	myMesh.look_at( Target, Vector3.UP, true )
	DistanceAB = position.distance_to(Target)
	scale = Vector3(Size, Size, DistanceAB)
	
	if !visible :
		visible  = true
		process_mode = Node.PROCESS_MODE_ALWAYS
	GameLifeTime (LifeTime, 0)

# timer
func GameLifeTime (GameMode : float, EditorMode : float) :
	if GameMode > 0 :
		await get_tree().create_timer(GameMode).timeout
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
	elif EditorMode > 0: 
		await get_tree().create_timer(EditorMode).timeout
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
