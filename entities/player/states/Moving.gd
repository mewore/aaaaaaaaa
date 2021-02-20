extends PlayerState

const HP_LOST_PER_SECOND := 0.005

func process(delta: float) -> void:
    self.player.hp -= delta * HP_LOST_PER_SECOND
    if self.player.hp < 0.0:
        self.player.hp = 0.0
        self.next_state = DYING

func physics_process(delta: float) -> void:
    self.player.move(delta)

func unhandled_input(event: InputEvent) -> void:
    self.player.handle_jump_control(event)

func _on_Player_reached_win_area() -> void:
    self.next_state = WINNING
