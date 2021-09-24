extends Control
class_name ScenePlayer

signal scene_finished

const KEY_END_OF_SCENE := -1

var _scene_data := {
	0: {
		character = "sophia",
		side = "left",
		animation = "enter",
		line = "Hi there! My name's Sophia.",
		next = 1
		},
	1: {
		character = "dani",
		side = "right",
		animation = "enter",
		next = 2,
		},
	2: {
		character = "dani",
		line = "Hey, I'm Dani.",
		next = -1
	   }
	}

onready var _text_box := $TextBox
onready var _character_displayer := $CharacterDisplay
onready var _background := $Background


func _ready() -> void:
	yield(_text_box.fade_in_async(), "completed")
	run_scene()


func run_scene() -> void:
	var key = _scene_data.keys()[0]
	while key != KEY_END_OF_SCENE:
		var node: Dictionary = _scene_data[key]

		var character: Character = (
			ResourceDB.get_character(node.character)
			if "character" in node
			else ResourceDB.get_narrator()
			)

		if "background" in node:
			var bg: Background = ResourceDB.get_background(node.background)
			_background.texture = bg.texture

		if "character" in node:
			var side: String = node.side if "side" in node else CharacterDisplay.SIDE.LEFT

			var animation: String = node.get("animation", "")
			var expression: String = node.get("expression", "")

			_character_displayer.display(character, side, expression, animation)

			if not "line" in node:
				yield(_character_displayer, "display_finished")

		if "line" in node:
			_text_box.display(node.line, character.display_name)
			yield(_text_box, "next_requested")
			key = node.next
		else:
			key = node.next

		#_character_displayer.hide()
		emit_signal("scene_finished")
