#version 300 es
precision mediump float;

// Input
in vec3 model_position;
in vec3 model_normal;
in vec2 model_uv;

// Uniforms
// material
uniform vec3 mat_color;
uniform vec3 mat_specular;
uniform float mat_shininess;
uniform sampler2D mat_texture;
// camera
uniform vec3 camera_position;
// lights
uniform vec3 ambient; // Ia
uniform int num_lights;
uniform vec3 light_positions[8];
uniform vec3 light_colors[8]; // Ip

// Output
out vec4 FragColor;

void main() {
    // Sample the material texture
    vec3 texture_color = texture(mat_texture, model_uv).rgb;

    // Calculate ambient light contribution
    vec3 ambient_color = ambient * mat_color;

    // Initialize final color
    vec3 final_color = vec3(0.0);

    // Calculate lighting contributions from each light source
    for (int i = 0; i < num_lights; ++i) {
        // Calculate light direction and distance
        vec3 light_dir = normalize(light_positions[i] - model_position);
        float light_distance = length(light_positions[i] - model_position);

        // Calculate diffuse component
        float diffuse_factor = max(dot(model_normal, light_dir), 0.0);
        vec3 diffuse_color = light_colors[i] * mat_color * diffuse_factor;

        // Calculate specular component
        vec3 view_dir = normalize(camera_position - model_position);
        vec3 reflect_dir = reflect(-light_dir, model_normal);
        float spec_angle = max(dot(view_dir, reflect_dir), 0.0);
        float specular_factor = pow(spec_angle, mat_shininess);
        vec3 specular_color = light_colors[i] * mat_specular * specular_factor;

        // Add diffuse and specular contributions to final color
        final_color += ambient_color + diffuse_color + specular_color;
    }

    // Add ambient color to final color
    final_color += ambient_color;

    // Multiply final color with texture color
    final_color *= texture_color;

    // Output the final color
    FragColor = vec4(final_color, 1.0);
}
