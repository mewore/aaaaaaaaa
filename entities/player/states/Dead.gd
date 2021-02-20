extends PlayerState

func exit() -> void:
    self.player.invulnerable = false
    self.player.SPRITE.visible = true
