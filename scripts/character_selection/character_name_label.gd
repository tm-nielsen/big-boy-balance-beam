class_name CharacterNameLabel
extends Label

@export_subgroup('font_size', 'font_size')
@export var font_size_maximum: float = 16
@export var font_size_minimum: float = 6

@export_subgroup('font_shadow')
@export var font_shadow_offset := Vector2(2, 2)

# replace underscores with spaces