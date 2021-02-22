tool
extends Bar

onready var INNER_LINE := $Wrapper/Inner as Line2D

export(Color) var full_colour: Color = Color.aquamarine setget set_full_colour
export(Color) var empty_colour: Color = Color.indianred setget set_empty_colour

func set_full_colour(new_full_colour: Color) -> void:
    full_colour = new_full_colour
    self.refresh_contents()

func set_empty_colour(new_empty_colour: Color) -> void:
    empty_colour = new_empty_colour
    self.refresh_contents()

func refresh_contents() -> void:
    if Engine.editor_hint and not INNER_LINE and has_node("Wrapper/Inner"):
        INNER_LINE = $Wrapper/Inner
    if not INNER_LINE:
        return
    INNER_LINE.scale.x = self.ratio
    INNER_LINE.default_color = self.empty_colour.linear_interpolate(self.full_colour, self.ratio)
    if not WRAPPER:
        WRAPPER = $Wrapper as Node2D
    self.refresh_visibility()
