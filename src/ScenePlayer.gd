extends Control
class_name ScenePlayer

signal scene_finished
signal transition_finished
signal restart_requested

const KEY_END_OF_SCENE := -1
const KEY_RESTART_SCENE := -2
const TRANSITIONS := {
	fade_in = "_appear_async",
	fade_out = "_disappear_async",
	}

var _scene_data := {}

onready var _text_box := $TextBox
onready var _character_displayer := $CharacterDisplay
onready var _background := $Background
onready var _anim_player: AnimationPlayer = $FadeAnimationPlayer


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
		elif "transition" in node:
			call(TRANSITIONS[node.transition])
			yield(self, "transition_finished")
			key = node.next
		elif "choices" in node:
			_text_box.display_choice(node.choices)
			key = yield(_text_box, "choice_made")
			if key == KEY_RESTART_SCENE:
				emit_signal("restart_requested")
				return
		else:
			key = node.next

		_character_displayer.hide()
		emit_signal("scene_finished")


func _appear_async() -> void:
	_anim_player.play("fade_in")
	yield(_anim_player, "animation_finished")
	yield(_text_box.fade_in_async(), "completed")
	emit_signal("transition_finished")


func _disappear_async() -> void:
	yield(_text_box.fade_out_async(), "completed")
	_anim_player.play("fade_out")
	yield(_anim_player, "animation_finished")
	emit_signal("transition_finished")


func load_scene(file_path: String) -> void:
	var file := File.new()
	file.open(file_path, File.READ)
	_scene_data = str2var(file.get_as_text())
	file.close()


func _store_scene_data(data: Dictionary, path: String) -> void:
	var file := File.new()
	file.open(path, File.WRITE)
	file.store_string(var2str(data))
	file.close()
