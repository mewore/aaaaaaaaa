class_name FadeOverlay

extends CanvasLayer

signal faded_out()
signal started_fading_out()

onready var ANIMATION_PLAYER := $AnimationPlayer as AnimationPlayer

func fade_out() -> void:
    ANIMATION_PLAYER.queue("fade_out")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
    if anim_name == "fade_out":
        self.emit_signal("faded_out")

func _on_AnimationPlayer_animation_started(anim_name: String) -> void:
    if anim_name == "fade_out":
        self.emit_signal("started_fading_out")
