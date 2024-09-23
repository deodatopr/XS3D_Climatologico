@tool

## Node to use lights without no Limit on distance and get performance
class_name Light_Occluder extends Node3D

# VARIABLES  - - - - - - - - - -  - - - - - - - - - - 
const WarningMesh = preload('Warning_Mesh.gd')


@export_group("OBJECTS")

#Light
@export_enum('Custom','Spot','Omni') var LightType : int = 0:
	set(value):
		LightType = value
		ChangeLightType()
		notify_property_list_changed()

@export var myLight: Light3D

#Add Mesh
@export var addMesh:bool = false:
	set (value) :
			addMesh = value
			notify_property_list_changed()
			addaddMeshNode()
			
			
@export_group("SETTINGS")
#Extra Settings
@export var addDisableByDistance:bool = false:
	set (value) :
		addDisableByDistance = value
		notify_property_list_changed()
@export_range(0, 4096, 0.1, "suffix:m") var distFromCam : float = 5

@export_subgroup('Override Light')

#Light
@export var LIGHTING:bool = false:
	set (value) :
			LIGHTING = value
			notify_property_list_changed()
			OverrideLightValues()

## Distance which light will turn off
@export_range(0, 4096, 0.1, "suffix:m") var lightOcclude:float = 40.0:
	set (value) :
		lightOcclude = value
		OverrideLightValues()

## [b] This is the transition to occlude light.[/b] [color=green][br] (Transition = Light Occlude - Light Fade)[/color]
@export_range(0, 4096, 0.1, "suffix:m") var lightFade:float = 10.0:
	set (value) :
		lightFade = value
		OverrideLightValues()

#Mesh 
@export_subgroup('Override Mesh')
@export var MESH:bool = false:
	set (value) :
			MESH = value
			notify_property_list_changed()
			GetMesh()

@export var materialFade:bool = false:
	set (value) :
			materialFade = value
			notify_property_list_changed()
			OverrideMaterialValues()
			
@export_enum('Standard','Shader') var materialType : int = 0:
	set(value):
		materialType = value
		notify_property_list_changed()
		OverrideShaderValues()
		
## In your shader this is the parameter from 'DistanceFade Node' -> 'min parameter var'
@export var minDistanceFade : String

## In your shader this is the parameter from 'DistanceFade Node' -> 'max parameter var'
@export var maxDistanceFade : String

## Distance which the mesh will be turned off
@export_range(0, 4096, 0.1, "suffix:m") var occludeDistance : float = 40:
	set (value) :
		occludeDistance = value
		OverrideMaterialValues()
		OverrideShaderValues()
		
## [b] This is the transition to occlude mesh.[/b] [color=green][br] (Transition = Occlude Distance - Occlude Fade)[/color]
@export_range(0, 4096, 0.1, "suffix:m") var occludeFade : float = 10:
	set (value) :
		occludeFade = value
		OverrideMaterialValues()
		OverrideShaderValues()
		
		
var myMesh : Node3D
var RenderVol : VisibleOnScreenEnabler3D


		

# End
@export_category("")
@export var end:String = ""

#endregion


# FUNCTIONS  - - - - - - - - - -  - - - - - - - - - - 

func _process(delta):
	if not Engine.is_editor_hint() and addDisableByDistance:
		if get_viewport().get_camera_3d().global_position.distance_to(self.global_position) < distFromCam:
			#GetLightInTree()
			myLight.hide()
			myLight.process_mode = PROCESS_MODE_DISABLED
			
			if MESH:
				GetMesh()
				myMesh.hide()
				myMesh.process_mode =  PROCESS_MODE_DISABLED
		else:
			myLight.show()
			myLight.process_mode = PROCESS_MODE_INHERIT
			
			if MESH:
				myMesh.show()
				myMesh.process_mode =  PROCESS_MODE_INHERIT
	

# UI Show / Hide Elements
func _validate_property(property: Dictionary) -> void:
	#LIGHT
	if property.name in ["myLight"] and LightType != 0:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name in ["lightOcclude","lightFade"] and not LIGHTING:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name in ["distFromCam"] and not addDisableByDistance:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name in ["minDistanceFade", "maxDistanceFade"] and materialType == 0:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name in ["materialType","occludeFade","minDistanceFade", "maxDistanceFade"] and not materialFade:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		
	if property.name in ["materialFade","occludeDistance","materialType","occludeFade","minDistanceFade", "maxDistanceFade"] and not MESH:
		property.usage = PROPERTY_USAGE_NO_EDITOR
		

# Render Vol + Light
func _ready() -> void:
	if Engine.is_editor_hint():
		if not self.get_children(true).any(func(child:Node): return child is VisibleOnScreenEnabler3D):
			RenderVol = VisibleOnScreenEnabler3D.new()
			RenderVol.name = 'Render Volume'
			self.add_child(RenderVol)
			RenderVol.owner = get_tree().get_edited_scene_root()
			
			#
			if LightType == 0 :
				UseCustomLight()
	else:
		for child in get_children():
			if child is VisibleOnScreenEnabler3D:
				RenderVol = child
				break
		RenderVol.screen_entered.connect(OnScreenEntered)
		RenderVol.screen_exited.connect(OnScreenExited)

func AddSpotlightNode():
	if self.get_children(true).any(func(child:Node3D): return child.name != 'SpotLight3D'):
		myLight = SpotLight3D.new()
		myLight.name = 'SpotLight3D'
		
		self.add_child(myLight) 

		myLight.owner = get_tree().get_edited_scene_root()
		
	if self.get_children(true).any(func(child:Node3D): return child.name == 'OmniLight3D'):
		var myNode = find_child ('OmniLight3D')
		myNode.queue_free()

func AddOmniLightNode():
	if self.get_children(true).any(func(child:Node3D): return child.name != 'OmniLight3D'):
		myLight = OmniLight3D.new()
		myLight.name = 'OmniLight3D'
		
		self.add_child(myLight) 

		myLight.owner = get_tree().get_edited_scene_root()
	
	if self.get_children(true).any(func(child:Node3D): return child.name == 'SpotLight3D'):
		var myNode = find_child ('SpotLight3D')
		myNode.queue_free()

func UseCustomLight():
	if self.get_children(true).any(func(child:Node3D): return child.name == 'OmniLight3D'):
		var myNode = find_child ('OmniLight3D')
		myNode.queue_free()
	
	if self.get_children(true).any(func(child:Node3D): return child.name == 'SpotLight3D'):
		var myNode = find_child ('SpotLight3D')
		myNode.queue_free()

func ChangeLightType():
	if LightType == 0 : #CUSTOM
		UseCustomLight()
		OverrideLightValues()
	if LightType == 1 : #SPOT
		AddSpotlightNode()
		OverrideLightValues()
	elif LightType == 2 :#OMNILIGHT
		AddOmniLightNode()
		OverrideLightValues()






#region TOOL LOGIC
func GetLightInTree():
	if self.get_children(true).any(func(child:Node3D): return child.name == 'OmniLight3D'):
		myLight = find_child ('OmniLight3D')
	elif self.get_children(true).any(func(child:Node3D): return child.name == 'SpotLight3D'):
		myLight = find_child ('SpotLight3D')
	
func OverrideLightValues():
	if not Engine.is_editor_hint(): return
	if myLight == null: return
	myLight.distance_fade_enabled = LIGHTING
	
	if LIGHTING:
		myLight.distance_fade_begin = lightOcclude
		myLight.distance_fade_length = lightFade
	else:#Poner values por default
		myLight.distance_fade_enabled = LIGHTING
		myLight.distance_fade_begin = 40
		myLight.distance_fade_length = 10

#MESH
func addaddMeshNode () :
	if Engine.is_editor_hint():
		if addMesh :
			if self.get_children(true).any(func(child:Node3D): return child.name != 'Add Mesh'):
				myMesh = Node3D.new()
				myMesh.name = 'Add Mesh'
				
				self.add_child(myMesh) 	
				myMesh.set_script(WarningMesh)

				myMesh.owner = get_tree().get_edited_scene_root()
		else :
			if self.get_children(true).any(func(child:Node3D): return child.name == 'Add Mesh'):
				var myNode = find_child ('Add Mesh')
				myNode.queue_free()

func GetMesh():
	if MESH:
		if self.get_children(true).any(func(child:Node3D): return child.name == 'Add Mesh'):
			myMesh = find_child ('Add Mesh')
		else: return
		if myMesh.get_child_count() == 0:
			print_rich("[color=yellow] No mesh parented found [/color]")
		else:
			var meshParented = myMesh.get_child(0)
			if meshParented:
				meshParented.visibility_range_end = occludeDistance
	else:
		if self.get_children(true).any(func(child:Node3D): return child.name == 'Add Mesh'):
			myMesh = find_child ('Add Mesh')
		else: return
		if myMesh.get_child_count() > 0:
			var meshParented = myMesh.get_child(0)
			if meshParented:
				meshParented.visibility_range_end = 0
				
func OverrideMaterialValues():
	GetMesh()
	if myMesh.get_child(0).get_active_material(0) is ShaderMaterial: return
	var meshMat = myMesh.get_child(0).get_active_material(0) as StandardMaterial3D
	if materialFade:
		meshMat.distance_fade_mode = 3
		meshMat.distance_fade_min_distance = occludeDistance
		meshMat.distance_fade_max_distance = (occludeDistance - occludeFade)
	else:
		meshMat.distance_fade_mode = 0
		meshMat.distance_fade_min_distance = 0
		meshMat.distance_fade_max_distance = 0

func OverrideShaderValues():
	GetMesh()
	if materialType == 1:
		if myMesh.get_child(0).get_active_material(0) is StandardMaterial3D: return
		var meshMat = myMesh.get_child(0).get_active_material(0) as ShaderMaterial
		
		if minDistanceFade == "":
			print_rich("[color=yellow] Min distance fade is empty [/color]")
		else:
			meshMat.set_shader_parameter(minDistanceFade, occludeDistance)
			
		if maxDistanceFade == "":
			print_rich("[color=yellow] Max distance fade is empty [/color]")
		else:
			meshMat.set_shader_parameter(maxDistanceFade, (occludeDistance - occludeFade))
#endregion

func OnScreenEntered():
	myLight.show()

func OnScreenExited():
	myLight.hide()
