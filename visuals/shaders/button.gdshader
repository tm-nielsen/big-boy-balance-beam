shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform float frequency = 20;
uniform vec3 albedo: source_color;
uniform float roughness: hint_range(0, 1) = 0.1;

void vertex() {
  if (VERTEX.y > 0.0) {
    float t = sin(TIME * frequency);
    VERTEX.y *= t;
  }
}

void fragment() {
  ALBEDO = albedo;
  ROUGHNESS = roughness;
}
