class_name SliderMenuItem

extends MenuItem

signal changed()

const DEFAULT_SLIDER_LENGTH := 10

var label: String
var slider_length: int = DEFAULT_SLIDER_LENGTH setget set_slider_length
var whole_value: int = 0 setget set_whole_value
var value: float = 0.0 setget set_value

func _init(initial_label: String) -> void:
    self.label = initial_label

func set_slider_length(new_slider_length: int) -> void:
    slider_length = new_slider_length
    # Refresh the value so that it matches a corresponding whole (integer) value
    self.value = self.value

func set_whole_value(new_whole_value: int) -> void:
    if new_whole_value >= 0 and new_whole_value <= slider_length:
        whole_value = new_whole_value
        value = float(whole_value) / slider_length

func set_value(new_value: float) -> void:
    if new_value < 0.0 and new_value > 1.0:
        return
    whole_value = int(round(new_value * slider_length))
    value = float(whole_value) / slider_length

func get_display_text() -> String:
    return "%s: (%s|%s)" % [label, "-".repeat(whole_value), "-".repeat(slider_length - whole_value)]

func receive_input(event: InputEvent) -> bool:
    if event.is_action_pressed("ui_left"):
        self.whole_value -= 1
        emit_signal("changed")
        return true
    if event.is_action_pressed("ui_right"):
        self.whole_value += 1
        emit_signal("changed")
        return true
    return false
