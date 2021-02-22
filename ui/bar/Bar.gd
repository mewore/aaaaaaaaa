tool
class_name Bar

extends Node2D

onready var WRAPPER := $Wrapper as Node2D

export(bool) var invisible_when_full := true

export(float, 0.0, 1.0) var ratio: float = 1.0 setget set_ratio

func set_ratio(new_ratio: float) -> void:
    ratio = new_ratio
    self.refresh()

func _ready():
    self.refresh()

func refresh() -> void:
    if self.refresh_visibility():
        self.refresh_contents()

func refresh_contents() -> void:
    pass

func refresh_visibility() -> bool:
    if Engine.editor_hint and not WRAPPER and has_node("Wrapper"):
        WRAPPER = $Wrapper
    if not WRAPPER:
        return false
    WRAPPER.visible = false if self.should_be_invisible() else true
    return WRAPPER.visible

func should_be_invisible() -> bool:
    return self.invisible_when_full and not Engine.editor_hint and is_equal_approx(self.ratio, 1.0)
