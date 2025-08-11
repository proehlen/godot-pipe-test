# Adapted fromhttps://github.com/godotengine/godot/pull/89206

extends Control

var message_pipe: FileAccess
var error_pipe: FileAccess
var thread: Thread
var is_running: bool
var is_quitting = false

func _ready():
	# start terminal process and open pipes
	var os_name = OS.get_name()
	assert(os_name == "Linux", "Sorry, I don't have win/mac versions of the echo script")

	var info = OS.execute_with_pipe("/bin/bash", ["echo-test.sh"])
	is_running = true
	assert(info, "Couldn't execute echo script. Maybe a path problem?" )
	message_pipe = info["stdio"]
	error_pipe = info["stderr"]
	thread = Thread.new()
	thread.start(_thread_func)
	get_window().close_requested.connect(clean_func)
	find_child("InputLine").grab_focus()

func _add_error(message):
	_add_message("ERROR: " + message)
	
func _thread_func():
	# read stdin and add to history.
	while message_pipe.is_open() and is_running:
		if message_pipe.get_error() != OK:
			_add_error.call_deferred(error_pipe.get_line())
			break
		else:
			var message = message_pipe.get_line()
			_add_message.call_deferred(message)
			if (message == "stopped"):
				is_running = false
				_disable_input.call_deferred()
				if is_quitting:
					_quit.call_deferred()

func _disable_input():
	find_child("InputContainer").visible = false

func _scroll_to_end():
	var messages = find_child("Messages")
	messages.scroll_vertical = messages.get_v_scroll_bar().max_value
	
func _add_message(line):
	if line:
		find_child("Messages").text += line + "\n"
		_scroll_to_end()

func clean_func():
	# close pipes and cleanup.
	message_pipe.close()
	error_pipe.close()
	thread.wait_to_finish()

func _send_message(message: String):
	# send command to stdin.
	assert(is_running, "Process isn't running.")
	var cmd = message + "\n"
	var buffer = cmd.to_utf8_buffer()
	message_pipe.store_buffer(buffer)
	find_child("InputLine").text = ""
	_add_message("> " + message)
	
func _on_input_line_text_submitted(new_text: String) -> void:
	_send_message(new_text)
	
func _quit():
	get_tree().quit() 

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		is_quitting = true
		if is_running:
			_send_message("quit")
		else:
			_quit()
		
func _on_exit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
