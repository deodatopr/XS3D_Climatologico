class_name GDs_SIGNALS
extends Node

#SCENES
@warning_ignore('unused_signal')
signal OnGoToSitio(_idSitio : int)

signal OnSitioInitialized

#CAMERA
@warning_ignore('unused_signal')
signal OnCameraUpdate(_isUpdating : bool)

@warning_ignore('unused_signal')
signal OnCameraRequestChangeMode(_modoToChange : int)

@warning_ignore('unused_signal')
signal OnCameraCanChangeMode()

@warning_ignore('unused_signal')
signal OnCameraChangedMode(_modoToChange : int)
