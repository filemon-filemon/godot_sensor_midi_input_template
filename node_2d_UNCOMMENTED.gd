extends Node2D

@onready var sprite = $Sprite2D

var raw_controller_number := 1
var raw_midi_value := 1
var pc_midi_value := 0.0

var pc_controller_number := 1
var known_raw_controller_numbers := []

func _ready() -> void:
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())

func _input(input_event):
	if input_event is InputEventMIDI:
		_print_midi_info(input_event)
		_assign_variables(input_event)
		_do_thingies()

func _print_midi_info(midi_event):
	print(midi_event)
	print("Channel ", midi_event.channel)
	print("Message ", midi_event.message)
	print("Pitch ", midi_event.pitch)
	print("Velocity ", midi_event.velocity)
	print("Instrument ", midi_event.instrument)
	print("Pressure ", midi_event.pressure)
	print("Controller number: ", midi_event.controller_number)
	print("Controller value: ", midi_event.controller_value)

func _assign_variables(midi_event):
	raw_controller_number = midi_event.controller_number
	raw_midi_value = midi_event.controller_value
	pc_midi_value = raw_midi_value / 127
	_adaptable_controller_number_picker()

func _adaptable_controller_number_picker():
	if not raw_controller_number in known_raw_controller_numbers:
		known_raw_controller_numbers.append(raw_controller_number)
		print("new controller number stored !", known_raw_controller_numbers.find(raw_controller_number))
		print("known controller numbers : ", known_raw_controller_numbers)
	pc_controller_number = known_raw_controller_numbers.find(raw_controller_number)

func _do_thingies():
	match raw_controller_number:
		48:
			sprite.rotation_degrees = pc_midi_value * 360
		49:
			sprite.scale = Vector2(pc_midi_value, pc_midi_value)
	#match pc_controller_number:
		#0:
			#sprite.rotation_degrees = pc_midi_value * 360
		#1:
			#sprite.scale = Vector2(pc_midi_value, pc_midi_value)
