shader_type canvas_item;

uniform sampler2D viewport_texture: repeat_disable;
uniform float warp_amount: hint_range(0, 1) = 0.5;

uniform sampler2D noise: repeat_enable;
uniform float noise_amount: hint_range(0.0, 1.0) = 0.2;
uniform float noise_speed = 8;

vec2 warp_uv(vec2 uv) {
  vec2 uv_offset = uv - vec2(0.5);
  float warp = dot(uv_offset, uv_offset);
  return uv + uv_offset * warp * warp_amount;
}

float step_edges(vec2 warped_uv) {
  float edge_step = step(warped_uv.x, 1.0);
  edge_step *= step(0.0, warped_uv.x);
  edge_step *= step(warped_uv.y, 1.0);
  edge_step *= step(0.0, warped_uv.y);
  return edge_step;
}

void fragment() {
  vec2 warped_uv = warp_uv(UV);
  
  vec4 viewport_colour = texture(viewport_texture, warped_uv);  
  vec4 noise_colour = texture(noise, warped_uv + vec2(0, TIME * noise_speed));
  
  COLOR = mix(viewport_colour, noise_colour, noise_amount);
  
  float edge_step = step_edges(warped_uv);
  COLOR.rgb *= edge_step;
  COLOR.a = mix(1.0, COLOR.a, edge_step);
}
