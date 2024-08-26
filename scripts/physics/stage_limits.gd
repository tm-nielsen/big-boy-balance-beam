class_name StageLimits
extends Node2D

static var left: float
static var right: float
static var bottom: float

@export var left_limit: float = -120
@export var right_limit: float = 120
@export var bottom_threshold: float = 80

func _ready():
    right = right_limit
    left = left_limit
    bottom = bottom_threshold