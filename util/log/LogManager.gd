tool
extends Node

# Source:
# https://github.com/ivanskodje-godotengine/godot-logging-util
# But with some modifications

const ENABLE_LOGGING: bool = true
var LOG_TO_FILE: bool = true \
    and ENABLE_LOGGING \
    and not Engine.editor_hint # ENABLE_LOGGING must be enabled
const DEFAULT_LOG_PATH: String = "res://logs/"
const DEFAULT_LOG_NAME: String = "logger"
var START_TIME: Dictionary = OS.get_datetime()

# Use this on each script you wish to use the Logger
func get_log(object, log_path: String = DEFAULT_LOG_PATH, log_file: String = DEFAULT_LOG_NAME) -> Log:
    if not OS.is_debug_build() or not ENABLE_LOGGING or OS.has_feature("web") \
            or not Directory.new().dir_exists(log_path):
        return DummyLog.new()
    return RealLog.new(LogSettings.new(object, log_path, log_file))

#####################
######## Log ########
#####################

class LogSettings:
    var caller_location: String
    var script_name: String
    var calling_node: Node
    
    var file_writer: IFileWriter
    
    func _init(object, log_path: String, log_file: String) -> void:
        if object is String:
            self.caller_location = object
        elif object is Object:
            var script_path: String = object.get_script().resource_path
            self.script_name = script_path.substr(script_path.find_last("/") + 1)
            if object is Node:
                _determine_location_based_on_node(object)
            else:
                self.caller_location = self.script_name
        else:
            self.caller_location = str(object)
        
        if LogManager.LOG_TO_FILE:
            self.file_writer = FileWriter.new(log_path, log_file)
        else:
            self.file_writer = DummyFileWriter.new()
    
    func _determine_location_based_on_node(node: Node) -> void:
        self.calling_node = node
        _refresh_location_with_node()
        if node.name:
            return
        
        yield(node, "ready")
        self._refresh_location_with_node()
        var error: int = node.connect("renamed", self, "_on_location_node_renamed")
        if error != OK:
            printerr("Error [%d] when connecting to the 'renamed' signal of node '%s'" %
                [error, node.name])
    
    func _on_location_node_renamed() -> void:
        self._refresh_location_with_node()
    
    func _refresh_location_with_node(node: Node = self.calling_node) -> void:
        self.caller_location = self._get_node_location(node)
    
    func _get_node_location(node: Node) -> String:
        if not node:
            return self.script_name
            
        if not node.name:
            return "... (%s)" % self.script_name
            
        if not node.owner or not node.owner.name:
            return "%s (%s)" % [node.name, self.script_name]
            
        return "%s:%s (%s)" % [node.owner.name, node.name, self.script_name]

class RealLog:
    extends Log
    
    # GLOBAL DEFAULT LOGGING CONFIGURATION
    # - This can be overridden within each script that utilizes the log tool.
    var LEVEL_MAP: Dictionary = {
        LEVEL_TRACE: 1,
        LEVEL_DEBUG: 2,
        LEVEL_INFO: 3,
        LEVEL_WARN: 4,
        LEVEL_ERROR: 5,
        LEVEL_SEVERE: 6,
    }
    
    var trace_logging: bool = true
    var debug_logging: bool = true
    var info_logging: bool = true
    var warn_logging: bool = true
    var error_logging: bool = true
    var severe_logging: bool = true
    
    # LOGGING 
    const LOG_FORMAT = "[{current_time}] | {level} | [{function_name} @ {caller_location}] >> {message}"
    const DATE_TIME_FORMAT = "{year}-{month}-{day} {hour}:{minute}:{second}"
    const DATE_TIME_PADDING = 2
    
    const LEVEL_TRACE: String = "TRACE"
    const LEVEL_DEBUG: String = "DEBUG"
    const LEVEL_INFO: String = "INFO"
    const LEVEL_WARN: String = "WARN"
    const LEVEL_ERROR: String = "ERROR"
    const LEVEL_SEVERE: String = "SEVERE"
    
    const DEFAULT_LOG_LEVEL: String = LEVEL_INFO
    
    # Logger script name
    var settings: LogSettings
    
    var file_writer: IFileWriter
    
    # Initializes the logger with the script name that is using it
    func _init(initial_settings: LogSettings) -> void:
        self.settings = initial_settings
        self.file_writer = settings.file_writer
        self.set_log_Level(DEFAULT_LOG_LEVEL)
    
    func set_log_Level(log_level: String) -> void:
        var log_level_numeric: int = LEVEL_MAP[log_level]
        self.trace_logging = LEVEL_MAP[LEVEL_TRACE] >= log_level_numeric
        self.debug_logging = LEVEL_MAP[LEVEL_DEBUG] >= log_level_numeric
        self.info_logging = LEVEL_MAP[LEVEL_INFO] >= log_level_numeric
        self.warn_logging = LEVEL_MAP[LEVEL_WARN] >= log_level_numeric
        self.error_logging = LEVEL_MAP[LEVEL_ERROR] >= log_level_numeric
        self.severe_logging = LEVEL_MAP[LEVEL_SEVERE] >= log_level_numeric
        
    func trace(message: String) -> void:
        if trace_logging:
            _log(LEVEL_TRACE, message)
        
    func debug(message: String) -> void:
        if debug_logging:
            _log(LEVEL_DEBUG, message)
    
    func info(message: String) -> void:
        if info_logging:
            _log(LEVEL_INFO, message)

    func warn(message: String) -> void:
        if warn_logging:
            _log(LEVEL_WARN, message)
        
    func error(message: String) -> void:
        if error_logging:
            _log(LEVEL_ERROR, message)
        
    func severe(message: String) -> void:
        if severe_logging:
            _log(LEVEL_SEVERE, message)
        breakpoint

    func check_error_code(
            error_code: int,
            action_description: String = "") -> void:
        if error_logging and error_code != OK:
            var action_description_phase: String = \
                "the following action: %s" % action_description if action_description \
                else "an unknown action"
            var message: String = \
                "Encountered ERROR [%d] while performing the %s" % \
                [error_code, action_description_phase]
            
            _log(LEVEL_ERROR, message)
            assert(error_code == OK, "The error_code (%d) of %s should be OK (%d)" %
                [error_code, action_description_phase, OK])
    
    func _log(level: String, message: String) -> void:
        var log_message: String = LOG_FORMAT.format({
            "level": level,
            "current_time": _get_current_time(),
            "caller_location": self.settings.caller_location, 
            "function_name": _get_calling_function_name(),
            "message": message
        })
        if level == LEVEL_ERROR or level == LEVEL_SEVERE:
            push_error(log_message)
            log_message += "\n" + _get_stack_string()
            printerr(log_message)
        elif level == LEVEL_WARN:
            push_warning(log_message)
            log_message += "\n" + _get_stack_string()
            printerr(log_message)
        else:
            print(log_message)
        file_writer.write(log_message)
    
    static func _get_current_time() -> String:
        var date_time: Dictionary = OS.get_datetime()
        _pad_zeroes_in_dictionary(date_time, DATE_TIME_PADDING)
        return DATE_TIME_FORMAT.format(date_time)
    
    static func _pad_zeroes_in_dictionary(dictionary: Dictionary, padding: int) -> void:
        for key in dictionary:
            dictionary[key] = str(dictionary[key]).pad_zeros(padding)
    
    static func _get_calling_function_name() -> String:
        var stack: Array = get_stack()

        var first_non_log_frame: int = 0
        while first_non_log_frame < stack.size() \
            and stack[first_non_log_frame].source.ends_with("LogManager.gd"):
            first_non_log_frame += 1
        
        return stack[first_non_log_frame].function if first_non_log_frame < stack.size() else ""
    
    func _get_stack_string() -> String:
        var stack: Array = get_stack()

        var first_non_log_frame: int = 0
        while first_non_log_frame < stack.size() \
            and stack[first_non_log_frame].source.ends_with("LogManager.gd"):
            first_non_log_frame += 1
        
        var frame_strings: Array = []
        var start_index: int = 0 if first_non_log_frame == stack.size() else first_non_log_frame
        for i in range(start_index, stack.size()):
            frame_strings.append("\tat [Frame %d] - %s:%s in function '%s'%s" % 
                [i, stack[i].source, stack[i].line, stack[i].function,
                " <---" if i == start_index else ""])

        return PoolStringArray(frame_strings).join("\n")


# DummyLog prevents logging when we have disabled logging.
# An efficient way to disable functionality without affecting performance or having to make code changes.
class DummyLog:
    extends Log

    func check_error_code(
            error_code: int,
            _message: String = "") -> void:
        assert(error_code == OK)

############################
######## FileWriter ########
############################

class IFileWriter:
    func write(_log_line: String) -> void:
        pass


class FileWriter:
    extends IFileWriter

    const DATE_TIME_FORMAT: String = "{year}-{month}-{day}-{hour}-{minute}-{second}"
    const DATE_TIME_PADDING: int = 2
    
    var file: File = null
    var full_file_path: String = ""
    
    func _init(file_path: String, file_name: String) -> void:
        self.full_file_path = file_path  + _get_game_start_time() + "-" + file_name + ".log"
        self.file = File.new()
    
    func _create_file_if_not_exist() -> void:
        if not file.file_exists(full_file_path):
            var error: int = file.open(full_file_path, File.WRITE)
            if error != OK:
                printerr("Error [%d] when creating file %s" % [error, full_file_path])
            file.close()
    
    func write(log_line: String) -> void:
        _create_file_if_not_exist()

        var error: int = self.file.open(full_file_path, File.READ_WRITE)
        if error != OK:
            printerr("Error [%d] when opening file %s" % [error, full_file_path])
        self.file.seek_end()
        self.file.store_line(log_line)
        self.file.close()
    
    func _get_game_start_time() -> String:
        var date_time: Dictionary = LogManager.START_TIME
        _pad_zeros_in_dictionary(date_time, DATE_TIME_PADDING)
        return DATE_TIME_FORMAT.format(date_time)
    
    func _pad_zeros_in_dictionary(dictionary: Dictionary, padding: int) -> void:
        for key in dictionary:
            dictionary[key] = str(dictionary[key]).pad_zeros(padding)


# DummyFileWriter prevents writing a file when we have disabled file writing.
# An efficient way to disable functionality without affecting performance or having to make code changes.
class DummyFileWriter:
    extends IFileWriter
