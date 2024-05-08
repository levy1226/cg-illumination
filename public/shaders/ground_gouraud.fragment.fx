#version 300 es
precision mediump float;

// Input
in vec2 model_uv;
in vec3 diffuse_illum;
in vec3 specular_illum;

// Uniforms
// material
uniform vec3 mat_color;
uniform vec3 mat_specular;
uniform sampler2D mat_texture;
// light from environment
uniform vec3 ambient; // Ia

// Output
out vec4 FragColor;

void main() {
    vec3 model_color = mat_color * texture(mat_texture, model_uv).rgb;
    
    // Calculate final color using Gouraud shading
    vec3 gouraud_diffuse = diffuse_illum * model_color;
    vec3 gouraud_specular = specular_illum * mat_specular;
    vec3 final_color = ambient + gouraud_diffuse + gouraud_specular;
    
    // Color
    FragColor = vec4(final_color, 1.0);
}