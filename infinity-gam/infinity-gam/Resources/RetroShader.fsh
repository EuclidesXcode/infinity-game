void main() {
    // Basic Scanline effect
    vec2 uv = v_tex_coord;
    
    // Create scanlines based on Y coordinate
    float count = 100.0; // Number of lines
    float scanline = sin(uv.y * count * 3.14159);
    
    // Darken every other line essentially
    // Map -1..1 to 0.5..1.0 roughly
    float intensity = 0.8 + 0.2 * scanline;
    
    vec4 color = SKDefaultShading();
    
    // Apply scanline intensity
    gl_FragColor = vec4(color.rgb * intensity, color.a);
}
