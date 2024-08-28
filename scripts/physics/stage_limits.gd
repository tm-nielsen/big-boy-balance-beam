class_name StageLimits
extends Node2D

signal bottom_threshold_reached(ball: PhysicsBall)

static var left: float
static var right: float
static var bottom: float

@export var left_limit: float = -120
@export var right_limit: float = 120
@export var bottom_threshold: float = 80

@export var ball_manager: PhysicsBallManager


func _ready():
    right = right_limit
    left = left_limit
    bottom = bottom_threshold

func _physics_process(_delta: float):
    for ball in ball_manager.physics_balls:
        if ball.position.y > bottom_threshold:
            bottom_threshold_reached.emit(ball)
