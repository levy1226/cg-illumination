#version 300 es
precision mediump float;

// Input
in vec2 model_uv;
in vec3 diffuse_illum;
in vec3 specular_illum;

// Uniforms
uniform vec3 mat_color;
uniform vec3 mat_specular;
uniform sampler2D mat_texture;
uniform vec3 ambient; // Ia

// Output
out vec4 FragColor;

void main() {
    // Sample the texture color
    vec3 texture_color = texture(mat_texture, model_uv).rgb;

    // Combine diffuse and specular illumination with material color and ambient light
    vec3 lighting = ambient * mat_color + diffuse_illum * mat_color + specular_illum * mat_specular;

    // Final color calculation
    vec3 final_color = texture_color * lighting;

    // Output final color
    FragColor = vec4(final_color, 1.0);
}
