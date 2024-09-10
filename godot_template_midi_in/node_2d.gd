#You can basically extend any node with that code, not just node2D
extends Node2D

#saving the sprite as a variable to use in the rest of the script
@onready var sprite = $Sprite2D

#This variable is made to store the number of the control change, and therefore to know which controller is in use
var raw_controller_number := 1
#This variable is made to store the integer sent by the sensor, from 0 to 127
var raw_midi_value := 1
#This variable is made to store the midi_raw_value expressed in a float from 0 to 1
var pc_midi_value := 0.0

#This variable is optional, and is made for games and softwares needing to be exported to other systems, that may not have the same configs
#See more at _adaptable_controller_number_picker() function if you want to know more about this variable
var pc_controller_number := 1
#This variable is an array to store the raw_controller_numbers and assign a new value to them, tied to their indexe
#For more infos see _adaptable_controller_number_picker() function
#Be careful as the values of this function start from 0, and not from 1 (your first stored sensor will be given the indexe number 0)
var known_raw_controller_numbers := []

#This function is triggered at the start of the program
func _ready() -> void:
	#gets the midi inputs and makes the rest of the script work
	OS.open_midi_inputs()
	#this prints the connected midi signal sources in the console
	print(OS.get_connected_midi_inputs())

#This function is triggered when an event happens
func _input(input_event):
	#This bit of code is triggered when something happens/changes related to the MIDI input
	#For example, when you activate a connected sensor, this bit of code will run
	if input_event is InputEventMIDI:
		#This prints as much info as it can from the MIDI source
		#When not testing if the MIDI input works, you can comment this function out
		_print_midi_info(input_event)
		#This function lets you store some infos about the MIDI input for later use
		_assign_variables(input_event)
		#This function is where you make your code do all the fun stuff !! I put a little exemple there :D
		_do_thingies()

#This prints as much info as it can from the MIDI source
#When not testing if the MIDI input works, you can comment this function out
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

#This function lets you assign some infos about the MIDI input for later use
#Here we will focus on storing which controller is in use, what is its raw integer, and to what float it rounds up when transformed into a %
func _assign_variables(midi_event):
	#This variable is made to store the number of the control change, and therefore to know which controller is in use
	raw_controller_number = midi_event.controller_number
	#This variable is made to store the integer sent by the sensor, from 0 to 127
	raw_midi_value = midi_event.controller_value
	#This variable is made to store the midi_raw_value expressed in a float from 0 to 1
	pc_midi_value = raw_midi_value / 127
	#This an optional function, that helps when exporting your project to a place that doesnt have the same hardware config
	#More infos just below, at the actual function
	_adaptable_controller_number_picker()

#This function is totally optionnal, but may be very handy for some
#Basically, the problem is that, when exporting a project with sensors, the control change numbers might vary drastically from one card to the other
#When trying to export this project to other people that dont use the same hardware config, having an "adaptable code" can come in handy
#Basically, this function lets you use virtual controller numbers in _do_thingies() function instead of the real ones
#For exemple, if you have at home two sensors connected to the 48 and 49 ports of your control change, and someone tries to use your softwrare in an environment where they have only access to the 50 and 51 ports, you can use this code
#When activating a sensor, it will be stored in the known_raw_controller_numbers array, then the pc_controller_number variable will be linked to its index in the array
#This way, in _do_thingies() function, you can just call the index of the needed sensor, and the user will have the same experience as you if they activate the sensors in the same order
#This might be very annoying for certain projects, that's why it's totally optionnal.
#I suggest open sourcing projects made with sensors if they use the "raw_controller_number" variable to perform actions, so that it's easier to debug for the users, and they can still enjoy your work :D
func _adaptable_controller_number_picker():
	#checks if the raw_controller is already stored, and reacts accordingly if not
	if not raw_controller_number in known_raw_controller_numbers:
		#adds the raw_controller_number at the end of the array
		known_raw_controller_numbers.append(raw_controller_number)
		#here are some useful print statements for debugging // checking the good deployment of your program
		#tells you that a new controller has been stored, and prints out the pc_controller_number related to it
		print("new controller number stored !", known_raw_controller_numbers.find(raw_controller_number))
		#prints the array content, by that I mean the known controller numbers
		print("known controller numbers : ", known_raw_controller_numbers)
	#"transforms" the raw_controller_number into its pc_controller_number equivalent
	pc_controller_number = known_raw_controller_numbers.find(raw_controller_number)

#this is an exemple, you can put the content of this function anywhere you want in your code, even in the _process(delta) function :D
func _do_thingies():
	#exemple of what you would maybe do using the "raw" method
	match raw_controller_number:
		48:
			sprite.rotation_degrees = pc_midi_value * 360
		49:
			sprite.scale = Vector2(pc_midi_value, pc_midi_value)
	#exemple of what you would maybe do using the "_adaptable_controller_number_picker()"
	#to avoid problems, I recommand commenting one of the two options
	#this exemple is commented by default for this reason
	#match pc_controller_number:
		#0:
			#sprite.rotation_degrees = pc_midi_value * 360
		#1:
			#sprite.scale = Vector2(pc_midi_value, pc_midi_value)


#This project was made as a newcomer-friendly way of integrating midi signals from capters into a godot 4.3+ project
#It is made to use with sensor sending integers in the midi signal

#This is the godot doc about handling midi inputs
#https://docs.godotengine.org/en/stable/classes/class_inputeventmidi.html

#For MIDI outputs, see NullMembers plugin below:
#https://github.com/NullMember/godot-rtmidi
