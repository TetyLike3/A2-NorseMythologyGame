//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 u_TintColour;

void main()
{
	vec4 baseColour = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = baseColour * u_TintColour;
}