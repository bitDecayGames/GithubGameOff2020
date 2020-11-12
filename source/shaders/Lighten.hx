package shaders;

import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class Lighten extends FlxShader
{
	@:glFragmentSource('
        #pragma header

        uniform float iTime;
        uniform float lightSourceX;
        uniform float lightSourceY;
        uniform float aspectRatio;
        uniform float lightRadius;
        uniform bool isShaderActive;

        void main()
        {
            vec2 uv = openfl_TextureCoordv;
            vec4 pixel = texture2D(bitmap, openfl_TextureCoordv);

			if (!isShaderActive)
			{
				gl_FragColor = pixel;
				return;
            }
            
            vec2 lightSourceVector = vec2(lightSourceX, lightSourceY);
            vec2 screenAspectRatio = vec2(aspectRatio, 1);

            // the distance from the light source as a value from 0 to 1 
            // a value of (.5, .5) would mean the distance between the pixel and light source is half the distance of the entire screen
            vec2 distanceFromLightSourceVector = lightSourceVector - uv; 

            // Adjust for screen aspect ratio
            float distanceFromLightSource = length(distanceFromLightSourceVector / screenAspectRatio); 

            if (distanceFromLightSource >= lightRadius) {
                pixel = vec4(0, 0, 0, 1.0);
            }
			gl_FragColor = pixel;
        }')

    public function new()
    {
        super();
    }    
}