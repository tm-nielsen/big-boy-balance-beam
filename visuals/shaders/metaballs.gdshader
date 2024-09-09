shader_type canvas_item;

uniform ivec2 screen_resolution = ivec2(240, 135);

const int ball_count = 400;
uniform int visible_ball_count = 50;

uniform vec2 ball_positions[ball_count];
uniform float ball_radii[ball_count];

varying vec2 resolution;
varying vec2 position;

void vertex() {
  resolution = vec2(screen_resolution);
  position = (UV - 0.5) * resolution;
  VERTEX = position;
}

float distance_squared(vec2 a, vec2 b) {
  float d_x = a.x - b.x;
  float d_y = a.y - b.y;
  return d_x * d_x + d_y * d_y;
}

void fragment() {  
  float t = 0.0;
  int n = min(ball_count, visible_ball_count);
  for (int i = 0; i < n; i++)
  {
    vec2 ball_position = ball_positions[i];
    float radius = ball_radii[i];
    float d = distance_squared(position, ball_position);
    t += (radius * radius) / d;
  }
  
  COLOR.a *= step(1.0, t);
}