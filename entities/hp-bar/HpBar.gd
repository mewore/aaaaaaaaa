extends Node2D

class_name HpBar

onready var INNER: Line2D = $Inner

export(Color) var FULL_COLOUR: Color = Color.aquamarine
export(Color) var EMPTY_COLOUR: Color = Color.indianred

export(bool) var invisible_when_full := true

func _ready():
    if self.invisible_when_full:
        self.modulate.a = 0.0

func set_hp_ratio(hp_ratio: float) -> void:
    INNER.scale.x = hp_ratio
    INNER.default_color = EMPTY_COLOUR.linear_interpolate(FULL_COLOUR, hp_ratio)
    self.modulate.a = 0.0 if self.invisible_when_full and  is_equal_approx(hp_ratio, 1.0) else 1.0
