attribute vec4 Position; 
 
uniform mat4 Modelview;
 
attribute vec2 TexCoordIn; 
varying vec2 TexCoordOut; 
 
void main(void) { 
    gl_Position = Modelview * Position;
    gl_Position = vec4(gl_Position.x * 2.0 / 320.0 - 1.0,
                     gl_Position.y * -2.0 / 440.0 + 1.0,
                     gl_Position.z, 
                     1.0);               
    TexCoordOut = TexCoordIn; 
}