tool
class_name OptionContanier

extends VBoxContainer

signal option_selected(option_index, option)
signal item_selected(item_index, item)

onready var TITLE_NODE: Label = $Title
export(String) var title: String setget set_title, get_title
onready var LIST_NODE: Label = $List

export(bool) var enabled: bool = true

export(int) var visible_option_count: int = 5 setget set_visible_option_count

# May add a circular wrap-around type
enum WrapType { NON_WRAPPING, WRAP_AROUND }
export(WrapType) var WRAP_TYPE: int = WrapType.NON_WRAPPING

export(PoolStringArray) var options: PoolStringArray = PoolStringArray([]) setget set_options
var menu_items: Array = [] setget set_menu_items
var active_item_index: int = 0 setget set_active_item_index
var visible_from: int = 0
var visible_to: int = int(min(visible_option_count - 1, options.size() - 1))

onready var NAVIGATE_SOUND_PLAYER := $NavigateSoundPlayer as AudioStreamPlayer
onready var SELECT_SOUND_PLAYER := $SelectSoundPlayer as AudioStreamPlayer

func _ready() -> void:
    self.title = title
    update_list_text()

func set_title(new_title: String) -> void:
    title = new_title
    var title_node: Label = get_node_or_null("Title") if Engine.editor_hint else TITLE_NODE
    if title_node:
        title_node.text = title

func get_title() -> String:
    var title_node: Label = get_node_or_null("Title") if Engine.editor_hint else TITLE_NODE
    if title_node and title_node.text != title:
        title = title_node.text
    return title

func set_visible_option_count(new_visible_option_count: int) -> void:
    if new_visible_option_count < 1:
        return
    visible_option_count = new_visible_option_count
    reset_index()
    update_list_text()

func set_options(new_options: PoolStringArray) -> void:
    options = new_options
    var new_menu_items := []
    for _label in options:
        var label := _label as String
        new_menu_items.append(BasicMenuItem.new(label))
    self.menu_items = new_menu_items

func set_menu_items(new_menu_items: Array) -> void:
    menu_items = new_menu_items
    reset_index()
    update_list_text()

func reset_index() -> void:
    visible_from = 0
    visible_to = int(min(visible_option_count - 1, menu_items.size() - 1))
    active_item_index = 0

func set_active_item_index(new_active_item_index: int) -> void:
    if menu_items.empty():
        return
    
    if not is_index_in_option_range(new_active_item_index):
        match WRAP_TYPE:
            WrapType.NON_WRAPPING:
                return
            WrapType.WRAP_AROUND:
                if new_active_item_index >= 0:
                    new_active_item_index = new_active_item_index % menu_items.size()
                else:
                    # warning-ignore:integer_division
                    new_active_item_index -= ((new_active_item_index + 1) / menu_items.size() - 1) * menu_items.size()
            _:
                assert(false, "Don't know how to handle wrap-around type (%d)" % WRAP_TYPE)
                return
    
    active_item_index = new_active_item_index

    if not is_index_in_option_range(active_item_index, visible_from, visible_to):
        match WRAP_TYPE:
            WrapType.NON_WRAPPING, WrapType.WRAP_AROUND:
                if active_item_index < visible_from:
                    visible_to = int(min(active_item_index + visible_option_count - 1, self.menu_items.size() - 1))
                    visible_from = int(max(visible_to - visible_option_count + 1, 0))
                else:
                    visible_from = int(max(active_item_index - visible_option_count + 1, 0))
                    visible_to = int(min(visible_from + visible_option_count - 1, self.menu_items.size() - 1))
            _:
                assert(false, "Don't know how to handle wrap-around type (%d)" % WRAP_TYPE)
                return
    
    update_list_text()

func is_index_in_option_range(index: int, from: int = 0, to: int = self.menu_items.size() - 1) -> bool:
    return (index >= from and index <= to) if from <= to \
        else ((index >= from and index < self.menu_items.size()) or (index >= 0 and index <= to))

func _input(event: InputEvent) -> void:
    if not self.enabled or not self.is_visible_in_tree():
        return
    
    if event.is_action_pressed("ui_down"):
        self.active_item_index += 1
        NAVIGATE_SOUND_PLAYER.play()
        get_tree().set_input_as_handled()
    elif event.is_action_pressed("ui_up"):
        self.active_item_index -= 1
        NAVIGATE_SOUND_PLAYER.play()
        get_tree().set_input_as_handled()
    elif event.is_action_pressed("ui_select"):
        var item := self.menu_items[self.active_item_index] as MenuItem
        if item is BasicMenuItem:
            emit_signal("option_selected", self.active_item_index, item.label)
        emit_signal("item_selected", self.active_item_index, item)
        SELECT_SOUND_PLAYER.play()
        get_tree().set_input_as_handled()
    else:
        var item := self.menu_items[self.active_item_index] as MenuItem
        if item.receive_input(event):
            NAVIGATE_SOUND_PLAYER.play()
            get_tree().set_input_as_handled()
            self.update_list_text()

func update_list_text() -> void:
    var list_node: Label = get_node_or_null("List") if Engine.editor_hint else LIST_NODE
    if not list_node:
        return
    
    var lines: PoolStringArray = PoolStringArray([])
    if not menu_items.empty():
        if visible_from <= visible_to:
            for i in range(visible_from, visible_to + 1):
                lines.append(get_item_label(i))
        else:
            for i in range(visible_from, menu_items.size()):
                lines.append(get_item_label(i))
            for i in range(0, visible_to + 1):
                lines.append(get_item_label(i))
    
    while lines.size() < visible_option_count:
        lines.append("")
    
    list_node.text = lines.join("\n")

func get_item_label(index: int) -> String:
    var item := self.menu_items[index] as MenuItem
    var label := item.get_display_text()
    return "[ %s ]" % label if index == active_item_index else label
