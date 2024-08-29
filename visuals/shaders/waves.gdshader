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
uniform vec2 screen_margin = vec2(0.2, 0.5);

varying vec2 position;

float wave(float wavelength, float amplitude, float frequency)
{
  float x = position.x / wavelength;
  return amplitude * cos((TIME + x) * frequency);
}

void vertex() {
  vec2 resolution = vec2(screen_resolution);
  resolution *= 1.0 + 2.0 * screen_margin;
  position = (UV - 0.5) * resolution;
  VERTEX = position;
}

void fragment() {
  float t = wave(wavelength_1, amplitude_1, frequency_1);
  t += wave(wavelength_2, amplitude_2, frequency_2);
  
  float outline_step = step(position.y - outline_width, water_level + t);
  COLOR.rgb *= outline_step * outline_colour + vec3(1.0 - outline_step);
  
  COLOR.a *= step(water_level + t, position.y);
}