@tool
class_name MshCmbnr extends MeshInstance3D 


@export_range(0,20) var layerToIgnore:int = 0
@export var deleteOriginalMshsOnPlay: bool

var result_mesh:ArrayMesh
var result_mesh_material:Material
var selectedObject:Array[Node]
var combinedMesh: MeshInstance3D
var cleanedMaterials:Array[Material]
var allSurfaces:Array[ArrayMesh]
var editorInterface

var btnCombine:Button
var btnClear:Button

func _get_configuration_warnings() -> PackedStringArray:
	if get_child_count() == 0:
		return ['This node has no child meshes to combine']
	return []

func _ready():
	if not Engine.is_editor_hint() and deleteOriginalMshsOnPlay:
		for child in get_all_children(self):
			if child is MshCmbnr: continue
			if child is MeshInstance3D:
				if layerToIgnore != 0:
					if child.get_layer_mask_value(layerToIgnore):continue
					else: child.queue_free()
				else:
					child.queue_free()



#-------------LOGIC------------------


func _on_btn_combine_pressed():
	combinedMesh = self
	if selectedObject.size() > 1:
		print_debug("ERROR: NO PUEDES TENER SELECCIONADO MAS DE UN OBJETO")
	else:
		if not selectedObject: print("No Objects Selected")
		#print_debug(get_all_children(combinedMesh))
		CombineMeshes(get_all_children(combinedMesh))
		set_toggle_children_visibility(false) # apaga los hijos, los meshes que se combinaron, y tambien el padre
		combinedMesh.show()
		combinedMesh.mesh = result_mesh #asigna el mesh creado al mesh instance padre

func set_toggle_children_visibility(value):
	for node in get_all_children(combinedMesh):
		if node is MeshInstance3D:
			node.visible = value

func OnBtnCleanPressed():
	#if collision_parent_path:
		#collision_parent = get_node(collision_parent_path)
	#clean_collisions()
	combinedMesh = self
	if selectedObject.size() > 1:
		print_debug("ERROR: NO PUEDES TENER SELECCIONADO MAS DE UN OBJETO")
	else:
		combinedMesh.mesh = null
		set_toggle_children_visibility(true)
		selectedObject.clear()
		cleanedMaterials.clear()
		allSurfaces.clear()
		result_mesh = ArrayMesh.new()

func CombineMeshes(selectedNodes: Array[Node3D]):
	#Solo se ejecuta en el editor
	if !Engine.is_editor_hint():
		return
	# Si ya existe un mesh, lo limpia para generar uno nuevo
	if result_mesh:
		result_mesh.clear_surfaces()
		
	var _surface_tool := SurfaceTool.new()
	result_mesh = ArrayMesh.new()
	
	#Obtiene todos los materiales, los limpia y junta en un array para que no haya materiales repetidos
	GetAllMaterials(selectedNodes)
	#Obtiene todos los surfaces de todos los meshes y los agrega a un array (Si un mesh tiene 2 materiales, es decir, dos surfaces, cada surface seria un elemento diferente en el array)
	GetAllSurfaces(selectedNodes)
	
	var materialIdx = 0
	
	#obtenemos todos los surfaces del array que compartan un mismo material y se junta en un solo surface
	for material in cleanedMaterials:
		#Devuelve una array filtrado con los surfaces que compartan el material[idx]
		var ArraySurfacesSameMaterial :Array[ArrayMesh]
		ArraySurfacesSameMaterial = allSurfaces.filter(func(_surface:ArrayMesh): return _surface.surface_get_material(0) == cleanedMaterials[materialIdx])
		
		#Combina el array filtrado en un solo ArrayMesh, pero crea varios surfaces en lugar de uno solo 
		#Ej: si el array tiene 5 elementos, el arraymesh va a tener 5 surfaces que usan el mismo material
		var arrayMeshSameMaterial = ArrayMesh.new()
		for surface in ArraySurfacesSameMaterial:
			arrayMeshSameMaterial.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,surface.surface_get_arrays(0))
		
		#Pasa el ArrayMesh a un meshinstance3D para despues combinarlo con SurfaceTool
		#PD: El Surfacetool solo puede combinar Meshes, no Arraymesh
		var tempMesh = MeshInstance3D.new()
		tempMesh.mesh = arrayMeshSameMaterial
		
		#Pasa la informacion de los surfaces del Arraymesh al SurfaceTool para combinarlos en un solo surface
		#PD:Se tiene que limpiar el SurfaceTool por que si no en cada iteracion el surface va a acumular la informacion de los surfaces de
			#las iteraciones pasadas y no queremos eso
		_surface_tool.clear()
		for surface in tempMesh.get_surface_override_material_count():
			_surface_tool.append_from(tempMesh.mesh,surface,tempMesh.transform)
		
		
		result_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,_surface_tool.commit_to_arrays())
		result_mesh.surface_set_material(materialIdx,material)
		materialIdx +=1

func GetAllMaterials(_selectedObjects: Array):
	for node in _selectedObjects: #Iteracion por nodo
		for childMesh in node.get_children(): #Iteracion por mesh
			if childMesh is MeshInstance3D:
				if layerToIgnore != 0:
					if childMesh.get_layer_mask_value(layerToIgnore): continue
					else:
						for surface in childMesh.get_surface_override_material_count():#Iteracion por Surfaces (Material)
							if cleanedMaterials.find(childMesh.get_active_material(surface)) == -1:
								cleanedMaterials.append(childMesh.get_active_material(surface))
				else:
					for surface in childMesh.get_surface_override_material_count():#Iteracion por Surfaces (Material)
						if cleanedMaterials.find(childMesh.get_active_material(surface)) == -1:
							cleanedMaterials.append(childMesh.get_active_material(surface))

func GetAllSurfaces(_selectedObjects: Array):
	#Agregar todos los meshes en un solo array
	var _surface_tool = SurfaceTool.new()
	var surfaceIdx = 0
	for node in _selectedObjects:#Iteracion por nodo
		for childMesh in node.get_children():#Iteracion por mesh
			if childMesh is MeshInstance3D:
				if layerToIgnore != 0:
					if childMesh.get_layer_mask_value(layerToIgnore):continue
					else:
						for surface in childMesh.get_surface_override_material_count():#Iteracion por Surfaces (Material)
							_surface_tool.clear()
							var auxSurface = ArrayMesh.new()
							_surface_tool.append_from(childMesh.mesh, surface, childMesh.global_transform) #Pasa la informacion del surface al SurfaceTool
							auxSurface.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,_surface_tool.commit_to_arrays())
							auxSurface.surface_set_material(0,childMesh.get_active_material(surfaceIdx))
							allSurfaces.append(auxSurface)
							surfaceIdx += 1
				else:
					for surface in childMesh.get_surface_override_material_count():#Iteracion por Surfaces (Material)
						_surface_tool.clear()
						var auxSurface = ArrayMesh.new()
						_surface_tool.append_from(childMesh.mesh, surface, childMesh.global_transform) #Pasa la informacion del surface al SurfaceTool
						auxSurface.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,_surface_tool.commit_to_arrays())
						auxSurface.surface_set_material(0,childMesh.get_active_material(surfaceIdx))
						allSurfaces.append(auxSurface)
						surfaceIdx += 1
				surfaceIdx=0

func get_all_children(in_node,children:Array[Node3D]=[]):
	children.push_back(in_node)
	for child in in_node.get_children():
		children = get_all_children(child,children)
		child.name
	return children
