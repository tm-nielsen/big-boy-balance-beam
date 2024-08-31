shader_type canvas_item;

uniform float points = 2.0;
uniform float frequency = 1.0;
uniform float height: hint_range(0, 1) = 0.1;

uniform vec3 background_colour: source_color;

uniform float outline_width: hint_range(0, 0.5) = 0.05;
uniform float outline_height: hint_range(0, 0.5) = 0.03;
uniform vec3 outline_colour: source_color;


void fragment() {
  float d = sin(UV.x * PI);
  
  float x = UV.x;
  x += TIME * frequency;
  float y = UV.y + 0.5 - d * height + height;
  
  float s = sign(sin(x * TAU * points));
  
  float z = (x * points) + (s * y);
  z *= s;
  z = mod(z, 1);
  float n = step(0.5, mod(z, 1));
  
  float a = step(n, 0.0);
  
  y += 2.0 * d * height;
  x -= 2.0 * TIME * frequency;
  float s_2 = sign(sin(x * TAU * points));
  
  float z_2 = (x * points) + (s_2 * y);
  z_2 *= s_2;
  z_2 = mod(z_2, 1);
  float n_2 = step(0.5, mod(z_2, 1));
  
  float y_step = step(UV.y + height, 0.5 + d * height);
  
  float y_cutoff = step(UV.y + height, 1.0 + d * height);
  float y_cutoff_2 = step(UV.y + height, 1.0 - d * height);
  
  float c = step(n_2, 0) * step(a, 0) * (1.0 - y_step);
  COLOR.rgb *= mix(vec3(1), background_colour, c);
  
  a += step(n_2, 0.0) * y_cutoff_2;
  a += y_step;
  a *= y_cutoff;
  
  //vec2 pos = UV / SCREEN_PIXEL_SIZE;
  //vec2 size = vec2(1) * SCREEN_PIXEL_SIZE;
  //pos = VERTEX;
  //float o = step(pos.x, 20.0);
  float o = step(UV.x, outline_width);
  o += step(1.0 - outline_width, UV.x);
  o += step(UV.y, outline_height);
  o += step(0.5 - mod(z, 1), outline_height * 2.0) * step(0.5 + d * height, UV.y + height + outline_height);
  o = clamp(o, 0, 1);
  COLOR.rgb *= mix(vec3(1), outline_colour, o);
  
  COLOR.a = a;
}
