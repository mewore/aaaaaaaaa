extends Node

var LOG: Log = LogManager.get_log(self)

const SAVE_DIRECTORY = "user://"
const SAVE_FILE_PREFIX = "save-"
const SAVE_FILE_SUFFIX = ".json"

const SETTINGS_SAVE_FILE := "settings"
const DEFAULT_SAVE_FILE := "default"

var settings: GameSettings = GameSettings.new()
var game_data: Dictionary = {}

const FIRST_LEVEL := 0
var current_level := FIRST_LEVEL

func _ready() -> void:
    if self.save_file_exists(SETTINGS_SAVE_FILE):
        self.settings.initialize_from_dictionary(self.load_data(SETTINGS_SAVE_FILE))

func new_game() -> void:
    Global.current_level = FIRST_LEVEL
    self.game_data = {}

func save_game(save_name: String = DEFAULT_SAVE_FILE, save_to_overwrite: String = "") -> void:
    for _node in get_tree().get_nodes_in_group("saveable"):
        var node := _node as Node
        if node.has_method("save_data"):
            node.save_data()

    for _key in game_data.keys():
        var key := _key as String
        var value = game_data.get(key)
        if value is Dictionary:
            var dict := value as Dictionary
            if dict.empty() and not game_data.erase(key):
                print("Tried to erase a non-existent game data key '%s'!" % key)
    self.game_data["level"] = self.current_level

    save_data(save_name, game_data)
    
    if not save_to_overwrite.empty() and save_to_overwrite != save_name:
        var dir: Directory = self.open_save_directory()
        var old_save_file_name: String = SAVE_FILE_PREFIX + save_to_overwrite + SAVE_FILE_SUFFIX
        if dir.file_exists(old_save_file_name):
            LOG.check_error_code(dir.remove(old_save_file_name), "Removing '%s'" % [old_save_file_name])

func save_settings() -> void:
    save_data(SETTINGS_SAVE_FILE, self.settings.as_dictionary())

func save_data(save_name: String, data: Dictionary) -> void:
    var path := self.get_save_file_path(save_name)
    LOG.info("Saving data to: %s" % path)
    var file := File.new()
    LOG.check_error_code(file.open(path, File.WRITE), "Opening '%s'" % path)
    LOG.info("Saving to: " + file.get_path_absolute())
    file.store_string(to_json(data))
    file.close()

func get_save_files() -> PoolStringArray:
    var dir: Directory = self.open_save_directory()
    LOG.check_error_code(dir.list_dir_begin(false, false), "Listing the files of " + SAVE_DIRECTORY)
    var file_name: String = dir.get_next()
    
    var result: Array = []
    while file_name != "":
        if not dir.current_is_dir() and file_name.begins_with(SAVE_FILE_PREFIX) \
                and file_name.ends_with(SAVE_FILE_SUFFIX):
            result.append(file_name.substr(SAVE_FILE_PREFIX.length(),
                file_name.length() - SAVE_FILE_PREFIX.length() - SAVE_FILE_SUFFIX.length()))
        file_name = dir.get_next()
    dir.list_dir_end()

    result.sort()
    return PoolStringArray(result)

func get_single_node_in_group(group: String) -> Node:
    return get_tree().get_nodes_in_group(group).front()

func open_save_directory() -> Directory:
    var dir: Directory = Directory.new()
    LOG.check_error_code(dir.open(SAVE_DIRECTORY), "Opening " + SAVE_DIRECTORY)
    return dir

func load_game(save_name: String = DEFAULT_SAVE_FILE) -> bool:
    if not self.save_file_exists(save_name):
        LOG.error("No such savefile: " + save_name)
        return false
    var loaded_data := self.load_data(save_name)
    if loaded_data.empty():
        return false
    self.game_data = loaded_data
    self.current_level = self.game_data.get("level", FIRST_LEVEL)
    return true

func save_file_exists(save_name: String) -> bool:
    var path := self.get_save_file_path(save_name)
    return File.new().file_exists(path)

func load_data(save_name: String) -> Dictionary:
    var path := self.get_save_file_path(save_name)
    var file := File.new()
    LOG.check_error_code(file.open(path, File.READ), "Opening file " + path)
    var raw_data := file.get_as_text()
    file.close()
    var loaded_data = parse_json(raw_data)
    if loaded_data is Dictionary:
        return loaded_data
    else:
        LOG.error("Corrupted savegame data in file '%s'!" % path)
        return {}

static func get_save_file_path(save_name: String) -> String:
    return SAVE_DIRECTORY + "/" + SAVE_FILE_PREFIX + save_name + SAVE_FILE_SUFFIX
