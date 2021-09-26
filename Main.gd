extends Node

const ScenePlayer := preload("res://src/ScenePlayer.tscn")

const SCENES := ["res://Scenes/1.scene", "res://Scenes/2.scene"]

var _current_index := -1
var _scene_player: ScenePlayer


func _ready() -> void:
	_play_scene(0)


func _play_scene(index: int) -> void:
	_current_index = int(clamp(index, 0.0, SCENES.size() - 1))

	if _scene_player:
		_scene_player.queue_free()

	_scene_player = ScenePlayer.instance()
	add_child(_scene_player)
	_scene_player.load_scene(SCENES[_current_index])

	_scene_player.connect("scene_finished", self, "_on_ScenePlayer_scene_finished")
	_scene_player.connect("restart_requested", self, "_on_ScenePlayer_restart_requested")
	_scene_player.run_scene()


func _on_ScenePlayer_scene_finished() -> void:
	if _current_index == SCENES.size() - 1:
		return

	_play_scene(_current_index + 1)


func _on_ScenePlayer_restart_requested() -> void:
	_play_scene(_current_index)
