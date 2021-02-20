class_name A

extends Node2D

var uppercase: bool = false

func _ready() -> void:
    if self.uppercase:
        $AnimationPlayer.play("uppercase-a")
