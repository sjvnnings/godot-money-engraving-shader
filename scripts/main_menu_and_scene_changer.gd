extends Control

var menu_enabled := true

const SCENE_ORDER := [preload("res://example_scenes/reactive_particles.tscn"),
					  preload("res://example_scenes/dark_table.tscn"),
					  preload("res://example_scenes/single_dollar_render.tscn"),
					  preload("res://example_scenes/money_sphere_with_particles.tscn"),
					  preload("res://example_scenes/physical_stacks.tscn"),
					  preload("res://example_scenes/just_the_money_texture.tscn")]

var scene_index : int = 0;

onready var main_menu = $main_menu
onready var processing_viewport = $two_tone_background
onready var cycle_hint = $cycle_hint
onready var two_tone_post_mat = $two_tone_background.material
onready var view := $two_tone_background/Viewport

onready var current_scene := view.get_child(0);

func _on_start_button_button_up():
	$main_menu/VBoxContainer/CenterContainer/start_button.text = "Resume"
	
	toggle_menu(false)

func toggle_menu(toggled : bool) -> void:
	main_menu.visible = toggled
	cycle_hint.visible = false
	processing_viewport.material = two_tone_post_mat if toggled else null
	
	view.transparent_bg = toggled
	
	menu_enabled = toggled

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused

func cycle_scene(dir : int):
	scene_index += dir
	scene_index = scene_index % SCENE_ORDER.size()
	
	current_scene.queue_free()
	current_scene = SCENE_ORDER[scene_index].instance()
	view.add_child(current_scene)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_menu(true)
	elif event.is_action_pressed("cycle_scene_forward") and !menu_enabled:
		cycle_scene(1)
	elif event.is_action_pressed("cycle_scene_backward") and !menu_enabled:
		cycle_scene(-1)
	elif event.is_action_pressed("pause_scene"):
		toggle_pause()


func _on_full_screen_button_button_up():
	OS.window_fullscreen = !OS.window_fullscreen
