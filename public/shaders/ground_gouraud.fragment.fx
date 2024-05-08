#version 300 es
precision mediump float;

// Input
in vec2 model_uv;
in vec3 vertex_normal;
in vec3 vertex_view_dir;
in vec3 vertex_light_dir;
in vec3 diffuse_illum;
in vec3 specular_illum;

// Uniforms
uniform vec3 mat_specular;
uniform sampler2D mat_texture;
uniform vec3 ambient; // Ia

// Output
out vec4 FragColor;

void main() {
    // Sample the material color from the texture
    vec3 mat_color = texture(mat_texture, model_uv).rgb;

    // Calculate ambient lighting
    vec3 ambient_illum = ambient * mat_color;

    // Calculate diffuse lighting
    float diffuse_factor = max(dot(normalize(vertex_normal), normalize(vertex_light_dir)), 0.0);
    vec3 diffuse_illum_interpolated = diffuse_factor * diffuse_illum;

    // Calculate specular lighting
    vec3 H = normalize(vertex_view_dir + vertex_light_dir);
    float specular_factor = pow(max(dot(normalize(vertex_normal), H), 0.0),  mat_specular.g);
    vec3 specular_illum_interpolated = specular_factor * mat_specular * specular_illum;

    // Combine ambient, diffuse, and specular lighting
    vec3 final_color = ambient_illum + diffuse_illum_interpolated + specular_illum_interpolated;

    // Clamp final color to ensure it's within the valid range
    final_color = clamp(final_color, 0.0, 1.0);

    // Output final color
    FragColor = vec4(final_color, 1.0);
}
