shader_type canvas_item;

uniform float water_level = 100;
uniform vec3 outline_colour: source_color = vec3(1.2);
uniform float outline_width = 2;

uniform float amplitude_1 = 10;
uniform float frequency_1 = 4;
uniform float wavelength_1 = 200;

uniform float amplitude_2 = 5;
uniform float frequency_2 = 2;
uniform float wavelength_2 = 100;

uniform ivec2 screen_resolution = ivec2(240, 135);
uniform float screen_margin: hint_range(0, 1) = 0.25;

uniform vec2 p1_distortion_point;
uniform vec2 p2_distortion_point;
uniform float distortion_radius = 30;
uniform float p1_distortion_amount: hint_range(0, 1) = 1;
uniform float p2_distortion_amount: hint_range(0, 1) = 1;

varying vec2 position;

float wave(float wavelength, float amplitude, float frequency)
{
  float x = position.x / wavelength;
  return amplitude * cos((TIME + x) * frequency);
}

float length_squared(vec2 v) {
  return v.x * v.x + v.y * v.y;
}

vec2 get_distortion_offset()
{
  float distortion_radius_squared = distortion_radius * distortion_radius;
  
  vec2 p1_displacement = p1_distortion_point - position;
  float p1_d = length_squared(p1_displacement);
  float p1_t = distortion_radius_squared / p1_d;
  p1_t *= p1_distortion_amount;
  vec2 offset = p1_t * p1_displacement;
  
  vec2 p2_displacement = p2_distortion_point - position;
  float p2_d = length_squared(p2_displacement);
  float p2_t = distortion_radius_squared / p2_d;
  p2_t *= p2_distortion_amount;
  offset += p2_t * p2_displacement;
  return offset;
}

void vertex() {
  vec2 resolution = vec2(screen_resolution);
  resolution *= (1.0 + 2.0 * screen_margin);
  position = (UV - 0.5) * resolution;
  VERTEX = position;
}

void fragment() {
  float t = wave(wavelength_1, amplitude_1, frequency_1);
  t += wave(wavelength_2, amplitude_2, frequency_2);
  
  vec2 distortion_offset = get_distortion_offset();
  float y_off = distortion_offset.y;
  
  float outline_step = step(position.y - outline_width, water_level + t);
  COLOR.rgb *= outline_step * outline_colour + vec3(1.0 - outline_step);
  
  COLOR.a *= step(water_level + y_off + t, position.y);
}