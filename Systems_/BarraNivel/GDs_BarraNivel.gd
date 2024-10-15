@tool class_name GDs_BarraNivel extends Node

@export var ProgressBarra: TextureProgressBar
@export var LabelNvl: Label
@export var LabelCrit: Label
@export var normalColor: Color
@export var PrevColor: Color
@export var CritColor: Color
@export var UseNormAndPrevValues:= false:
	set (value) :
		UseNormAndPrevValues = value
		notify_property_list_changed()

@export var LabelNorm: Label
@export var LabelPrev: Label

@export var UseGlowingAnimation:= false
var tween: Tween
var glowingTween: Tween
var originalBarColor: Color

func _validate_property(property: Dictionary) -> void:
	if property.name in ["LabelNorm"] and not UseNormAndPrevValues:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ["LabelPrev"] and not UseNormAndPrevValues:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func FillBarData(nivel:float,nvlPreventivo: float, nvlCritico: float):
	LabelNvl.text = UTILITIES.FormatNivel(nivel)
	LabelCrit.text = UTILITIES.FormatNivel(nvlCritico)
	ProgressBarra.value = nivel
	ProgressBarra.max_value = nvlCritico
	ChangeBarColor(nivel,nvlPreventivo, nvlCritico)
	#PlayBarAnimation(nivel)

func ChangeBarColor(nivel:float,nvlPreventivo: float, nvlCritico: float):
	if glowingTween:
		if glowingTween.is_running(): StopGlowingAnimation() 
	ProgressBarra.tint_progress = normalColor
	if nivel >= nvlPreventivo && nivel < nvlCritico: 
		ProgressBarra.tint_progress = PrevColor
		if UseGlowingAnimation: PlayGlowingAnimation()
	
	if nivel >= nvlCritico: 
		ProgressBarra.tint_progress = CritColor
		if UseGlowingAnimation: PlayGlowingAnimation()

func PlayBarAnimation(value:float):
	tween = create_tween()
	tween.tween_property(ProgressBarra,'value',value * 100,.5).from(0)

func SetProgressBarValue(value:float):
	ProgressBarra.value = value
	

func PlayGlowingAnimation():
	glowingTween = create_tween().set_loops()
	originalBarColor = ProgressBarra.tint_progress
	var fadedColor = originalBarColor
	fadedColor.a = .5
	glowingTween.tween_property(ProgressBarra,"tint_progress",fadedColor,.5)
	glowingTween.tween_property(ProgressBarra,"tint_progress",originalBarColor,.5)
	
func StopGlowingAnimation():
	ProgressBarra.tint_progress = originalBarColor
	glowingTween.kill()
