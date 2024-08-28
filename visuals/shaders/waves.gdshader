shader_type canvas_item;

uniform float water_level = 100;

uniform float amplitude_1 = 10;
uniform float frequency_1 = 4;
uniform float wavelength_1 = 200;

uniform float amplitude_2 = 5;
uniform float frequency_2 = 2;
uniform float wavelength_2 = 100;

uniform ivec2 screen_resolution = ivec2(240, 135);
uniform float screen_margin: hint_range(0, 1) = 0.25;

varying vec2 resolution;
varying vec2 position;

float wave(float wavelength, float amplitude, float frequency)
{
  float x = position.x / wavelength;
  return amplitude * cos((TIME + x) * frequency);
}

void vertex() {
  resolution = vec2(screen_resolution);
  resolution *= (1.0 + 2.0 * screen_margin);
  position = (UV - 0.5) * resolution;
  VERTEX = position;
}

void fragment() {
  float t = wave(wavelength_1, amplitude_1, frequency_1);
  t += wave(wavelength_2, amplitude_2, frequency_2);
  
  COLOR.a *= step(water_level + t, position.y);
}