#version 300 es
precision highp float;

// Attributes
in vec3 position;
in vec3 normal;
in vec2 uv;

// Uniforms
// projection 3D to 2D
uniform mat4 world;
uniform mat4 view;
uniform mat4 projection;
// material
uniform vec2 texture_scale;

// Output
out vec3 model_position;
out vec3 model_normal;
out vec2 model_uv;

void main() {
    
    model_position = vec3(world * vec4(position, 1.0));
    
    model_normal = mat3(transpose(inverse(world))) * normal;
    
    model_uv = uv * texture_scale;

    
    gl_Position = projection * view * world * vec4(position, 1.0);
}
