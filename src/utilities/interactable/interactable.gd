# Any entity with the Interactable Node as a child may be "interacted" with by the Player.
extends Node2D
class_name Interactable

signal interactable_selected
signal interactable_deselected
signal interact_triggered

func select_interactable() -> void:
	# TODO: Highlight parent of this Node using shaders or other nonsense.
	interactable_selected.emit()

func deselect_interactable() -> void:
	# TODO: Remove highlight from parent of this Node.
	interactable_deselected.emit()

func interact() -> void:
	interact_triggered.emit()
