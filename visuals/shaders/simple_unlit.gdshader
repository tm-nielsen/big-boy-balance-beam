shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform vec3 albedo: source_color;
uniform float roughness: hint_range(0, 1) = 0.1;

void fragment() {
  ALBEDO = albedo;
  ROUGHNESS = roughness;
}
