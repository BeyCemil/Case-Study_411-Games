#ifndef OCCASOFTWARE_BUTO_INPUT_INCLUDED
#define OCCASOFTWARE_BUTO_INPUT_INCLUDED

#pragma warning (disable : 3571)

Texture3D IntegratorData;

SamplerState buto_input_linear_clamp_sampler;
float _MaxDistanceVolumetric;
float _InverseMaxDistanceVolumetric;
float _inverse_depth_ratio;
float _depth_ratio;

float _ButoIsEnabled;
float4 ButoFog(float2 ScreenPosition, float Distance)
{
    if (_ButoIsEnabled == 0.0)
    {
        return half4(0, 0, 0, 1);
    }
	
	float3 uvw = float3(ScreenPosition, pow(Distance * _InverseMaxDistanceVolumetric, _inverse_depth_ratio));
	uvw = saturate(uvw);
				
	float4 integratorData = IntegratorData.SampleLevel(buto_input_linear_clamp_sampler, uvw, 0).rgba; 
	return integratorData;
}

float3 ButoFogBlend(float2 ScreenPosition, float Distance, float3 InputColor)
{
	float4 fog = ButoFog(ScreenPosition, Distance);
	return (InputColor.rgb * fog.a) + fog.rgb;
}

void ButoFog_float(float2 ScreenPosition, float Distance, out float3 Color, out float Density)
{
	Color = 0;
	Density = 1;
	#ifndef SHADERGRAPH_PREVIEW
	float4 fog = ButoFog(ScreenPosition, Distance);
	
	// Note: To blend with target, multiply Density by pre-fog frag color, then add fog color.
	// Alternatively, use ButoFogBlend, which handles this blending for you.
	Color = fog.rgb;
	Density = fog.a;
	#endif
}

void ButoFogBlend_float(float2 ScreenPosition, float Distance, float3 InputColor, out float3 Color)
{
	Color = InputColor;
	#ifndef SHADERGRAPH_PREVIEW
	Color = ButoFogBlend(ScreenPosition, Distance, InputColor);
	#endif
}
#pragma warning (restore : 3571)
#endif