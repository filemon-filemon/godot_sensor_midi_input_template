#Ce code est utilisable avec tout type de noeud !! Pas que le Node2d :D
extends Node2D

#Ici on garde le sprite posé dans la scène sous forme de variable pour pouvoir ensuite l'utiliser comme exemple
@onready var sprite = $Sprite2D

#Cette variable est faite pour garder en mémoire les numéros des ports du control change, pour savoir quel capteur est en train d'être utilisé
var raw_controller_number := 1
#Cette variable est faite pour garder l'integer envoyé par le capteur, sa valeur va de 0 à 127
var raw_midi_value := 1.0
#Cette variable est faite pour garder la valeur raw_midi_value, mais sous une forme plus utilisable dans le reste du code, sous forme d'un float allant de 0 à 1
var pc_midi_value := 0.0

#Cette variable est optionnelle, et est faite pour les jeux et programmes ayant besoin d'être exportés vers d'autres systèmes, qui n'ont pas forcément la même configuration
#Plus sur cette variable à la function _adaptable_controller_number_picker() plus bas
var pc_controller_number := 1
#Cette variable est un array pour garder les valeurs raw_controller_numbers connues et leur assigner une nouvelle valeur, liée à leur indexe
#Pour plus d'infos, voir la function _adaptable_controller_number_picker() plus bas
#Faites gaffe !! Les valeurs de cette fonction commencent à 0, et non à 1 !! (La première valeur que vous stockerez aura l'indexe "0")
var known_raw_controller_numbers := []

#Cette fonction se lance au début de l'exécution du programme
func _ready() -> void:
	#Choppe l'input MIDI et fait fonctionner le reste du script
	OS.open_midi_inputs()
	#Cette ligne print la source du signal MIDI connecté dans la console
	print(OS.get_connected_midi_inputs())

#Cette fonction se lance quand un évènement est activé
func _input(input_event):
	#Ce bout de code se lance quand quelque chose relatif aux capteurs/au signal MIDI se lance
	#Par exemple, quand un capteur capacitif est touché, le reste du code se lancera
	if input_event is InputEventMIDI:
		#Cela print beaucoup d'infos sur la source MIDI (instrument, touche, pression)
		#Quand vous n'êtes pas en train de tester si le setup de hardware marche correctement, n'hésitez pas à hashtagger cette fonction pour debloater votre console :D
		#De plus, si comme moi vous utilisez des capteurs, n'hésitez pas à toucher à cette fonction, et à enlever les infos qui ne vous intéressent pas ;D
		_print_midi_info(input_event)
		#Cette fonction vous permet de changer la valeur des variables évoquées plus haut, et ainsi de stocker les valeurs de l'input MIDI, pour les utiliser plus tard dans le code
		_assign_variables(input_event)
		#Cette fonction est la partie la plus fun !! En gros c'est juste là qu'on pourra faire s'éxecuter le code en utilisant les valeurs récupérées avant !! :D
		_do_thingies()

#Cette function print un maximum d'infos sur la source MIDI
#Quand vous n'êtes pas en période de débuggage // de setup intense, je vous conseille de commenter cette fonction, pour debloat votre console :D
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

#Cette fonction vous permet d'assigner des informations à propos de l'input MIDI pour un usage ultérieur
#Ici, concentrons-nous sur le fait de garder en mémoire quel controller/capteur est utilisé, et quel integer il transmet
func _assign_variables(midi_event):
	#Cette variable est faite pour garder en mémoire le numéro du port du control change en train d'être utilisé, et ainsi de savoir quel contrôleur est en train d'être utilisé
	raw_controller_number = midi_event.controller_number
	#Cette variable est faite pour garder en mémoire l'integer envoyé par le capteur. La valeur de cette variable va de 0 à 127
	raw_midi_value = midi_event.controller_value
	#Cette variable est faite pour garder en mémoire la variable midi_raw_value, mais exprimée sous la forme d'un float allant de 0 à 1. Cette valeur permet d'être utilisée plus facilement dans le reste du code :O
	pc_midi_value = raw_midi_value / 127
	#C'est une fonction optionnelle, qui aide lorsque l'on veut obtenir un programme exportable à un endroit ne possédant pas la même configuration hardware
	#Plus d'infos juste en dessous, à la fonction elle-même
	_adaptable_controller_number_picker()

#This function is totally optionnal, but may be very handy for some
#Cette fonction est complètement optionnelle, mais pourrait être très utile pour certain.e.s
#Le problème est, simplement, que lorsqu'on exporte un programme faisant usage de capteurs, le numéro des ports du control change peut changer du tout au tout d'une carte à l'autre
#Lorsque l'on essaie d'exporter ce projet à des gens n'ayant pas la même config hardware, avoir un code "adaptable" peut être très utile
#Cette fonction vous permet d'assigner des variables adaptableset facilement "configurables" d'un point de vue d'utilisateur lambda, et de manier des valeurs "abstraites" dans la fonction _do_thingies() au lieu des vrais ports MIDI
#Par exemple, si on a deux capteurs connectés aux ports 48 et 49 du control change, et que quelqu'un essaie d'utiliser votre programme dans un environnement où iel.le.s ont uniquement accès aux ports 50 et 51, vous pouvez utiliser ce code
#Lorsque l'on active un capteur, il sera "sauvegardé" dans l'array known_raw_controller_numbers, puis la variable pc_controller_number sera liée à son index dans ledit array
#De cette manière, dans la fonction -do-thingies(), on peut juste appeler l'indexe du capteur nécessaire, et l'utilisateur aura la même expérience que vous si iel utilise les capteurs dans le même ordre que vous
#Cette addition au code sera peut-être très chiante dans certains projets, c'est pourquoi elle est tout à fait optionnelle
#Je suggère vivement ;D d'open sourcer les projets faits avec la technique du "raw_controller_number" (c'est à dire celleux qui n'utiliseront pas cette fonction), car ainsi il sera plus facile aux usager.e.s de se débugger en cas de configuration non conforme, et ainsi de pouvoir malgré tout apprécier votre travail :D

func _adaptable_controller_number_picker():
	#vérifie si le raw_controller utilisé a déjà été enregistré, et réagit si ce n'est pas le cas
	if not raw_controller_number in known_raw_controller_numbers:
		#ajouter la variable raw_controller_number à la fin de l'array
		known_raw_controller_numbers.append(raw_controller_number)
		#Ici on appelle quelques prints utiles pour débugger // checker si tout se passe comme prévu
		#Cette ligne print qu'un nouveau raw_controller_number a été enregistré, et print la valeur de la variable pc_controller_number qui lui est reliée
		print("new controller number stored !", known_raw_controller_numbers.find(raw_controller_number))
		#print le contenu de l'array, c'est-à-dire les numéros des capteurs enregistrés
		print("known controller numbers : ", known_raw_controller_numbers)
	#"transforme" la variable raw_controller_number en son équivalent pc_controller_number
	pc_controller_number = known_raw_controller_numbers.find(raw_controller_number)

#Cette funcion est un exemple, vous pouvez changer le contenu de cette fonction, changer son nom, ou même utiliser ce code dans la fonction _process(delta) si le coeur vous en dit :D
func _do_thingies():
	#exemple d'un bout de code utilisant la méthode "raw"
	match raw_controller_number:
		48:
			sprite.rotation_degrees = pc_midi_value * 360
		49:
			sprite.scale = Vector2(pc_midi_value, pc_midi_value)
	#exemple de ce que l'on eut faire en utilisant la fonction optionnelle "_adaptable_controller_number_picker()"
	#pour éviter les problèmes, il est recommandé de commenter une des deux options pour qu'elles n'entren pas en conflit
	#ce deuxième exemple est "commenté" par défaut pour cette raison
	#match pc_controller_number:
		#0:
			#sprite.rotation_degrees = pc_midi_value * 360
		#1:
			#sprite.scale = Vector2(pc_midi_value, pc_midi_value)


#Ce projet a été fait pour être un moyen très abordable pour celleux qui n'ont pas l'habitude de godot d'intégrer les signaux midi, surtout ceux provenant de capteurs, dans un projet godot 4.3+
#Ce projet est pensé pour être utilisé avec des capteurs envoyant des integers via le signal MIDI

#Ici la documentation officielle concernant l'uilisation d'input MIDI dans l'engine
#https://docs.godotengine.org/en/stable/classes/class_inputeventmidi.html

#Pour faire des outputs MIDI, voir le plugin de NullMembers ci-dessous:
#https://github.com/NullMember/godot-rtmidi
