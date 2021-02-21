class_name BasicMenuItem

extends MenuItem

var label: String

func _init(initial_label: String) -> void:
    self.label = initial_label

func get_display_text() -> String:
    return label
