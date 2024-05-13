#version 300 es
precision highp float;

// Attributes
in vec3 position;
in vec2 uv;

// Uniforms
uniform mat4 world;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 camera_position;
uniform int num_lights;
uniform vec3 light_positions[8];
uniform vec3 light_colors[8];
uniform sampler2D heightmap;
uniform vec2 ground_size;
uniform float height_scalar;
uniform float mat_shininess;
uniform vec2 texture_scale;

// Output
out vec2 model_uv;
out vec3 vertex_normal;
out vec3 vertex_view_dir;
out vec3 vertex_light_dir;
out vec3 diffuse_illum;
out vec3 specular_illum;

void main() {
        // Sample heightmap at current vertex uv coordinates
    float heightValue = texture(heightmap, uv).r; // Get height value from texture
    
    // Remap height value from [0, 1] range to [-1, 1] range
    float remappedHeight = heightValue * 2.0 - 1.0;
    
    // Scale the height by the scalar factor
    float height = remappedHeight * height_scalar; // Adjusted height
    
    // Displace vertex position along the y-axis
    vec3 displacedPosition = position + vec3(0.0, height, 0.0);

    // Get initial position of vertex (prior to height displacement)
    vec4 world_pos = world * vec4(displacedPosition, 1.0);

    // Compute vertex normal
    vec3 normal = vec3(0.0, 1.0, 0.0); // Assuming ground is flat, so normal is pointing straight up

    // Pass vertex texcoord onto the fragment shader
    model_uv = uv;

    // Compute vertex normal (approximated using heightmap)
    float dx = texture(heightmap, uv + vec2(texture_scale.x, 0.0)).r - texture(heightmap, uv - vec2(texture_scale.x, 0.0)).r;
    float dy = texture(heightmap, uv + vec2(0.0, texture_scale.y)).r - texture(heightmap, uv - vec2(0.0, texture_scale.y)).r;
    vec3 tangent = vec3(2.0 * ground_size.x / texture_scale.x, 0.0, dx * height_scalar);
    vec3 bitangent = vec3(0.0, 2.0 * ground_size.y / texture_scale.y, dy * height_scalar);
    vertex_normal = normalize(cross(tangent, bitangent));

    // Compute diffuse and specular illumination per vertex
    diffuse_illum = vec3(0.0);
    specular_illum = vec3(0.0);
    for (int i = 0; i < num_lights; ++i) {
        // Calculate light direction
        vec3 light_dir = normalize(light_positions[i] - vec3(world_pos));
        
        // Calculate diffuse component
        float diffuse_factor = max(dot(normalize(vertex_normal), light_dir), 0.0);
        diffuse_illum += (diffuse_factor * light_colors[i]);
        
        // Calculate specular component (Phong lighting model)
        vec3 view_dir = normalize(camera_position - vec3(world_pos));
        vec3 reflect_dir = reflect(-light_dir, normalize(vertex_normal));
        float spec_angle = max(dot(view_dir, reflect_dir), 0.0);
        float specular_factor = pow(spec_angle, mat_shininess);
        specular_illum += specular_factor * light_colors[i];
    }

    // Transform and project vertex from 3D world-space to 2D screen-space
    gl_Position = projection * view * world_pos;
}
