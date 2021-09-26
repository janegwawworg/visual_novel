extends TextureRect

signal next_requested
signal display_finished
signal choice_made(target_id)

export var display_speed := 20.0
export var bbcode_text := "" setget set_bbcode_text

onready var _rich_text_label: RichTextLabel = $RichTextLabel
onready var _name_label: Label = $NameBackground/Label
onready var _blinking_arrow: Control = $RichTextLabel/BlinkingArrow
onready var _tween: Tween = $Tween
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _choice_selector: ChoiceSelector = $ChoiceSelector
onready var _name_background: TextureRect = $NameBackground


func _ready() -> void:
	hide()
	_blinking_arrow.hide()

	_name_label.text = ""
	_rich_text_label.bbcode_text = ""
	_rich_text_label.visible_characters = 0

	_tween.connect("tween_all_completed", self, "_on_Tween_tween_all_completed")
	_choice_selector.connect("choice_made", self, "_on_ChoiceSelector_choice_made")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if _blinking_arrow.visible:
			emit_signal("next_requested")
		else:
			_tween.seek(INF)


func display(text: String, character_name := "", speed := display_speed) -> void:
	set_bbcode_text(text)

	if speed != display_speed:
		display_speed = speed

	if character_name == ResourceDB.get_narrator().display_name:
		_name_background.hide()
	elif character_name != "":
		_name_background.show()
		if _name_label.text == "":
			_name_label.appear()

		_name_label.text = character_name


func set_bbcode_text(text: String) -> void:
	bbcode_text = text
	if not is_inside_tree():
		yield(self, "ready")

	_blinking_arrow.hide()
	_rich_text_label.bbcode_text = bbcode_text
	call_deferred("_begin_dialogue_display")


func _begin_dialogue_display() -> void:
	var character_count := _rich_text_label.get_total_character_count()
	_tween.interpolate_property(
		_rich_text_label, "visible_characters", 0, character_count, character_count / display_speed
		)
	_tween.start()


func _on_Tween_tween_all_completed() -> void:
	emit_signal("display_finished")
	_blinking_arrow.show()


func fade_in_async() -> void:
	_anim_player.play("fade_in")
	_anim_player.seek(0.0, true)
	yield(_anim_player, "animation_finished")


func fade_out_async() -> void:
	_anim_player.play("fade_out")
	yield(_anim_player, "animation_finished")


func display_choice(choices: Array) -> void:
	_name_background.hide()
	_rich_text_label.hide()
	_blinking_arrow.hide()

	_name_background.disappear()
	_choice_selector.display(choices)


func _on_ChoiceSelector_choice_made(target_id: int) -> void:
	emit_signal("choice_made", target_id)
	_name_background.show()
	_rich_text_label.show()
	_name_background.appear()
