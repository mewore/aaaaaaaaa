tool
extends Bar

# A reasonable number to prevent devs from accidentally spawning a million icons
const MAX_ICON_COUNT: int = 100
export(int) var icon_count: int = 1 setget set_icon_count
var icons := []

export(Texture) var icon_texture: Texture setget set_icon_texture
var icon_width: int
var icon_hframes: int

func set_icon_texture(new_icon_texture: Texture) -> void:
    if new_icon_texture == icon_texture:
        return
    if new_icon_texture == null:
        icon_texture = null
        while not icons.empty():
            WRAPPER.remove_child(icons.pop_back())
        return
    var width := new_icon_texture.get_width()
    var height := new_icon_texture.get_height()
    if width % height != 0:
        push_warning("The width of texture '%s' (%d) should be divisible by its height (%d)!" % [
            new_icon_texture.resource_path, width, height])
    icon_width = height
    icon_hframes = int(round(floor(width) / icon_width))
    icon_texture = new_icon_texture
    refresh_contents()

func set_icon_count(new_icon_count: int) -> void:
    if new_icon_count < 0:
        new_icon_count = 0
    if new_icon_count > MAX_ICON_COUNT:
        new_icon_count = MAX_ICON_COUNT
    icon_count = new_icon_count
    refresh_contents()

func refresh_contents() -> void:
    if not self.icon_texture:
        return
    if not WRAPPER:
        return
    
    while WRAPPER.get_child_count() > icons.size():
        WRAPPER.remove_child(WRAPPER.get_child(WRAPPER.get_child_count() - 1))
    WRAPPER.position.x = -(icon_count - 1) * 0.5 * self.icon_width
    while icons.size() < self.icon_count:
        var new_icon := Sprite.new()
        new_icon.texture = self.icon_texture
        new_icon.hframes = self.icon_hframes
        new_icon.position.x = icons.size() * icon_width
        WRAPPER.add_child(new_icon)
        icons.append(new_icon)
    while icons.size() > self.icon_count:
        WRAPPER.remove_child(icons.pop_back())
    
    if icons.empty():
        return
    
    var value_per_icon := 1.0 / self.icon_count
    var from := 0.0
    var to := value_per_icon
    for _icon in icons:
        var icon := _icon as Sprite
        if self.icon_hframes == 1:
            icon.visible = self.ratio > to
        elif self.ratio < from:
            icon.frame = 0
        elif self.ratio > to:
            icon.frame = self.icon_hframes - 1
        else:
            icon.frame = int(ceil(lerp(0, self.icon_hframes - 1, inverse_lerp(from, to, self.ratio))))
        from = to
        to += value_per_icon
