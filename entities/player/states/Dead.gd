extends PlayerState

func enter() -> void:
    self.player.emit_signal("dead")
